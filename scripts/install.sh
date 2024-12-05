#!/bin/bash
set -e
echo $(pwd)

# Create directories
mkdir -p ~/k3d/data/zookeeper/data
mkdir -p ~/k3d/data/zookeeper/datalog
mkdir -p ~/k3d/data/kafka


echo "Creating k3d cluster..."
k3d cluster create --config infrastructure/cluster/k3d-config.yaml

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
kubectl wait --for=condition=Ready -n kube-system pods --all --timeout=120s

echo "Cluster Installation done..."

# echo "Adding helm repositories..."
# helm repo add traefik https://traefik.github.io/charts || helm repo update traefik
# helm repo add bitnami https://charts.bitnami.com/bitnami || helm repo update bitnami
helm repo update

# echo "Creating namespaces..."
# kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -

# echo "Installing Traefik..."
# helm install traefik traefik/traefik \
#   -f infrastructure/traefik/values.yaml \
#   -n traefik

# echo "Waiting for Traefik to be ready..."
# kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=traefik -n traefik --timeout=90s

# echo "Creating Traefik Dashboard..."
# kubectl apply -f infrastructure/traefik/dashboard.yaml
# Reapply configurations
kubectl create namespace storage
echo "created namespace Storage..."
kubectl create namespace database
echo "created namespace database..."

echo "Installing Zookeeper..."

kubectl apply -f infrastructure/database/clickhouse-hpa/zookeeper.yaml
kubectl wait --for=condition=ready pod/zookeeper-0 -n database --timeout=120s

# # Apply MinIO configs (your existing MinIO configs)
# echo "Installing Minio..."
# kubectl apply -f infrastructure/storage/minio/minio-shared-deployment.yaml
# # kubectl apply -f minio-deployment.yaml
# # kubectl apply -f minio-service.yaml

# echo "Waiting for Minio to be ready..."
# # kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=minio -n storage --timeout=90s

# echo "Creating Clickhouse Dashboard..."
# kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml
# kubectl apply -f infrastructure/database/clickhouse/clickhouse-instance.yaml 
# kubectl apply -f infrastructure/database/clickhouse/clickhouse-service.yaml 

# echo "Installation complete!"
# echo "Traefik Dashboard: http://traefik.localhost"
# echo "PostgreSQL: localhost:5432"
# echo "PostgreSQL Credentials:"
# echo "  Username: pguser"
# echo "  Password: pgpass123"
# echo "  Database: pgdatabase"

