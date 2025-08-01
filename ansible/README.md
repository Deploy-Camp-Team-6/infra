# Docker Swarm Infrastructure Deployment

This Ansible playbook deploys a production-ready Docker Swarm infrastructure with Traefik and Portainer.

## Prerequisites

1. **Target Server**: Ubuntu 22.04 VPS with root/sudo access
2. **Ansible Control Node**: Ansible 2.9+ installed
3. **SSH Access**: Key-based authentication configured between your control node and the target servers.
4. **Domain**: A domain name pointing to your swarm manager's public IP.
5. **Host Key Verification**: The SSH host keys of your target servers should be in your control node's `~/.ssh/known_hosts` file. This playbook enforces host key checking for security.

## Quick Start

### 1. Clone and Configure

```bash
git clone <this-repo>
cd docker-swarm-ansible
```

### 2. Update Inventory

Edit `inventory/hosts.yml` with the IP addresses of your manager and worker nodes. For example:
```yaml
swarm_managers:
  hosts:
    swarm-manager-01:
      ansible_host: 192.0.2.10
      ansible_user: ubuntu
      ansible_ssh_private_key_file: /path/to/your/key.pem

swarm_workers:
  hosts:
    swarm-worker-01:
      ansible_host: 192.0.2.20
      ansible_user: ubuntu
      ansible_ssh_private_key_file: /path/to/your/key.pem
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
ansible docker_nodes -m ping

# Deploy everything
ansible-playbook site.yml

# Deploy specific components
ansible-playbook site.yml --tags "docker,traefik"
```

### 5. Access Services

After deployment:
- **Traefik Dashboard**: `https://traefik.yourdomain.com`
- **Portainer**: `https://portainer.yourdomain.com`

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
│   └── portainer/
└── scripts/
    ├── deploy.sh
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

This playbook is designed to support multi-node clusters out of the box. To scale your swarm:

1.  **Add Worker Nodes to Inventory**: Add your new worker nodes to the `swarm_workers` group in `inventory/hosts.yml`.

    ```yaml
    swarm_workers:
      hosts:
        swarm-worker-01:
          ansible_host: YOUR_WORKER_1_IP
          # ...
        swarm-worker-02:
          ansible_host: YOUR_WORKER_2_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: /path/to/your/key.pem
          node_role: worker
          ansible_python_interpreter: /usr/bin/python3
    ```

2.  **Run the Playbook**: Re-run the main playbook. Ansible will automatically provision the new nodes and join them to the swarm.

    ```bash
    ansible-playbook site.yml
    ```

## Maintenance Scripts

### Deploy Script
```bash
#!/bin/bash
# scripts/deploy.sh

set -e

echo "Starting deployment..."

# Test connectivity
ansible docker_nodes -m ping

# Deploy infrastructure
ansible-playbook site.yml

echo "Deployment completed!"
echo "Access services at:"
echo "- Traefik: https://traefik.yourdomain.com"
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

# Backup Docker volumes (e.g., Portainer, Traefik)
# This is a conceptual example. You should adapt it to back up the specific volumes you care about.
docker run --rm -v portainer_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/portainer_data.tar.gz -C /data .
docker run --rm -v traefik_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/traefik_data.tar.gz -C /data .

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
7. **Documentation**: Keep deployment docs updated

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
- [ ] File integrity monitoring active

## License

MIT License - Feel free to use and modify for your needs.