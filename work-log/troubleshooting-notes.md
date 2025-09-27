- **Service:** `backend`
- **Symptom:** Pods were stuck in a `CrashLoopBackOff` state after the initial deployment.
- **Diagnosis (Phase 1):**
  - Used `kubectl get pods -n shopmicro -l app=backend -w` to observe the crash loop.
  - Used `kubectl logs -n shopmicro <pod-name>` to inspect the container logs.
  - Logs revealed a clear error: `Error: Cannot find module './telemetry'`.
- **Root Cause (Initial):** The `backend/Dockerfile` was missing a `COPY` instruction for the `telemetry.js` file, causing the Node.js application to fail immediately on startup.
- **Resolution (Attempt 1):**
  1. Added `COPY --chown=nodejs:nodejs telemetry.js ./` to the `backend/Dockerfile`.
  2. Re-built the Docker image with the same tag: `docker build -t shopmicro-backend:latest -f backend/Dockerfile ./backend`.
  3. Re-loaded the image into Minikube: `minikube image load shopmicro-backend:latest`.
  4. Triggered a re-deployment by deleting the old pods: `kubectl delete pods -n shopmicro -l app=backend`.
- **Symptom (Phase 2):** The problem persisted. The newly created pods also went into `CrashLoopBackOff` with the exact same `Cannot find module './telemetry'` error.
- **Diagnosis (Phase 2):** The issue was not the code fix, but the deployment process. The use of the `:latest` tag combined with `imagePullPolicy: Never` likely caused the Kubernetes node to use its cached, older version of the image instead of the newly loaded one. Kubernetes did not detect a change because the image name and tag were identical.
- **Root Cause (Final):** Using the non-specific `:latest` tag for updates is unreliable. Kubernetes needs a unique image tag to guarantee it pulls and runs the correct version.
- **Resolution (Final):**
  1. Re-built the image with a unique, versioned tag: `docker build -t shopmicro-backend:v1.1 -f backend/Dockerfile ./backend`.
  2. Loaded the new versioned image into Minikube: `minikube image load shopmicro-backend:v1.1`.
  3. Updated `k8s/deployments/backend.yaml` to specify `image: shopmicro-backend:v1.1`.
  4. Applied the updated manifest to the cluster: `kubectl apply -f k8s/deployments/backend.yaml`. This triggered a proper rolling update.
- **Outcome:** The new pods, created with the `v1.1` image, started successfully and remained in a stable `Running` state. This reinforces the best practice of using immutable, unique tags for all container images in Kubernetes.

- **Service:** `frontend`
- **Symptom (Phase 1):** After deploying with `infrastructure/kubernetes/frontend.yaml`, pods were stuck in an `ImagePullBackOff` state.
- **Diagnosis (Phase 1):**
  - The deployment manifest did not specify an `imagePullPolicy`.
  - For images with a `:latest` tag (or if the tag is omitted), the default policy is `Always`.
  - The value of image in the container spec section of frontend.yaml was also wrongly set to `ghcr.io/your-org/shopmicro/frontend:latest`
  - This caused Kubernetes to ignore the locally loaded image and try (and fail) to pull `shopmicro-frontend:latest` from a public registry.
- **Resolution (Phase 1):**
  1. Edited `infrastructure/kubernetes/frontend.yaml` to add `imagePullPolicy: Never` to the container spec and added `shopmicro-frontend:v1.1` as the image. This forces Kubernetes to use the image present on the node.
  2. Rebuilt the image with the v1.1 tag `docker build -t shopmicro-frontend:v1.1 -f frontend/Dockerfile ./frontend`
  3. Loaded the image into minikube `minikube image load shopmicro-frontend:v1.1`
  4. Deleted the failed deployment objects: `kubectl delete -f infrastructure/kubernetes/frontend.yaml`.
  5. Re-applied the corrected manifest: `kubectl apply -f infrastructure/kubernetes/frontend.yaml`.

- **Symptom (Phase 2):** The `ImagePullBackOff` was resolved, but the new pods immediately went into a `CrashLoopBackOff` state.
- **Diagnosis (Phase 2):**
  - Used `kubectl logs -n shopmicro <pod-name>` to inspect the logs of a crashing container.
  - The logs revealed a fatal Nginx startup error: `nginx: [emerg] invalid value "must-revalidate" in /etc/nginx/conf.d/default.conf:18`.
