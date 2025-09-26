---
mode: ask
---
# Task: Initialize Minikube Cluster and Project Namespace

## Objective
To start the Minikube cluster with the correct resource allocation and enable necessary addons, then create the `shopmicro` namespace.

## Detailed Instructions for Copilot
1.  Refer to `KUBERNETES_BOOTCAMP_LAB.md`, specifically "Step 1: Start Minikube Cluster".
2.  Provide the exact `minikube start` command, ensuring it includes `--memory=6144`, `--cpus=4`, and `--disk-size=20g`.
3.  List the `minikube addons enable` commands for `ingress` and `metrics-server`.
4.  Provide the `kubectl` command to verify the cluster is running (e.g., `kubectl cluster-info`).
5.  Next, refer to `KUBERNETES_BOOTCAMP_LAB.md`, "Step 2.1: Create Namespace".
6.  Generate the YAML for the `shopmicro` namespace. The file should be named `k8s/namespace.yaml`. Ensure it includes the metadata with labels `name: shopmicro`.
7.  Provide the `kubectl apply` command for this namespace file.
8.  Suggest an entry for `work-log/daily-progress.md` summarizing these steps.
9.  After providing all commands and YAML, ask me to execute them one by one and confirm success before proceeding to the next prompt.