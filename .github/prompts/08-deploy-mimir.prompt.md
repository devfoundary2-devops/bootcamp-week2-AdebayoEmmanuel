---
mode: ask
---
# Task: Deploy Mimir for Metrics Storage (Production-Ready Configuration)

## Objective
To deploy a robust, production-ready Mimir instance within the `shopmicro` namespace, starting from official documentation and adapting it for our Minikube lab. This ensures we learn best practices.

## Detailed Instructions for Copilot
1.  **Gather Context:**
    *   Read `KUBERNETES_BOOTCAMP_LAB.md`, "Step 3.1: Mimir (Metrics Storage)" for foundational requirements (filesystem storage, port 9009).
    *   Examine all files in `infrastructure/mimir/`, paying close attention to `mimir-official.yaml`.
2.  **Analyze and Select Configuration:**
    *   Prioritize analyzing `mimir-official.yaml`. Recognize that this file likely represents a more complete, production-oriented setup, possibly with multiple components (distributor, ingester, store-gateway, etc.) defined.
    *   Your task is to **adapt** this official configuration for a single-node Minikube environment. This might involve:
        *   Scaling down deployments from multiple replicas to 1 where appropriate for a lab.
        *   Ensuring all components still communicate correctly within the single node.
        *   Verifying that the filesystem storage paths are suitable for Minikube's `emptyDir` or a simple `hostPath` PV.
    *   Justify your choice by stating: "I will adapt `mimir-official.yaml` as it provides a production-grade structure. I will scale it down for a single-node Minikube environment while preserving its robust configuration."
3.  **Generate Kubernetes Manifests:**
    *   Based on your **adapted** configuration, generate the complete set of Kubernetes YAMLs (ConfigMaps, Deployments, Services, etc.) required for Mimir.
    *   Ensure all components are correctly labeled and reside in the `shopmicro` namespace.
    *   The main Mimir service should remain accessible on port `9009`.
    *   Save the generated YAMLs to `k8s/deployments/mimir.yaml` (or multiple files if necessary, e.g., `k8s/configmaps/mimir-config.yaml` and `k8s/deployments/mimir.yaml`).
4.  **Provide Deployment Command:** Give me the `kubectl apply -f` command(s).
5.  **Provide Verification Steps:** Suggest commands to verify the deployment (`kubectl get pods -n shopmicro -l app.kubernetes.io/name=mimir`) and check the logs of each Mimir component for a healthy start. Remind me to port-forward to access the Mimir API.
6.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md`.
7.  **Explain Configuration:** Briefly explain the key components of the *adapted* official Mimir deployment (e.g., the roles of the distributor, ingester, and store-gateway, even if scaled to one replica each). This demonstrates understanding of a production architecture.