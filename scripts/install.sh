#!/bin/bash
set -e
echo $(pwd)
echo "Creating k3d cluster..."
k3d cluster create --config infrastructure/cluster/k3d-cluster-config.yaml

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
kubectl wait --for=condition=Ready -n kube-system pods --all --timeout=120s

echo "Cluster Installation done..."

# Reapply configurations
kubectl create namespace storage
echo "created namespace Storage..."
kubectl create namespace database
echo "created namespace database..."

# Apply MinIO configs (your existing MinIO configs)
echo "Installing Minio..."
kubectl apply -f infrastructure/storage/minio/minio-shared-deployment.yaml
# kubectl apply -f minio-deployment.yaml
# kubectl apply -f minio-service.yaml

echo "Waiting for Minio to be ready..."
# kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=minio -n storage --timeout=90s

echo "Creating Clickhouse Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml
kubectl apply -f infrastructure/database/clickhouse/clickhouse-instance.yaml 
kubectl apply -f infrastructure/database/clickhouse/clickhouse-service.yaml 

echo "Installation complete!"
echo "Traefik Dashboard: http://traefik.localhost"
echo "PostgreSQL: localhost:5432"
echo "PostgreSQL Credentials:"
echo "  Username: pguser"
echo "  Password: pgpass123"
echo "  Database: pgdatabase"

