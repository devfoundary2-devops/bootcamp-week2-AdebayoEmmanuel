---
mode: ask
---
# Task: Build and Load Application Docker Images into Minikube

## Objective
To build the Docker images for the backend, frontend, and ml-service, and then load them into the Minikube cluster so they can be used by the Kubernetes deployments.

## Detailed Instructions for Copilot
1.  **Refer to Instructions:** Your primary reference is `KUBERNETES_BOOTCAMP_LAB.md`, specifically "Step 5: Build and Load Images".
2.  **List Docker Build Commands:** Provide the complete `docker build` commands for each of the three services.
    *   For the backend service, the image tag should be `shopmicro-backend:latest`. Remind me that this command needs to be executed from the `./backend` directory.
    *   For the frontend service, the image tag should be `shopmicro-frontend:latest`. Remind me that this command needs to be executed from the `./frontend` directory.
    *   For the ml-service, the image tag should be `shopmicro-ml-service:latest`. Remind me that this command needs to be executed from the `./ml-service` directory.
3.  **List Minikube Load Commands:** After the images are built, provide the complete `minikube image load` commands for each of the three newly built images (`shopmicro-backend:latest`, `shopmicro-frontend:latest`, `shopmicro-ml-service:latest`).
4.  **Suggest Verification:** Suggest how I can verify that the images have been successfully loaded into Minikube (e.g., `minikube image ls | grep shopmicro`).
5.  **Suggest Logging:** Remind me to update `work-log/daily-progress.md` with a summary of this task, listing all the `docker build` and `minikube image load` commands that were executed.
6.  **Explain Process:** Briefly explain why it's necessary to load images into Minikube in this way, rather than relying on a standard image pull from a registry.