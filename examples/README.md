# ARK Configuration Examples

This directory contains example environment configurations for different ARK deployment scenarios.

## Quick Start

1. Choose the configuration that matches your use case
2. Copy the `.env` file to your ARK root directory: `cp examples/.env.core-only .env`
3. Source it before running ark-manager: `source .env && ./scripts/ark-manager.sh deploy`

## Available Configurations

### `.env.core-only`
**Use Case:** Minimal resource footprint, essential infrastructure only

**Profiles:** `core`

**Services Included:**
- Traefik (reverse proxy)
- Tailscale (mesh networking)
- Autoheal (container watchdog)
- Homepage (dashboard)
- Portainer (container management)
- Syncthing (file sync)

**Resource Requirements:**
- RAM: ~2GB
- Storage: ~5GB
- CPU: 2 cores

**Best For:**
- Low-power devices (Raspberry Pi, small VMs)
- Edge deployments
- Testing/development environments
- Users who only need basic infrastructure

### `.env.full-node`
**Use Case:** Complete ARK deployment with all services

**Profiles:** `core,apps,media`

**Services Included:**
- All Core services
- All Application services (Ollama, Open WebUI, Kiwix, Gitea, Code-Server, Vaultwarden, FileBrowser)
- All Media services (Jellyfin, Audiobookshelf, Home Assistant)

**Resource Requirements:**
- RAM: ~8GB+ (16GB recommended)
- Storage: ~100GB+ (for media and models)
- CPU: 4+ cores

**Best For:**
- High-performance nodes
- Complete self-hosted infrastructure
- Users who want everything ARK offers

### `.env.ai-lab`
**Use Case:** AI-focused deployment without media services

**Profiles:** `core,apps`

**Services Included:**
- All Core services
- All Application services (including Ollama and Open WebUI)
- No Media services

**Resource Requirements:**
- RAM: ~8GB+ (12GB+ if running large models)
- Storage: ~50GB+ (for AI models)
- CPU: 4+ cores (GPU recommended for Ollama)

**Best For:**
- AI/ML development
- GPU-equipped nodes
- Users who want AI capabilities without media streaming
- Research and experimentation

## Usage Examples

### Deploy Core-Only Stack
```bash
# Set environment
export COMPOSE_PROFILES=core

# Deploy
./scripts/ark-manager.sh deploy

# Check status
./scripts/ark-manager.sh status
```

### Deploy Full Stack
```bash
# Set environment
export COMPOSE_PROFILES=core,apps,media

# Deploy
./scripts/ark-manager.sh deploy

# Or use the default (all profiles)
./scripts/ark-manager.sh deploy
```

### Switch Between Configurations
```bash
# Stop current stack
docker compose down

# Switch to core-only
export COMPOSE_PROFILES=core
./scripts/ark-manager.sh deploy

# Later, add apps
export COMPOSE_PROFILES=core,apps
./scripts/ark-manager.sh deploy
```

## Custom Configurations

You can create your own `.env` file by combining profiles:

```bash
# Example: Core + Media (no apps)
export COMPOSE_PROFILES=core,media

# Example: Core + specific apps only
# (Note: Profiles are all-or-nothing per profile, but you can modify docker-compose.yml)
```

## Profile Reference

| Profile | Services | Use Case |
|---------|----------|----------|
| `core` | Traefik, Tailscale, Autoheal, Homepage, Portainer, Syncthing | Essential infrastructure |
| `apps` | Ollama, Open WebUI, Kiwix, Gitea, Code-Server, Vaultwarden, FileBrowser | Development & productivity |
| `media` | Jellyfin, Audiobookshelf, Home Assistant | Entertainment & automation |

## Notes

- Profiles are cumulative: `core,apps` includes both core and apps services
- The `core` profile is required for all deployments (other services depend on Traefik)
- You can change profiles at any time by setting `COMPOSE_PROFILES` and redeploying
- Services in inactive profiles will be stopped but not removed (data preserved)
