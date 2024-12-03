# Check if ClickHouse is actually running and storing data.

1. Check the pods and their volumes:
```bash
# Get the pod name
kubectl get pods -n database

# Describe the pod to check volume mounts
kubectl describe pod -n database $(kubectl get pods -n database -l clickhouse.altinity.com/app=chop -o jsonpath='{.items[0].metadata.name}')
```

2. Let's try creating some test data in ClickHouse:
```bash
# Connect to ClickHouse via curl and create a test table
curl "http://localhost:30123/?user=default&password=clickhouse" -d "CREATE TABLE test (id UInt32, name String) ENGINE = MergeTree() ORDER BY id"

# Insert some test data
curl "http://localhost:30123/?user=default&password=clickhouse" -d "INSERT INTO test VALUES (1, 'Test')"
```

3. Check where the data is actually being stored:
```bash
# Get into the pod
kubectl exec -it -n database $(kubectl get pods -n database -l clickhouse.altinity.com/app=chop -o jsonpath='{.items[0].metadata.name}') -- bash

# Inside the pod, check the actual data location
ls -la /var/lib/clickhouse
```

4. Let's also check the node:
```bash
# Get into the k3d node
docker exec -it k3d-k3d-cluster-agent-0 sh

# Check if the mount exists and has data
ls -la /mnt/clickhouse
```

# verify the database connection and create a test table step by step.

1. First, let's check if ClickHouse is responding:
```bash
curl "http://localhost:30123/ping"
```

2. List all databases to make sure we can connect:
```bash
curl "http://localhost:30123/?user=default&password=clickhouse&query=SHOW%20DATABASES"
```

3. Let's create a test table with proper SQL formatting:
```bash
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=CREATE TABLE default.test (
    id UInt32,
    name String
) ENGINE = MergeTree()
ORDER BY id"
```

4. Insert some test data:
```bash
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=INSERT INTO default.test VALUES (1, 'Test')"
```

5. Verify the table was created and data was inserted:
```bash
# List tables
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=SHOW TABLES FROM default"

# Query data
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=SELECT * FROM default.test"
```

Also, can you try connecting through DBeaver again with these settings:
```
Host: localhost
Port: 30123
Database: default
Username: default
Password: clickhouse
URL Template: jdbc:clickhouse:http://{host}:{port}/{database}
```

# Confirm the data gets committed. In ClickHouse, we should use ATOMIC database engine for better data persistence.

1. First, let's modify our default database to use ATOMIC engine:
```bash
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=CREATE DATABASE IF NOT EXISTS default ENGINE = Atomic"
```

2. Create a test table with ATOMIC engine:
```bash
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=CREATE TABLE default.test (
    id UInt32,
    name String
) ENGINE = MergeTree()
ORDER BY id
SETTINGS storage_policy = 'default'"
```

3. Insert and COMMIT data:
```bash
# Start transaction
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=START TRANSACTION"

# Insert data
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=INSERT INTO default.test VALUES (1, 'Test')"

# Commit transaction
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=COMMIT"
```

4. Verify data persistence:
```bash
# Query data
curl "http://localhost:30123/?user=default&password=clickhouse" \
--data-urlencode "query=SELECT * FROM default.test"
```

5. Let's also verify the storage configuration in our ClickHouse pod:
```bash
# Check the pod's storage configuration
kubectl exec -it -n database $(kubectl get pods -n database -l clickhouse.altinity.com/app=chop -o jsonpath='{.items[0].metadata.name}') -- \
clickhouse-client --user default --password clickhouse --query "SELECT * FROM system.storage_policies"
```
