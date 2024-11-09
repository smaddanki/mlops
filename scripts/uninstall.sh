#!/bin/bash

echo "Deleting k3d cluster..."
k3d cluster delete k3d-cluster

# echo "Removing local DNS entries..."
# sudo sed -i '/traefik.localhost/d' /etc/hosts
# sudo sed -i '/postgres.localhost/d' /etc/hosts

echo "Cleanup complete!"