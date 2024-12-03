Let's check why the ClickHouse pods aren't being created. First, let's verify the operator installation and check for any issues:

1. Check if the ClickHouse operator is installed:
```bash
# Check operator pods
kubectl get pods -n kube-system -l app=clickhouse-operator

# Check CRDs
kubectl get crds | grep clickhouse
```

2. Check if the ClickHouseInstallation (chi) was created:
```bash
# Check CHI status
kubectl get chi -n database

# Check events in the namespace
kubectl get events -n database
```

3. Let's look at the operator logs:
```bash
# Get operator logs
kubectl logs -n kube-system -l app=clickhouse-operator
```

4. Verify our ClickHouse configuration:
```bash
# Describe the CHI
kubectl describe chi clickhouse -n database
```

The output from these commands will help us identify why the ClickHouse pods aren't being created. 

Also, let's try to install the operator again in the correct namespace:
```bash
# Delete existing operator if any
kubectl delete -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml

# Install operator in the database namespace
kubectl apply -n database -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml
```

