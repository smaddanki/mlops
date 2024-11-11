#!/bin/bash
set -e

# ... (previous installations) ...

echo "Adding MinIO helm repository..."
helm repo add minio https://charts.min.io/ || helm repo update minio
helm repo update

echo "Creating MinIO namespace..."
kubectl create namespace minio --dry-run=client -o yaml | kubectl apply -f -

echo "Installing MinIO..."
helm install minio minio/minio \
  -f infrastructure/minio/values.yaml \
  -n minio

echo "Waiting for MinIO to be ready..."
kubectl wait --for=condition=ready pod -l app=minio -n minio --timeout=180s

echo "Creating MinIO Ingress Routes..."
kubectl apply -f infrastructure/minio/ingress.yaml

# # Update hosts file
# echo "Updating /etc/hosts file..."
# if [ -w "/etc/hosts" ]; then
#     sed -i '/minio.localhost/d' /etc/hosts
#     echo "127.0.0.1 minio.localhost" >> /etc/hosts
# else
#     echo "Need sudo access to update /etc/hosts"
#     sudo bash -c 'sed -i "/minio.localhost/d" /etc/hosts && \
#                   echo "127.0.0.1 minio.localhost" >> /etc/hosts'
# fi

# Create initial buckets using MinIO Client (mc)
echo "Setting up MinIO buckets..."
kubectl run minio-client --image=minio/mc --namespace minio --command -- /bin/sh -c "\
  mc alias set myminio http://minio:9000 minioadmin minioadmin && \
  mc mb -p myminio/airflow && \
  mc mb -p myminio/data"

echo "MinIO installation complete!"
echo "MinIO Console: http://minio.localhost"
echo "MinIO API: http://minio.localhost/api"
echo "Username: minioadmin"
echo "Password: minioadmin"

# Verify MinIO installation
echo "Verifying MinIO services..."
kubectl get pods,svc -n minio