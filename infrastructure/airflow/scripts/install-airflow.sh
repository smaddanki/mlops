#!/bin/bash
set -e

# ... (previous cluster and PostgreSQL setup) ...

# echo "Adding Airflow helm repository..."
# helm repo add apache-airflow https://airflow.apache.org || helm repo update apache-airflow
helm repo update

export PGPASSWORD=pgpassword

echo "Creating Airflow database..."


# kubectl exec -n postgres --env PGPASSWORD=pgpassword postgres-postgresql-0 -- psql -U pguser  --password -d pgdatabase -c "CREATE DATABASE airflow;"
# kubectl exec -n postgres --env PGPASSWORD=pgpassword postgres-postgresql-0 -- psql -U pguser -d pgdatabase -c "GRANT ALL PRIVILEGES ON DATABASE airflow TO pguser;"

echo "Creating Airflow namespace..."
kubectl create namespace airflow --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Airflow..."
helm install airflow apache-airflow/airflow \
  -f infrastructure/airflow/values.yaml \
  -n airflow \
  --timeout 10m

echo "Waiting for Airflow to be ready..."
kubectl wait --for=condition=ready pod -l component=webserver -n airflow --timeout=300s

echo "Creating Airflow Ingress Route..."
kubectl apply -f infrastructure/airflow/ingress.yaml

# # Update hosts file
# echo "Updating /etc/hosts file..."
# if [ -w "/etc/hosts" ]; then
#     sed -i '/airflow.localhost/d' /etc/hosts
#     echo "127.0.0.1 airflow.localhost" >> /etc/hosts
# else
#     echo "Need sudo access to update /etc/hosts"
#     sudo bash -c 'sed -i "/airflow.localhost/d" /etc/hosts && \
#                   echo "127.0.0.1 airflow.localhost" >> /etc/hosts'
# fi

echo "Airflow installation complete!"
echo "Airflow UI: http://airflow.localhost"
echo "Username: admin"
echo "Password: admin"

# Verify Airflow installation
echo "Verifying Airflow services..."
kubectl get pods -n airflow