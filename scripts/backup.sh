#!/bin/bash
# scripts/backup.sh

BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "Creating backup in $BACKUP_DIR"

# Backup Docker volumes
docker run --rm -v /opt/docker:/backup alpine tar czf /backup/docker-data.tar.gz /backup

# Backup Grafana data
docker run --rm -v grafana_data:/data -v $BACKUP_DIR:/backup alpine cp -r /data /backup/grafana

# Backup Prometheus data
docker run --rm -v prometheus_data:/data -v $BACKUP_DIR:/backup alpine cp -r /data /backup/prometheus

echo "Backup completed: $BACKUP_DIR"