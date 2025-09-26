---
mode: ask
---
# Task: Deploy Backend Service

## Objective
To create and apply the Kubernetes Deployment and Service manifests for the backend application, ensuring it is correctly configured to connect to PostgreSQL and Redis, and includes health probes.

## Detailed Instructions for Copilot
1.  **Refer to Instructions:** Your primary reference is `KUBERNETES_BOOTCAMP_LAB.md`, specifically "Step 4.1: Backend Service".
2.  **Generate Kubernetes Manifest:** Based on the YAML provided in `KUBERNETES_BOOTCAMP_LAB.md`, generate the complete Kubernetes manifest for the backend. This manifest should include both a `Deployment` and a `Service`.
    *   The Deployment should be named `backend` in the `shopmicro` namespace with `replicas: 2`.
    *   It should use the image `shopmicro-backend:latest` with `imagePullPolicy: Never`.
    *   It must include the following environment variables:
        *   `NODE_ENV`: "production"
        *   `PORT`: "3001"
        *   `POSTGRES_URL`: "postgresql://postgres:postgres@postgres:5432/shopmicro"
        *   `REDIS_URL`: "redis://redis:6379"
        *   `OTEL_SERVICE_NAME`: "shopmicro-backend"
    *   It should expose container port `3001`.
    *   It must include both a `livenessProbe` and a `readinessProbe` performing an HTTP GET request to `/health` on port `3001`, with the specified `initialDelaySeconds` and `periodSeconds`.
    *   The Service should be named `backend` in the `shopmicro` namespace.
    *   It should select pods with the label `app: backend`.
    *   It should expose port `3001` targeting the container port `3001`.
3.  **Specify File Path:** Save the generated combined YAML to the file `k8s/deployments/backend.yaml`. If this file already exists, ask for my explicit confirmation before overwriting it.
4.  **Provide Deployment Command:** After generating the YAML, provide the exact `kubectl apply` command I need to run to deploy this manifest.
5.  **Provide Verification Command:** Suggest how I can verify the deployment, such as checking pod status (`kubectl get pods -n shopmicro -l app=backend`) and testing the health endpoint after port-forwarding.
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` with a summary of this task.
7.  **Explain Configuration:** Briefly explain the importance of `imagePullPolicy: Never` in this Minikube context and the role of the liveness and readiness probes in maintaining application health and availability.