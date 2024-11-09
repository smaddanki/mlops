# Local Kubernetes Development Cluster

This project sets up a local Kubernetes development environment using k3d, Traefik, and PostgreSQL.

## Prerequisites
- Docker
- kubectl
- helm
- k3d

## Quick Start
```bash
# Create the cluster and install components
./scripts/install.sh

# To delete everything
./scripts/uninstall.sh
```

## Components
- K3d cluster with 1 server and 2 agents
- Traefik as ingress controller
- PostgreSQL database
- Traefik Dashboard: http://traefik.localhost
- PostgreSQL: postgres.localhost:5432

## Connection Details
PostgreSQL:
- Host: postgres.localhost
- Port: 5432
- Database: pgdatabase
- Username: pguser
- Password: pgpass123

