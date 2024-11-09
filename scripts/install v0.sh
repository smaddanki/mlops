#!/bin/bash
set -e

echo "Creating k3d cluster..."
k3d cluster create --config cluster/k3d-config.yaml

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
kubectl wait --for=condition=Ready -n kube-system pods --all --timeout=120s

echo "Adding helm repositories..."
# helm repo add traefik https://traefik.github.io/charts || helm repo update traefik
# helm repo add bitnami https://charts.bitnami.com/bitnami || helm repo update bitnami
helm repo update

echo "Creating namespaces..."
kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace postgres --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Traefik..."
helm install traefik traefik/traefik \
  -f infrastructure/traefik/values.yaml \
  -n traefik

echo "Waiting for Traefik to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=traefik -n traefik --timeout=90s

kubectl apply -f infrastructure/traefik/dashboard.yaml

echo "Installing PostgreSQL..."
helm install postgres bitnami/postgresql \
  -f infrastructure/postgres/values.yaml \
  -n postgres

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=postgres -n postgres --timeout=90s

echo "Creating PostgreSQL Ingress Route..."
kubectl apply -f infrastructure/postgres/ingress.yaml

echo "Adding local DNS entries..."
sudo sed -i '/traefik.localhost/d' /etc/hosts
sudo sed -i '/postgres.localhost/d' /etc/hosts
echo "127.0.0.1 traefik.localhost postgres.localhost" | sudo tee -a /etc/hosts

echo "Installation complete!"
echo "Traefik Dashboard: http://traefik.localhost"
echo "PostgreSQL: localhost:5432"
echo "PostgreSQL Credentials:"
echo "  Username: pguser"
echo "  Password: pgpass123"
echo "  Database: pgdatabase"

# Verify the installation
echo "Verifying services..."
echo "Traefik pods:"
kubectl get pods -n traefik
echo
echo "PostgreSQL pods:"
kubectl get pods -n postgres
echo
echo "TCP Routes:"
kubectl get ingressroutetcp -A

# Test PostgreSQL connection
echo "Testing PostgreSQL connection..."
PGPASSWORD=pgpass123 pg_isready -h localhost -p 5432 -U pguser
if [ $? -eq 0 ]; then
    echo "PostgreSQL is ready!"
else
    echo "PostgreSQL connection failed!"
fi