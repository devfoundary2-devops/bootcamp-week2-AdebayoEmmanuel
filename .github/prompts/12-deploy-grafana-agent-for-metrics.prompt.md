---
mode: ask
---
# Task: Deploy Grafana Agent (Alloy) for Metrics Collection

## Objective
To deploy Grafana Agent (Alloy) to discover application pods in the `shopmicro` namespace, scrape their Prometheus metrics endpoints, and forward these metrics to our Mimir instance.

## Detailed Instructions for Copilot
1.  **Gather Context:**
    *   Examine the `infrastructure/alloy/` directory. You will find `config.alloy` and `config-official.alloy`.
    *   Understand that Alloy is a configuration language for Grafana Agent, defining components for discovery, scraping, and remote writing.
2.  **Analyze and Select Alloy Config:**
    *   Analyze `config.alloy` and `config-official.alloy`.
    *   Select `config.alloy` as a starting point, assuming `config-official.alloy` is overly complex for this lab. Justify this choice.
3.  **Adapt Alloy Configuration:**
    *   **Discovery:** The Alloy config needs a `discovery.kubernetes` component. Guide me to modify or ensure the config includes a block like:
        ```alloy
        discovery.kubernetes "pods" {
          role = "pod"
          namespace = "shopmicro"
        }
        ```
    *   **Scraping:** The config needs a `prometheus.scrape` component. Guide me to modify or ensure it discovers pods based on common labels used in our deployments (e.g., `app.kubernetes.io/name`). It should look for a port named `http` or a specific metrics port if defined.
        ```alloy
        prometheus.scrape "default" {
          targets    = discovery.kubernetes.pods.targets
          forward_to = [prometheus.remote_write.mimir.receiver]
        }
        ```
    *   **Remote Write:** The config needs a `prometheus.remote_write` component pointing to Mimir.
        ```alloy
        prometheus.remote_write "mimir" {
          endpoint {
            url = "http://mimir:9009/api/v1/write" // Mimir's remote write URL
          }
        }
        ```
    *   Provide the complete, modified Alloy configuration content.
4.  **Generate Kubernetes Manifests for Grafana Agent:**
    *   **ConfigMap:** Create `k8s/configmaps/alloy-config.yml` containing the modified Alloy configuration.
    *   **Deployment (`k8s/deployments/grafana-agent.yaml`):**
        *   Use the `grafana/agent` image (e.g., `grafana/agent:static-0.36.0` or `latest`).
        *   Mount the `alloy-config.yml` ConfigMap into the pod (e.g., at `/etc/agent/config.alloy`).
        *   Command to run: `/bin/grafana-agent --server.http.listen-port=0 --config.file=/etc/agent/config.alloy`.
        *   **RBAC:** The agent needs permissions to discover pods. Generate YAML for `k8s/rbac/grafana-agent-rbac.yml` including a `ServiceAccount`, a `Role` (with permissions like `get`, `list`, `watch` on `pods` in the `shopmicro` namespace), and a `RoleBinding`.
        *   The deployment must specify `serviceAccountName: grafana-agent`.
5.  **Provide Deployment Commands:** List all `kubectl apply` commands for the ConfigMap, RBAC, and Grafana Agent deployment.
6.  **Provide Verification Steps:**
    *   Check Grafana Agent logs: `kubectl logs -n shopmicro deployment/grafana-agent`. Look for successful discovery of targets and remote write operations.
    *   In Grafana, go to Explore -> Mimir datasource. Query for metrics like `{__name__=~".+"}` or specific application metrics (e.g., `http_requests_total{app="backend"}`) to confirm they are being received.
7.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md`.
8.  **Explain Agent Role:** Briefly explain how Grafana Agent acts as a bridge, performing service discovery and metric scraping before sending data to Mimir, offloading this work from Mimir itself.