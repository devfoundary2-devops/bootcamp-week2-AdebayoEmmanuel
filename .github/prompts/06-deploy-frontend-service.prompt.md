---
mode: ask
---
# Task: Deploy Frontend Service

## Objective
To create and apply the Kubernetes Deployment and Service manifests for the frontend application. You will need to infer the configuration by examining the project's existing files, as a complete manifest is not provided in `KUBERNETES_BOOTCAMP_LAB.md`.

## Detailed Instructions for Copilot
1.  **Gather Context:**
    *   Examine the `frontend/Dockerfile` to determine the port the frontend application runs on internally (look for an `EXPOSE` instruction or a command like `CMD ["nginx", "-g", "daemon off;"]` which implies port 80, or a `npm start` command which might imply a different port like 3000). The `KUBERNETES_BOOTCAMP_LAB.md` file in Step 7 implies the frontend service runs on port 3000 (`kubectl port-forward ... svc/frontend 8080:3000`). The `infrastructure/kubernetes/frontend.yaml` will be your best guide.
    *   Examine `infrastructure/kubernetes/frontend.yaml` (as indicated by `tree.txt`) for a pre-existing Kubernetes manifest. Use this as your primary template.
2.  **Generate Kubernetes Manifest:** Generate a complete Kubernetes manifest for the frontend, including both a `Deployment` and a `Service`.
    *   The Deployment should be named `frontend` in the `shopmicro` namespace. Use `replicas: 1` or `replicas: 2` as a reasonable default.
    *   It should use the image `shopmicro-frontend:latest` with `imagePullPolicy: Never`.
    *   It should expose the container port you identified in the previous step (e.g., `3000`).
    *   (Optional but good practice) Suggest adding liveness and readiness probes, perhaps probing `/` or a specific health endpoint if the frontend has one.
    *   The Service should be named `frontend` in the `shopmicro` namespace.
    *   It should select pods with the label `app: frontend`.
    *   It should expose the service port, mapping it to the container port.
3.  **Specify File Path:** Save the generated combined YAML to the file `k8s/deployments/frontend.yaml`. If this file already exists, ask for my explicit confirmation before overwriting it.
4.  **Provide Deployment Command:** After generating the YAML, provide the exact `kubectl apply` command I need to run to deploy this manifest.
5.  **Provide Verification Command:** Suggest how I can verify the deployment.
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` with a summary of this task, noting that the manifest was inferred from project files.
7.  **Explain Configuration:** Briefly explain your reasoning for the chosen port and any other assumptions you made while creating the manifest.