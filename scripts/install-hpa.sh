#!/bin/bash
set -e
echo $(pwd)

# Create directories
mkdir -p ~/k3d/data/zookeeper/data
mkdir -p ~/k3d/data/zookeeper/datalog
mkdir -p ~/k3d/data/kafka


echo "Creating k3d cluster..."
k3d cluster create --config infrastructure/cluster/k3d-cluster-config.yaml --agents-memory 8G

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

echo "Installing Zookeeper..."

kubectl apply -f infrastructure/database/clickhouse-hpa/zookeeper.yaml
kubectl wait --for=condition=ready pod/zookeeper-0 -n database --timeout=120s

# Wait for ZooKeeper to be ready
kubectl wait --for=condition=ready pod -l app=zookeeper -n database

echo "Creating Clickhouse Operator..."
kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml
echo "Creating Clickhouse Instance and Persistance Volume claims..."
kubectl apply -f infrastructure/database/clickhouse-hpa/clickhouse-instance.yaml 
echo "Creating Clickhouse HPA..."
kubectl apply -f infrastructure/database/clickhouse-hpa/clickhouse-hpa.yaml 
echo "Creating Clickhouse Service..."
kubectl apply -f infrastructure/database/clickhouse-hpa/clickhouse-service.yaml 

echo "Installing Kafka..."

kubectl apply -f infrastructure/database/clickhouse-hpa/kafka.yaml

# echo "Add monitoring to the cluster!"
# kubectl create namespace monitoring
# echo "created namespace monitoring..."
# helm repo update
# # Install kube-prometheus-stack
# helm install monitoring prometheus-community/kube-prometheus-stack \
#   --namespace monitoring \
#   --set prometheus.service.type=NodePort \
#   --set prometheus.service.nodePort=30090 \
#   --set grafana.service.type=NodePort \
#   --set grafana.service.nodePort=30091

