#!/bin/bash

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo:"
    echo "sudo $0"
    exit 1
fi

# Update hosts file
sed -i '/traefik.localhost/d' /etc/hosts
sed -i '/postgres.localhost/d' /etc/hosts
echo "127.0.0.1 traefik.localhost postgres.localhost" >> /etc/hosts

echo "Hosts file updated successfully!"