# K3d Cluster Setup and Management Guide

## Prerequisites
- Docker installed and running
- kubectl CLI tool installed
- k3d installed (`brew install k3d` on macOS or `wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash` on Linux)

## Basic Cluster Operations

### Create a Simple Cluster
```bash
# Create a basic single-node cluster
k3d cluster create mycluster

# Create a cluster with 3 server nodes and 2 agent nodes
k3d cluster create mycluster --servers 3 --agents 2

# Create a cluster with specific port mapping
k3d cluster create mycluster -p "8080:80@loadbalancer"
```

### Manage Clusters
```bash
# List all clusters
k3d cluster list

# Stop a cluster
k3d cluster stop mycluster

# Start a cluster
k3d cluster start mycluster

# Delete a cluster
k3d cluster delete mycluster
```

## Advanced Configuration

### Using a Configuration File
```yaml
# k3d-config.yaml
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: mycluster
servers: 1
agents: 2
kubeAPI:
  host: "k3d-mycluster"
  hostIP: "127.0.0.1"
  hostPort: "6443"
ports:
  - port: 8080:80
    nodeFilters:
      - loadbalancer
volumes:
  - volume: /path/on/host:/path/in/node
    nodeFilters:
      - all
```

Apply the configuration:
```bash
k3d cluster create --config k3d-config.yaml
```

### Registry Setup
```bash
# Create a local registry
k3d registry create myregistry.localhost --port 5000

# Create a cluster with registry
k3d cluster create mycluster --registry-use k3d-myregistry.localhost:5000
```

## Working with Applications

### Deploy a Sample Application
```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Verify deployment
kubectl get pods,svc
```

## Common Operations

### Access the Cluster
```bash
# Get kubeconfig
k3d kubeconfig get mycluster > ~/.kube/config

# Merge with existing kubeconfig
k3d kubeconfig merge mycluster --kubeconfig-switch-context
```

### Scale Nodes
```bash
# Add agent nodes
k3d node create myagent --cluster mycluster --role agent

# Add server node
k3d node create myserver --cluster mycluster --role server
```

## Troubleshooting

### Common Issues and Solutions

1. **Cluster Creation Fails**
   - Ensure Docker is running
   - Check for port conflicts
   - Verify sufficient system resources

2. **Unable to Access Applications**
   - Verify port mappings
   - Check LoadBalancer configuration
   - Ensure correct kubeconfig is being used

3. **Registry Issues**
   - Verify registry is running (`docker ps`)
   - Check registry port availability
   - Ensure proper registry configuration in cluster

### Debug Commands
```bash
# Get cluster info
kubectl cluster-info

# Check node status
kubectl get nodes -o wide

# View cluster events
kubectl get events --sort-by='.metadata.creationTimestamp'

# Check k3d logs
k3d cluster list
k3d node list
docker logs k3d-mycluster-server-0
```

## Best Practices

1. **Resource Management**
   - Set resource limits for containers
   - Monitor node resource usage
   - Use node labels for workload distribution

2. **Networking**
   - Use meaningful port mappings
   - Configure network policies
   - Implement proper ingress rules

3. **Storage**
   - Use persistent volumes for stateful applications
   - Implement proper backup strategies
   - Monitor storage usage

4. **Security**
   - Enable network policies
   - Use RBAC for access control
   - Regularly update images and components

## Clean Up
```bash
# Delete specific cluster
k3d cluster delete mycluster

# Delete all clusters
k3d cluster delete --all

# Remove registry
k3d registry delete myregistry.localhost
```