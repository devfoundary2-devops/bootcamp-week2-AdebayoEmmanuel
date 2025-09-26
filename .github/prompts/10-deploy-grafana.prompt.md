---
mode: ask
---
# Task: Deploy Grafana and Configure Datasources & Dashboards

## Objective
To deploy Grafana and use its provisioning feature to automatically configure datasources for Mimir, Loki, and Tempo, and to load pre-configured dashboards.

## Detailed Instructions for Copilot
1.  **Gather Context:**
    *   Examine the `infrastructure/grafana/` directory thoroughly. Pay close attention to:
        *   `infrastructure/grafana/provisioning/datasources/prometheus.yml` (as a template).
        *   `infrastructure/grafana/provisioning/dashboards/dashboards.yml`.
        *   The `infrastructure/grafana/dashboards/` directory containing JSON dashboard files.
        *   `infrastructure/grafana/grafana.ini` for any specific Grafana settings.
    *   Look for a Grafana deployment YAML in `infrastructure/kubernetes/grafana.yaml`. If it's not suitable or doesn't exist, be prepared to generate one.
2.  **Generate Datasource ConfigMaps:**
    *   **Mimir Datasource:** Create a new YAML content for a ConfigMap named `grafana-datasources-mimir`. It should define a datasource of type `prometheus` (or `mimir` if Grafana supports it natively as a type, pointing to `http://mimir:9009/api/prom` or similar, with `access: proxy`. The name should be `Mimir`.
    *   **Loki Datasource:** Create YAML content for a ConfigMap named `grafana-datasources-loki`. It should define a datasource of type `loki`, URL `http://loki:3100`, `access: proxy`. Name it `Loki`.
    *   **Tempo Datasource:** Create YAML content for a ConfigMap named `grafana-datasources-tempo`. It should define a datasource of type `tempo`, URL `http://tempo:3200` (assuming Tempo's default query port), `access: proxy`. Name it `Tempo`.
    *   Combine these into a single `k8s/configmaps/grafana-datasources.yml` file, structured for Grafana provisioning.
3.  **Generate Dashboard ConfigMaps:**
    *   The `infrastructure/grafana/provisioning/dashboards/dashboards.yml` likely defines a provider that looks for dashboards in a specific directory.
    *   Guide me on how to create a ConfigMap, say `k8s/configmaps/grafana-dashboards.yml`, that embeds all the JSON files from `infrastructure/grafana/dashboards/`. This ConfigMap should then be mounted into the Grafana pod where the provisioning expects it (e.g., `/etc/grafana/provisioning/dashboards/json-dashboards`).
4.  **Generate Grafana Deployment YAML:**
    *   Create `k8s/deployments/grafana.yaml`.
    *   The deployment should use the `grafana/grafana:latest` image (or a specific version).
    *   It should be named `grafana` in the `shopmicro` namespace, with a service `grafana` exposing port `3000`.
    *   It must volume mount the datasource ConfigMap (`grafana-datasources.yml`) to `/etc/grafana/provisioning/datasources`.
    *   It must volume mount the dashboard ConfigMap (`grafana-dashboards.yml`) to the appropriate directory (e.g., `/etc/grafana/provisioning/dashboards`).
    *   If `infrastructure/grafana/grafana.ini` has non-default settings, create a ConfigMap for it and mount it to `/etc/grafana/grafana.ini`.
5.  **Provide Deployment Commands:** List all `kubectl apply` commands for the generated ConfigMaps and the Grafana deployment.
6.  **Provide Verification Steps:**
    *   Suggest port-forwarding to Grafana: `kubectl port-forward -n shopmicro svc/grafana 3000:3000`.
    *   Instruct me to access Grafana at `http://localhost:3000` (default admin/admin).
    *   Guide me to check Configuration -> Datasources to confirm Mimir, Loki, and Tempo are configured and healthy.
    *   Guide me to check Dashboards -> Manage to see if the dashboards from `infrastructure/grafana/dashboards/` have been loaded.
7.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md`.
8.  **Explain Provisioning:** Briefly explain the benefits of Grafana's provisioning feature for automating configuration in a Kubernetes environment.