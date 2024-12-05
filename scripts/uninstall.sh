#!/bin/bash

# Delete Kubernetes resources
kubectl delete statefulset kafka zookeeper -n database
kubectl delete svc kafka zookeeper -n database

# Clean the persistent volumes
sudo rm -rf ~/k3d/data/kafka/*
sudo rm -rf ~/k3d/data/zookeeper/*


echo "Deleting k3d cluster..."
k3d cluster delete k3d-cluster

# echo "Removing local DNS entries..."
# sudo sed -i '/traefik.localhost/d' /etc/hosts
# sudo sed -i '/postgres.localhost/d' /etc/hosts

echo "Cleanup complete!"