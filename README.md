# Docker Swarm Infrastructure Deployment

This Ansible playbook deploys a production-ready Docker Swarm infrastructure with Traefik, Portainer, Redis, Redis Insight and Grafana monitoring stack (Grafana, Loki, Alloy).

## Prerequisites

1. **Target Server**: Ubuntu 22.04 VPS with root/sudo access
2. **Ansible Control Node**: Ansible 2.9+ installed
3. **SSH Access**: Key-based authentication configured
4. **Domain**: Domain name pointing to your VPS IP

## Quick Start

### 1. Clone and Configure

```bash
git clone <this-repo>
cd docker-swarm-ansible
```

### 2. Update Inventory

Edit `inventory/hosts.yml`:
```yaml
swarm_managers:
  hosts:
    swarm-manager-01:
      ansible_host: YOUR_VPS_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/your_key
```

### 3. Configure Variables

Edit `vars/main.yml`:
```yaml
base_domain: "yourdomain.com"
acme_email: "admin@yourdomain.com"
```

Create `vars/secrets.yml` (encrypt with ansible-vault):
```bash
ansible-vault create vars/secrets.yml
```

### 4. Deploy Infrastructure

```bash
# Test connectivity
ansible all -m ping

# Deploy everything
ansible-playbook site.yml

# Deploy specific components
ansible-playbook site.yml --tags "docker,traefik"
```

### 5. Access Services

After deployment:
- **Traefik Dashboard**: `https://traefik.yourdomain.com`
- **Grafana**: `https://grafana.yourdomain.com`
- **Portainer**: `https://portainer.yourdomain.com`
- **Prometheus**: `https://prometheus.yourdomain.com`
- **Redis**: internal service available on port `6379`
- **Redis Insight**: `https://redis.yourdomain.com`

## Directory Structure

```
.
├── ansible.cfg
├── site.yml
├── inventory/
│   └── hosts.yml
├── vars/
│   ├── main.yml
│   └── secrets.yml
├── roles/
│   ├── base-system/
│   ├── security/
│   ├── docker/
│   ├── docker-swarm/
│   ├── traefik/
│   ├── portainer/
│   ├── monitoring/
│   └── mlops/
│   └── redis/
└── scripts/
    ├── scale-service.sh
    └── backup.sh
```

## Security Features

- **SSH Hardening**: Key-only auth, custom port, fail2ban
- **UFW Firewall**: Minimal open ports
- **Automatic Updates**: Security patches
- **File Integrity**: AIDE monitoring
- **Audit Logging**: System activity tracking
- **Docker Security**: Non-root containers, secrets management

## Scaling to Multi-Node

### Add Worker Nodes

1. Update inventory:
```yaml
swarm_workers:
  hosts:
    swarm-worker-01:
      ansible_host: WORKER_IP
      ansible_user: ubuntu
      node_role: worker
```

2. Deploy to workers:
```bash
ansible-playbook site.yml --limit swarm_workers
```

3. Join workers to swarm:
```bash
# Get join token from manager
docker swarm join-token worker

# On worker nodes
docker swarm join --token <token> <manager-ip>:2377
```

## Maintenance Scripts

### Deploy Script
```bash
#!/bin/bash
# scripts/deploy.sh

set -e

echo "Starting deployment..."

# Test connectivity
ansible all -m ping

# Deploy infrastructure
ansible-playbook site.yml

echo "Deployment completed!"
echo "Access services at:"
echo "- Traefik: https://traefik.yourdomain.com"
echo "- Grafana: https://grafana.yourdomain.com"
echo "- Portainer: https://portainer.yourdomain.com"
```

### Service Scaling Script
```bash
#!/bin/bash
# scripts/scale-service.sh

SERVICE_NAME=$1
REPLICAS=$2

if [ -z "$SERVICE_NAME" ] || [ -z "$REPLICAS" ]; then
    echo "Usage: $0 <service_name> <replicas>"
    exit 1
fi

docker service scale ${SERVICE_NAME}=${REPLICAS}
```

### Backup Script
```bash
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
```

## Troubleshooting

### Common Issues

1. **Services not starting**: Check logs with `docker service logs <service>`
2. **Network issues**: Verify overlay networks with `docker network ls`
3. **SSL certificates**: Check Traefik logs for ACME challenges

### Useful Commands

```bash
# Check swarm status
docker node ls

# View service status
docker service ls

# Check service logs
docker service logs -f <service_name>

# Update a service
docker service update --image new_image:tag <service_name>

# Drain a node for maintenance
docker node update --availability drain <node_name>

# Promote worker to manager
docker node promote <node_name>
```

## Best Practices

1. **Secrets Management**: Use Docker secrets for sensitive data
2. **Resource Limits**: Set memory/CPU limits for services
3. **Health Checks**: Implement health checks for all services
4. **Backup Strategy**: Regular backups of data volumes
5. **Updates**: Regular security updates and image updates
6. **Documentation**: Keep deployment docs updated

## Security Checklist

- [ ] SSH key-based authentication only
- [ ] Custom SSH port configured
- [ ] UFW firewall enabled with minimal rules
- [ ] Fail2ban configured and running
- [ ] Automatic security updates enabled
- [ ] Docker daemon secured
- [ ] Secrets stored in Docker secrets (not environment variables)
- [ ] Non-root containers where possible
- [ ] Regular security audits scheduled
- [ ] SSL/TLS certificates configured

## License

MIT License - Feel free to use and modify for your needs.