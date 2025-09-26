---
mode: ask
---
# Task: Deploy ML Service

## Objective
To create and apply the Kubernetes Deployment and Service manifests for the machine learning service. You will need to infer the configuration by examining the project's existing files, as a complete manifest may not be provided in `KUBERNETES_BOOTCAMP_LAB.md`.

## Detailed Instructions for Copilot
1.  **Gather Context:**
    *   Examine the `ml-service/Dockerfile` to determine the port the ML service application runs on internally (look for an `EXPOSE` instruction or a command like `python app.py` which might run on a default Flask/FastAPI port like 5000, or a specified port). The `infrastructure/kubernetes/ml-service.yaml` will be your best guide.
    *   Examine `infrastructure/kubernetes/ml-service.yaml` (as indicated by `tree.txt`) for a pre-existing Kubernetes manifest. Use this as your primary template.
2.  **Generate Kubernetes Manifest:** Generate a complete Kubernetes manifest for the ML service, including both a `Deployment` and a `Service`.
    *   The Deployment should be named `ml-service` in the `shopmicro` namespace. Use `replicas: 1` as a starting point.
    *   It should use the image `shopmicro-ml-service:latest` with `imagePullPolicy: Never`.
    *   It should expose the container port you identified in the previous step (e.g., `5000`).
    *   (Optional but good practice) Suggest adding liveness and readiness probes, perhaps probing `/` or a specific health endpoint if the ML service has one (e.g., `/health`).
    *   The Service should be named `ml-service` in the `shopmicro` namespace.
    *   It should select pods with the label `app: ml-service`.
    *   It should expose the service port, mapping it to the container port.
3.  **Specify File Path:** Save the generated combined YAML to the file `k8s/deployments/ml-service.yaml`. If this file already exists, ask for my explicit confirmation before overwriting it.
4.  **Provide Deployment Command:** After generating the YAML, provide the exact `kubectl apply` command I need to run to deploy this manifest.
5.  **Provide Verification Command:** Suggest how I can verify the deployment.
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` with a summary of this task, noting that the manifest was inferred from project files.
7.  **Explain Configuration:** Briefly explain your reasoning for the chosen port and any other assumptions you made while creating the manifest.