- **Root Cause (Phase 2):** A syntax error existed in the `frontend/nginx.conf` file that was copied into the Docker image. The `gzip_proxied` directive on line 18 contained `must-revalidate`, which is not a valid parameter for that directive, causing Nginx to fail its configuration check and exit.
- **Resolution (Phase 2):**
  1. Corrected `frontend/nginx.conf` by removing the invalid `must-revalidate` parameter from the `gzip_proxied` line.
  2. To ensure the cluster picked up the change and avoided any caching issues, a new versioned image was built: `docker build -t shopmicro-frontend:v1.1 -f frontend/Dockerfile ./frontend`.
  3. The new image was loaded into the cluster: `minikube image load shopmicro-frontend:v1.1`.
  4. The `infrastructure/kubernetes/frontend.yaml` manifest was updated to point to the new, versioned image tag: `image: shopmicro-frontend:v1.1`.
  5. The final, corrected manifest was applied, triggering a successful rolling update: `kubectl apply -f infrastructure/kubernetes/frontend.yaml`.
- **Final Outcome:** The frontend pods started successfully with the corrected image and Nginx configuration, and remained in a stable `Running` state.

- **Service:** `Ingress Controller (NGINX)`
- **Symptom:** Applying `infrastructure/kubernetes/ingress.yaml` failed with an admission webhook error: `nginx.ingress.kubernetes.io/configuration-snippet annotation cannot be used`.
- **Diagnosis:** The default security configuration for the NGINX Ingress Controller addon in Minikube disables the `configuration-snippet` annotation. This is a security measure to prevent users from injecting arbitrary and potentially malicious NGINX configuration.
- **Root Cause:** The `shopmicro-ingress` resource was using the forbidden `configuration-snippet` annotation to apply several HTTP security headers.
- **Resolution:**
  1. Identified that simply removing the annotation would also remove the desired security headers.
  2. Refactored the `ingress.yaml` manifest to replace the dangerous `configuration-snippet` with the safer, officially supported `nginx.ingress.kubernetes.io/add-headers` annotation.
  3. This allowed the same security headers (like `X-Frame-Options` and `Referrer-Policy`) to be applied without violating the Ingress Controller's security policy.
  4. Re-applied the modified manifest successfully using `kubectl apply -f infrastructure/kubernetes/ingress.yaml`.
- **Outcome:** The Ingress and NetworkPolicy resources were created successfully, preserving the intended security posture while adhering to the cluster's security constraints.

- **Service:** `frontend`
- **Symptom:** After a full cluster redeployment, the `frontend-deployment` was created, but no pods were being scheduled. The ReplicaSet showed a `FailedCreate` error.
- **Diagnosis (Phase 1 - LimitRange):**
  - `kubectl describe replicaset -n shopmicro <replicaset-name>` revealed the initial error: `minimum memory usage per Container is 128Mi, but request is 64Mi`.
  - This indicated that the pod's memory request (`64Mi`) was below the minimum allowed by the `LimitRange` object (`shopmicro-limits`) defined in the `shopmicro` namespace.
- **Resolution (Phase 1):**
  1. Modified `infrastructure/kubernetes/frontend.yaml`.
  2. Increased the container's resource requests to `memory: "256Mi"` and `cpu: "100m"`, satisfying the `LimitRange` minimums.

- **Symptom (Phase 2 - ResourceQuota):**
  - After fixing the `LimitRange` issue, the pods still failed to create with a new `FailedCreate` error in the ReplicaSet events.
  - The new error was: `exceeded quota: shopmicro-quota, requested: limits.cpu=500m, used: limits.cpu=3700m, limited: limits.cpu=4`.
- **Diagnosis (Phase 2):**
  - This error came from the `ResourceQuota` object (`shopmicro-quota`), which governs the *total* resource consumption for the entire namespace.
  - The namespace had a total CPU limit of `4000m`. The existing running pods were already using `3700m`. Each new frontend pod required a `500m` limit, and `3700m + 500m` exceeds the `4000m` quota, so the request was denied.
- **Explanation of Interaction:**
  - A `LimitRange` sets rules for *individual* pods (e.g., min/max memory). A pod must conform to these rules to be considered valid.
  - A `ResourceQuota` sets rules for the *entire namespace* (e.g., total memory/CPU allowed).
  - For a pod to be created, it must **first** be valid according to the `LimitRange`, and **second**, there must be enough capacity left in the namespace's `ResourceQuota` to accommodate it. We resolved the first issue, which then allowed us to encounter the second.
