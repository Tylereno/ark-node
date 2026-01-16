# Docker Compose Guide for ARK Node

Complete guide for working with Docker Compose in ARK Node, including how to add new services, manage configurations, and troubleshoot issues.

## Table of Contents

- [Overview](#overview)
- [File Structure](#file-structure)
- [Adding a New Service](#adding-a-new-service)
- [Configuration Management](#configuration-management)
- [Volume Mounting Best Practices](#volume-mounting-best-practices)
- [Network Configuration](#network-configuration)
- [Traefik Integration](#traefik-integration)
- [Health Checks](#health-checks)
- [Common Operations](#common-operations)
- [Troubleshooting](#troubleshooting)

---

## Overview

ARK Node uses Docker Compose to orchestrate 13 containerized services. The main configuration file is `/opt/ark/docker-compose.yml`.

**Key Concepts**:
- All services run on a single bridge network (`ark_network`)
- Traefik provides reverse proxy with automatic service discovery
- Configurations stored in `/opt/ark/configs/`
- Large files stored on `/mnt/dock/`

---

## File Structure

```
/opt/ark/
├── docker-compose.yml          # Main orchestration file
├── .env                         # Environment variables (optional)
├── configs/                     # Service configurations
│   ├── homepage/
│   ├── portainer/
│   ├── jellyfin/
│   └── ...
└── deploy.sh                    # Deployment script

/mnt/dock/                       # Windows CIFS mount
└── data/
    ├── models/                  # AI models
    ├── media/                   # Media files
    └── sync/                    # Syncthing data
```

---

## Adding a New Service

### Step 1: Choose Service Template

Use this template for most services:

```yaml
service-name:
  image: organization/image:tag
  container_name: service-name
  restart: unless-stopped
  ports:
    - "HOST_PORT:CONTAINER_PORT"
  volumes:
    - /opt/ark/configs/service-name:/config
    - /mnt/dock/data/service-name:/data
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=America/Los_Angeles
  networks:
    - ark_network
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.service-name.rule=Host(`service-name.ark.local`)"
    - "traefik.http.services.service-name.loadbalancer.server.port=CONTAINER_PORT"
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:CONTAINER_PORT/health"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 60s
```

### Step 2: Customize for Your Service

**Example: Adding Grafana**

```yaml
grafana:
  image: grafana/grafana:latest
  container_name: grafana
  restart: unless-stopped
  ports:
    - "3002:3000"                # Grafana runs on 3000 internally
  volumes:
    - /opt/ark/configs/grafana:/var/lib/grafana
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=admin
    - GF_SERVER_ROOT_URL=http://grafana.ark.local
  networks:
    - ark_network
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.grafana.rule=Host(`grafana.ark.local`)"
    - "traefik.http.services.grafana.loadbalancer.server.port=3000"
```

### Step 3: Create Configuration Directory

```bash
sudo mkdir -p /opt/ark/configs/grafana
sudo chown -R 1000:1000 /opt/ark/configs/grafana
```

### Step 4: Test the Service

```bash
cd /opt/ark
docker compose up -d grafana
docker logs -f grafana
```

### Step 5: Verify Access

```bash
curl http://localhost:3002
# Should respond with Grafana login page
```

### Step 6: Update Homepage

Add to `/opt/ark/configs/homepage/services.yaml`:

```yaml
- Monitoring:
    - Grafana:
        icon: grafana.svg
        href: http://192.168.26.8:3002
        description: Metrics & Dashboards
```

---

## Configuration Management

### Environment Variables

#### Option 1: `.env` File

Create `/opt/ark/.env`:

```env
# Global settings
TZ=America/Los_Angeles
PUID=1000
PGID=1000

# Service-specific
JELLYFIN_VERSION=latest
OLLAMA_HOST=0.0.0.0
```

Reference in `docker-compose.yml`:

```yaml
environment:
  - TZ=${TZ}
  - PUID=${PUID}
```

#### Option 2: Inline Environment Variables

```yaml
environment:
  - TZ=America/Los_Angeles
  - PUID=1000
```

### Secrets Management

For sensitive data, use Docker secrets or env files:

```bash
# Create secrets file
echo "my_api_key" | sudo tee /opt/ark/configs/service/.secret

# Mount in compose
volumes:
  - /opt/ark/configs/service/.secret:/run/secrets/api_key:ro
```

---

## Volume Mounting Best Practices

### Decision Matrix

**Use `/opt/ark/configs/` for:**
- ✅ SQLite databases
- ✅ Configuration files
- ✅ Cache directories
- ✅ Small, frequently-accessed files

**Use `/mnt/dock/data/` for:**
- ✅ Media files (videos, audiobooks)
- ✅ AI models (multi-GB files)
- ✅ Backup storage
- ✅ Downloads

### Examples

#### Good: Database on Local Storage

```yaml
vaultwarden:
  volumes:
    - /opt/ark/configs/vaultwarden:/data  # ✅ SQLite here
```

#### Good: Media on CIFS Mount

```yaml
jellyfin:
  volumes:
    - /opt/ark/configs/jellyfin:/config    # ✅ Config local
    - /mnt/dock/data/media:/media          # ✅ Media on CIFS
```

#### Bad: Database on CIFS

```yaml
vaultwarden:
  volumes:
    - /mnt/dock/data/vaultwarden:/data  # ❌ Will corrupt!
```

### Bind Mounts vs Named Volumes

**Bind Mounts** (what ARK Node uses):
```yaml
volumes:
  - /opt/ark/configs/service:/config
```

**Named Volumes** (alternative):
```yaml
volumes:
  - service_data:/config

volumes:
  service_data:
```

ARK Node uses bind mounts for easier backup and access from the host.

### File Permissions

Ensure correct ownership:

```bash
sudo chown -R 1000:1000 /opt/ark/configs/service-name
```

Most containers run as UID 1000 (default user).

---

## Network Configuration

### Default Network

All services use `ark_network`:

```yaml
networks:
  ark_network:
    name: ark_network
    driver: bridge
```

### Service-to-Service Communication

Services communicate using container names:

```yaml
# Open WebUI connecting to Ollama
environment:
  - OLLAMA_BASE_URL=http://ollama:11434
```

### Port Mapping

```yaml
ports:
  - "HOST_PORT:CONTAINER_PORT"
```

**Example**:
```yaml
ports:
  - "3000:3000"  # Homepage: Host 3000 → Container 3000
  - "3001:8080"  # Open WebUI: Host 3001 → Container 8080
```

### Expose vs Ports

```yaml
# Expose: Only accessible to other containers
expose:
  - "8080"

# Ports: Accessible from host
ports:
  - "8080:8080"
```

---

## Traefik Integration

### Basic Traefik Labels

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.SERVICE.rule=Host(`SERVICE.ark.local`)"
  - "traefik.http.services.SERVICE.loadbalancer.server.port=PORT"
```

### Multiple Hostnames

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.SERVICE.rule=Host(`SERVICE.ark.local`) || Host(`alias.ark.local`)"
```

### Path-Based Routing

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.SERVICE.rule=Host(`ark.local`) && PathPrefix(`/service`)"
  - "traefik.http.middlewares.SERVICE-strip.stripprefix.prefixes=/service"
  - "traefik.http.routers.SERVICE.middlewares=SERVICE-strip"
```

### HTTPS/TLS (Future)

```yaml
labels:
  - "traefik.http.routers.SERVICE.tls=true"
  - "traefik.http.routers.SERVICE.tls.certresolver=letsencrypt"
```

---

## Health Checks

### Basic Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### Alternative Test Methods

**Using wget**:
```yaml
test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080"]
```

**Using nc (netcat)**:
```yaml
test: ["CMD", "nc", "-z", "localhost", "8080"]
```

**Using custom script**:
```yaml
test: ["CMD", "/app/healthcheck.sh"]
```

**Using docker exec**:
```yaml
# From host
docker exec SERVICE curl -f http://localhost:8080/health
```

### Health Check Parameters

- `interval`: Time between checks
- `timeout`: Time to wait for response
- `retries`: Number of consecutive failures before unhealthy
- `start_period`: Grace period during startup

### Autoheal Integration

Autoheal automatically restarts containers that fail health checks:

```yaml
autoheal:
  image: willfarrell/autoheal:latest
  environment:
    - AUTOHEAL_CONTAINER_LABEL=all
    - AUTOHEAL_INTERVAL=60
```

---

## Common Operations

### Start All Services

```bash
cd /opt/ark
docker compose up -d
```

### Start Specific Service

```bash
docker compose up -d homepage
```

### Stop All Services

```bash
docker compose down
```

### Restart Service

```bash
docker compose restart homepage
```

### View Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs -f homepage

# Last 100 lines
docker compose logs --tail=100 jellyfin

# With timestamps
docker compose logs -t ollama
```

### Update Service

```bash
# Pull latest image
docker compose pull homepage

# Recreate container
docker compose up -d homepage

# Or in one command
docker compose up -d --pull always homepage
```

### Remove Service

```bash
# Stop and remove
docker compose rm -sf homepage

# Remove from docker-compose.yml
# Then restart remaining services
docker compose up -d
```

### Scale Service (Not typically used in ARK Node)

```bash
docker compose up -d --scale worker=3
```

---

## Troubleshooting

### Service Won't Start

**Check logs**:
```bash
docker compose logs SERVICE_NAME
```

**Common issues**:
- Port already in use
- Volume permission issues
- Missing environment variables
- Invalid configuration file

**Debug mode**:
```bash
docker compose up SERVICE_NAME
# (without -d to see output)
```

### Port Conflicts

**Find what's using a port**:
```bash
sudo lsof -i :8080
# or
sudo netstat -tulpn | grep 8080
```

**Change port in docker-compose.yml**:
```yaml
ports:
  - "8081:8080"  # Use 8081 on host instead
```

### Volume Permission Issues

```bash
# Fix permissions
sudo chown -R 1000:1000 /opt/ark/configs/SERVICE

# Check current permissions
ls -la /opt/ark/configs/
```

### Container Crashes Immediately

**Check exit code**:
```bash
docker ps -a | grep SERVICE_NAME
```

**Inspect container**:
```bash
docker inspect SERVICE_NAME
```

**Run interactively**:
```bash
docker run -it --rm IMAGE_NAME /bin/bash
```

### Network Issues

**Verify network exists**:
```bash
docker network ls | grep ark
```

**Inspect network**:
```bash
docker network inspect ark_network
```

**Test connectivity between containers**:
```bash
docker exec SERVICE1 ping SERVICE2
```

### CIFS Mount Issues

**Check mount**:
```bash
mount | grep /mnt/dock
```

**Test CIFS performance**:
```bash
dd if=/dev/zero of=/mnt/dock/test bs=1M count=100
```

**Remount if needed**:
```bash
sudo umount /mnt/dock
sudo mount -a
```

### Memory Issues

**Check memory usage**:
```bash
docker stats
```

**Limit service memory**:
```yaml
services:
  SERVICE:
    deploy:
      resources:
        limits:
          memory: 2G
```

### Disk Space Issues

**Check Docker disk usage**:
```bash
docker system df
```

**Clean up**:
```bash
# Remove unused images
docker image prune -a

# Remove stopped containers
docker container prune

# Remove unused volumes
docker volume prune

# Complete cleanup
docker system prune -a --volumes
```

---

## Advanced Configurations

### Dependencies

```yaml
service-a:
  depends_on:
    - service-b
    - service-c
```

**With health check wait**:
```yaml
service-a:
  depends_on:
    service-b:
      condition: service_healthy
```

### Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 4G
    reservations:
      cpus: '1.0'
      memory: 2G
```

### Logging Configuration

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Custom Networks

```yaml
networks:
  frontend:
  backend:

services:
  web:
    networks:
      - frontend
  database:
    networks:
      - backend
```

---

## Service Template Checklist

When adding a new service, ensure:

- [ ] Unique container name
- [ ] Correct port mapping (no conflicts)
- [ ] Volumes pointing to correct locations
- [ ] Part of `ark_network`
- [ ] Traefik labels configured (if web service)
- [ ] Health check defined (if applicable)
- [ ] Restart policy set (`unless-stopped`)
- [ ] Environment variables set
- [ ] Added to Homepage dashboard
- [ ] Tested and verified working

---

## References

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Traefik Docker Provider](https://doc.traefik.io/traefik/providers/docker/)
- [Docker Health Check Reference](https://docs.docker.com/engine/reference/builder/#healthcheck)
