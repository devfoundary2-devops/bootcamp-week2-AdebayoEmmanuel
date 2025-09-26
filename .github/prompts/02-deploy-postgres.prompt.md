---
mode: ask
---
# Task: Deploy PostgreSQL Database

## Objective
To create and apply the Kubernetes Deployment and Service manifests for the PostgreSQL database, ensuring it is running within the `shopmicro` namespace and ready for application connections.

## Detailed Instructions for Copilot
1.  **Refer to Instructions:** Your primary reference is `KUBERNETES_BOOTCAMP_LAB.md`, specifically the content under "Step 2.2: PostgreSQL Database".
2.  **Generate Kubernetes Manifest:** Based on the YAML provided in `KUBERNETES_BOOTCAMP_LAB.md`, generate the complete Kubernetes manifest for PostgreSQL. This manifest should include both a `Deployment` and a `Service`.
    *   The Deployment should be named `postgres` in the `shopmicro` namespace.
    *   It should use the `postgres:15` image.
    *   It must include the following environment variables: `POSTGRES_DB` with value "shopmicro", `POSTGRES_USER` with value "postgres", and `POSTGRES_PASSWORD` with value "postgres".
    *   It should expose container port `5432`.
    *   It should define an `emptyDir` volume named `postgres-storage` mounted at `/var/lib/postgresql/data`.
    *   The Service should be named `postgres` in the `shopmicro` namespace.
    *   It should select pods with the label `app: postgres`.
    *   It should expose port `5432` targeting the container port `5432`.
3.  **Specify File Path:** Save the generated combined YAML to the file `k8s/deployments/postgres.yaml`. If this file already exists, ask for my explicit confirmation before overwriting it.
4.  **Provide Deployment Command:** After generating the YAML, provide the exact `kubectl apply` command I need to run to deploy this manifest.
5.  **Provide Verification Command:** Suggest a `kubectl` command I can use to verify that the PostgreSQL pod is running and healthy (e.g., `kubectl get pods -n shopmicro -l app=postgres -w`).
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` with a summary of this task, including the file created and the commands used.
7.  **Explain Configuration:** Briefly explain the purpose of the `emptyDir` volume in this context and why the environment variables for the database are defined in the deployment manifest.