- **Resolution (Phase 2):**
  1. Modified `infrastructure/kubernetes/namespace.yaml`.
  2. Increased the `ResourceQuota` for `limits.cpu` from `4000m` to `5000m`.
  3. Re-applied the `namespace.yaml` and restarted the `frontend-deployment` rollout.
- **Final Outcome:** With both the `LimitRange` and `ResourceQuota` policies satisfied, the frontend pods were created successfully and entered a stable `Running` state.

- **Service:** `frontend`
- **Symptom:** Pods were stuck in a `CrashLoopBackOff` state. `kubectl port-forward` would connect but then immediately fail with a "Connection refused" or "lost connection to pod" error.
- **Diagnosis:**
  - Used `kubectl describe pod -n shopmicro <pod-name>` which confirmed the `CrashLoopBackOff` status and showed the container was terminating with an `Error` exit code.
  - Used `kubectl logs -n shopmicro <pod-name>` to inspect the container logs.
  - The logs revealed a fatal NGINX error: `nginx: [emerg] host not found in upstream "backend" in /etc/nginx/conf.d/default.conf:47`.
- **Root Cause:** The `frontend/nginx.conf` file was configured to proxy API requests to an upstream service named `backend`. However, the actual Kubernetes service for the backend is named `backend-service`. NGINX could not resolve the incorrect hostname via cluster DNS and failed to start.
- **Resolution:**
  1. Modified `frontend/nginx.conf` to change the `proxy_pass` directive from `http://backend:3001/` to `http://backend-service:3001/`.
  2. Re-built the frontend Docker image with a new tag: `docker build -t shopmicro-frontend:v1.2 -f frontend/Dockerfile ./frontend`.
  3. Loaded the new image into Minikube: `minikube image load shopmicro-frontend:v1.2`.
  4. Updated `infrastructure/kubernetes/frontend.yaml` to use the `shopmicro-frontend:v1.2` image tag.
  5. Re-applied the manifest: `kubectl apply -f infrastructure/kubernetes/frontend.yaml`.
- **Outcome:** The new frontend pods started successfully, as NGINX could now correctly resolve the `backend-service`. Health checks via `curl` against the port-forwarded service returned `HTTP 200 OK`, confirming the fix.

- **Service:** `Mimir`
- **Symptom:** A multi-stage deployment failure involving pod scheduling blocks and container crashes.
- **Diagnosis & Resolution (Multi-Phase):**
  1.  **Phase 1: Initial Pod Scheduling Failure (Resource Policies):**
      -   **Symptom:** After the initial deployment, no Mimir pods were being created. `kubectl get deployments` showed `0/1` READY.
      -   **Diagnosis:** `kubectl describe replicaset` revealed two distinct, sequential errors:
          1.  **`LimitRange` Violation:** The first attempt was blocked because the pod's memory limit (`1.5Gi`) exceeded the `LimitRange` maximum (`1Gi`) for a single container.
          2.  **`ResourceQuota` Violation:** After fixing the `LimitRange`, the pod was blocked again, this time because the namespace's total CPU `ResourceQuota` (`5000m`) was insufficient to accommodate the new pod's CPU limit (`1000m`) on top of existing usage.
      -   **Resolution:** The `infrastructure/kubernetes/namespace.yaml` file was updated to increase both the `LimitRange`'s `max.memory` (to `2Gi`) and the `ResourceQuota`'s `hard.limits.cpu` (to `8000m`).
  2.  **Phase 2: `CrashLoopBackOff` (Configuration Error):**
      -   **Symptom:** Once the resource policy issues were resolved, the pod was created but immediately entered a `CrashLoopBackOff` state.
      -   **Diagnosis:** `kubectl logs` on the crashing pod revealed a fatal error on startup: `error loading config... field auth_enabled not found in type mimir.Config`.
      -   **Root Cause:** The `ConfigMap` within `infrastructure/kubernetes/mimir.yaml` contained an invalid top-level field, `auth_enabled: false`.
      -   **Resolution:** The invalid line was removed from the `ConfigMap` in the manifest, and the deployment was restarted via `kubectl rollout restart deployment/mimir-deployment -n shopmicro`.
- **Final Outcome:** After resolving the cascade of resource policy and configuration file errors, the Mimir deployment was successful, and the pod entered a stable `Running` state.