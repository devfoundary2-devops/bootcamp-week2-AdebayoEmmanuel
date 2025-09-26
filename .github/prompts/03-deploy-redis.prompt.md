---
mode: ask
---
# Task: Deploy Redis Cache

## Objective
To create and apply the Kubernetes Deployment and Service manifests for the Redis cache, ensuring it is operational within the `shopmicro` namespace.

## Detailed Instructions for Copilot
1.  **Refer to Instructions:** Your primary reference is `KUBERNETES_BOOTCAMP_LAB.md`, specifically the content under "Step 2.3: Redis Cache".
2.  **Generate Kubernetes Manifest:** Based on the YAML provided in `KUBERNETES_BOOTCAMP_LAB.md`, generate the complete Kubernetes manifest for Redis. This manifest should include both a `Deployment` and a `Service`.
    *   The Deployment should be named `redis` in the `shopmicro` namespace.
    *   It should use the `redis:7-alpine` image.
    *   It should expose container port `6379`.
    *   The Service should be named `redis` in the `shopmicro` namespace.
    *   It should select pods with the label `app: redis`.
    *   It should expose port `6379` targeting the container port `6379`.
3.  **Specify File Path:** Save the generated combined YAML to the file `k8s/deployments/redis.yaml`. If this file already exists, ask for my explicit confirmation before overwriting it.
4.  **Provide Deployment Command:** After generating the YAML, provide the exact `kubectl apply` command I need to run to deploy this manifest.
5.  **Provide Verification Command:** Suggest a `kubectl` command I can use to verify that the Redis pod is running and healthy (e.g., `kubectl get pods -n shopmicro -l app=redis -w`).
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` with a summary of this task, including the file created and the commands used.
7.  **Explain Configuration:** Briefly explain why a `persistent volume` is not configured for Redis in this lab setup and what the implications might be (referencing the use of a default ephemeral storage).