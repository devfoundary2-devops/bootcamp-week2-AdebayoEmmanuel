---
mode: ask
---
# Task: Deploy Tempo and Instrument Applications for Distributed Tracing

## Objective
To deploy Tempo for distributed tracing and to instrument the backend, frontend, and ml-service with OpenTelemetry to send traces to this Tempo instance.

## Detailed Instructions for Copilot
1.  **Tempo Deployment:**
    *   Examine `infrastructure/tempo/` directory: `tempo.yaml`, `tempo-simple.yaml`, `tempo-official.yaml`.
    *   Analyze and select the most suitable Tempo YAML for this lab (likely `tempo-simple.yaml`). Justify your choice.
    *   Adapt it for the `shopmicro` namespace. The service should be named `tempo`.
    *   Ensure it's configured to accept OTLP traces (typically on port 3200 for HTTP or 4317 for gRPC). The `KUBERNETES_BOOTCAMP_LAB.md` doesn't specify Tempo, so infer standard ports and configurations.
    *   Save the final YAML to `k8s/deployments/tempo.yaml`.
    *   Provide the `kubectl apply` command.
    *   Suggest verification: `kubectl get pods -n shopmicro -l app=tempo`.
2.  **Application Instrumentation (OpenTelemetry):**
    *   **General Principle:** Explain that we will use OpenTelemetry. Each service needs to be configured to export traces to `http://tempo:3200/v1/traces` (OTLP HTTP) or `grpc://tempo:4317` (OTLP gRPC). Each service needs a unique `OTEL_SERVICE_NAME`.
    *   **Backend (Node.js):**
        *   Examine `backend/Dockerfile` and `backend/package.json`.
        *   **Action:** Guide me to modify `backend/Dockerfile` to install and configure the OpenTelemetry Node.js agent. This usually involves setting `NODE_OPTIONS` to `-r @opentelemetry/auto-instrumentations-node` and providing environment variables like `OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo:3200/v1/traces` and `OTEL_SERVICE_NAME=shopmicro-backend`.
        *   **Action:** Guide me to update `k8s/deployments/backend.yaml` to include these OTEL environment variables.
    *   **Frontend (React/JavaScript):**
        *   Examine `frontend/src/` structure, particularly `App.js` and any API service files like `frontend/src/services/api.js`.
        *   **Action:** Guide me to install necessary OpenTelemetry browser packages (`@opentelemetry/api`, `@opentelemetry/sdk-trace-web`, `@opentelemetry/instrumentation-fetch`).
        *   **Action:** Guide me to add OTEL initialization code to `frontend/src/index.js` or a new file `frontend/src/telemetry.js`. This code should configure a tracer and instrument `fetch` calls to inject trace context into headers sent to the backend.
        *   **Action:** No changes to `k8s/deployments/frontend.yaml` are needed for OTEL itself, as this is client-side code.
    *   **ML Service (Python):**
        *   Examine `ml-service/Dockerfile`, `ml-service/app.py`, and `ml-service/requirements.txt`.
        *   **Action:** Guide me to add `opentelemetry-distro`, `opentelemetry-instrumentation-flask` (or `fastapi`, etc., based on `app.py`), and `opentelemetry-exporter-otlp-proto-http` to `ml-service/requirements.txt`.
        *   **Action:** Guide me to modify `ml-service/app.py` to initialize OpenTelemetry, preferably via environment variables for auto-instrumentation: `OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo:3200/v1/traces`, `OTEL_SERVICE_NAME=shopmicro-ml-service`, `OTEL_PYTHON_AUTO_INSTRUMENTATION_ENABLED=true`.
        *   **Action:** Guide me to update `k8s/deployments/ml-service.yaml` to include these OTEL environment variables.
3.  **Provide Commands for Re-deployment:** After I've made the code changes, remind me to rebuild and re-load the application images (`docker build`, `minikube image load`) and then re-apply their deployment YAMLs.
4.  **Provide Verification Steps:**
    *   After re-deploying applications, suggest generating some traffic (e.g., by browsing the frontend).
    *   Instruct me to go to Grafana -> Explore -> Tempo (or the Traces section if using a newer Grafana version) to search for traces.
5.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` and `work-log/troubleshooting-notes.md` for any instrumentation challenges.
6.  **Explain Tracing:** Briefly explain the concept of distributed tracing and trace context propagation.