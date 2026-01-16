# Container Upgrade Guide - v3.1.2

## Issue

Your containers are currently running with `:latest` tags from an older deployment. The current `docker-compose.yml` uses **pinned versions** for deterministic deployments (LTS requirement).

## Solution: Upgrade to Pinned Versions

### Step 1: Backup Current State

```bash
cd /opt/ark
./scripts/ark-manager.sh document  # Backup configs
```

### Step 2: Stop Old Containers

```bash
# Stop all containers managed by docker-compose
docker compose down

# Note: This will stop containers but preserve volumes/data
```

### Step 3: Deploy with Pinned Versions

```bash
# Deploy all profiles with pinned versions
docker compose --profile core --profile apps --profile media up -d

# Or use the manager script
./scripts/ark-manager.sh deploy
```

### Step 4: Verify

```bash
# Check containers are using pinned versions
docker ps --format "{{.Names}}: {{.Image}}" | grep -v "datadog"

# Should show versions like:
# homepage: ghcr.io/gethomepage/homepage:v1.0.0
# portainer: portainer/portainer-ce:2.20.4
# jellyfin: jellyfin/jellyfin:10.11.4
```

## Why This Matters

**Pinned versions ensure:**
- Deterministic deployments (same version every time)
- LTS compliance (no unexpected updates)
- Reproducible state across nodes
- Security (you control when to update)

## Note on autoheal Container

If you see an `autoheal` container running, it's from an old deployment. It was removed in v3.1.0 in favor of native Docker restart policies. It will be removed when you run `docker compose down`.

## Quick Command

```bash
cd /opt/ark && docker compose down && docker compose --profile core --profile apps --profile media up -d
```

This will:
1. Stop old containers (including autoheal)
2. Start new containers with pinned versions
3. Preserve all your data (volumes are not removed)
