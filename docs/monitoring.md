1. First, let's create a monitoring namespace:
```bash
kubectl create namespace monitoring
```

2. Add the Prometheus Helm repository:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```yaml
# monitoring-values.yaml
grafana:
  persistence:
    enabled: true
    storageClassName: local-path
    size: 10Gi
    accessModes:
      - ReadWriteOnce
  service:
    type: LoadBalancer
    port: 3000

prometheus:
  prometheusSpec:
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

alertmanager:
  enabled: true
  persistence:
    enabled: true
    storageClassName: local-path
    size: 5Gi

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true

```

3. Install the Prometheus stack with our custom values:
```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f monitoring-values.yaml
```

4. Verify the installation:
```bash
# Check all pods are running
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring
```

5. Get access credentials:
```bash
# Get Grafana admin password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
```

You can now access:
- Grafana: http://localhost:30000 (username: admin, password: from the command above)
- Prometheus: http://localhost:30090

Useful commands for monitoring:

```bash
# Get all monitoring resources
kubectl get all -n monitoring

# Get Prometheus rules
kubectl get prometheusrules -n monitoring

# Get service monitors
kubectl get servicemonitors -n monitoring

# Check Grafana logs
kubectl logs -f -l app.kubernetes.io/name=grafana -n monitoring

# Check Prometheus logs
kubectl logs -f -l app=prometheus -n monitoring
```

Some default Grafana dashboards that will be available:
1. Kubernetes Cluster Overview
2. Node Exporter
3. Kubernetes Resources
4. Kubernetes Nodes

Would you like me to:
1. Show you how to create custom dashboards?
2. Set up alerts?
3. Add more specific monitoring for certain workloads?
4. Set up additional exporters for specific metrics?