---
mode: ask
---
# Task: Deploy Loki for Log Aggregation

## Objective
To deploy a fully functional Loki instance within the `shopmicro` namespace to aggregate logs from all application pods.

## Detailed Instructions for Copilot
1.  **Gather Context:**
    *   Read `KUBERNETES_BOOTCAMP_LAB.md`, specifically "Step 3.2: Loki (Log Aggregation)" to understand the basic requirements (filesystem storage, port 3100).
    *   Examine all files within the `infrastructure/loki/` directory. You will find `loki.yaml`, `loki-simple.yaml`, and `loki-official.yaml`.
2.  **Analyze and Select Configuration:**
    *   Analyze the content of `loki.yaml`, `loki-simple.yaml`, and `loki-official.yaml`.
    *   Decide which configuration is most suitable for this lab environment. Justify your choice.
3.  **Generate Kubernetes Manifests:**
    *   Based on your chosen configuration file, adapt it for deployment in the `shopmicro` namespace.
    *   Ensure the Loki service is named `loki` and listens on port `3100`.
    *   The configuration should use filesystem storage for chunks and rules as indicated in `KUBERNETES_BOOTCAMP_LAB.md` (e.g., `/tmp/loki/chunks`, `/tmp/loki/rules`).
    *   If the chosen file separates the ConfigMap, ensure you generate both the ConfigMap and the Deployment/Service YAMLs.
    *   Save the final, combined Deployment and Service YAML to `k8s/deployments/loki.yaml`.
4.  **Provide Deployment Command:** Give me the `kubectl apply -f k8s/deployments/loki.yaml` command.
5.  **Provide Verification Steps:** Suggest commands to verify that Loki is running correctly, such as `kubectl get pods -n shopmicro -l app=loki`.
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md`.
7.  **Explain Configuration:** Briefly explain the role of Loki's configuration schema (`schema_config`) and the `common` storage settings in your generated YAML.