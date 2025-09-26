#!/bin/bash

# This script port-forwards all relevant services in the shopmicro namespace
# based on the actual ports defined in their service manifests.
# Press Ctrl+C to stop all forwarding.

# Function to clean up background jobs on exit
cleanup() {
    echo -e "\nStopping all port-forwarding..."
    # The 'jobs -p' command lists the process IDs of all background jobs.
    # The 'kill' command sends a termination signal to these processes.
    kill $(jobs -p) &>/dev/null
    echo "All forwards stopped."
}

# Trap the SIGINT signal (Ctrl+C) and call the cleanup function
trap cleanup SIGINT

NAMESPACE="shopmicro"

echo "Starting port-forwarding for all services in namespace '$NAMESPACE'..."
echo "Press Ctrl+C to stop."
echo "--------------------------------------------------"
echo "Access URLs:"
echo "  - Grafana:      http://localhost:3000"
echo "  - Shop Frontend:  http://localhost:8080"
echo "--------------------------------------------------"

# --- User-Facing Services ---
# Forward Grafana (svc/grafana -> port 3000)
kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000 &

# Forward Frontend (svc/frontend -> port 3000), mapping to local 8080 to avoid conflict
kubectl port-forward -n $NAMESPACE svc/frontend-service 8080:80 &

# --- Backend APIs ---
# Forward Backend (svc/backend -> port 3001)
kubectl port-forward -n $NAMESPACE svc/backend-service 3001:3001 &

# Forward ML Service (svc/ml-service -> port 3002)
kubectl port-forward -n $NAMESPACE svc/ml-service 3002:3002 &

# --- Observability Backend Services ---
# Forward Mimir (svc/mimir-service -> port 9009)
kubectl port-forward -n $NAMESPACE svc/mimir-service 9009:9009 &

# Forward Loki (svc/loki -> port 3100)
kubectl port-forward -n $NAMESPACE svc/loki 3100:3100 &

# Forward Tempo (svc/tempo -> port 3200)
kubectl port-forward -n $NAMESPACE svc/tempo 3200:3200 &

# --- Datastores ---
# Forward Postgres (svc/postgres-service -> port 5432)
kubectl port-forward -n $NAMESPACE svc/postgres-service 5432:5432 &

# Forward Redis (svc/redis-service -> port 6379)
kubectl port-forward -n $NAMESPACE svc/redis-service 6379:6379 &

echo "All services are being forwarded. Script is running in the background."

# Wait for all background jobs to complete. This keeps the script alive.
wait