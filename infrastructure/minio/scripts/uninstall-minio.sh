#!/bin/bash
set -e

echo "Uninstalling MinIO..."
helm uninstall minio -n minio

echo "Deleting MinIO namespace..."
kubectl delete namespace minio

echo "Cleaning up MinIO persistent volumes..."
kubectl delete pvc --all -n minio

echo "Removing MinIO from hosts file..."
if [ -w "/etc/hosts" ]; then
    sed -i '/minio.localhost/d' /etc/hosts
else
    sudo sed -i '/minio.localhost/d' /etc/hosts
fi

echo "MinIO uninstallation complete!"