#!/bin/bash
set -e

echo "Uninstalling Airflow..."
helm uninstall airflow -n airflow

echo "Deleting Airflow namespace..."
kubectl delete namespace airflow

echo "Cleaning up Airflow database..."
kubectl exec -n postgres postgres-postgresql-0 -- psql -U pguser -d pgdatabase -c "DROP DATABASE IF EXISTS airflow;"

echo "Removing Airflow from hosts file..."
if [ -w "/etc/hosts" ]; then
    sed -i '/airflow.localhost/d' /etc/hosts
else
    sudo sed -i '/airflow.localhost/d' /etc/hosts
fi

echo "Airflow uninstallation complete!"