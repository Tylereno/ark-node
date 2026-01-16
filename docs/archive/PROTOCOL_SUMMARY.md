# ARK Node - Protocol & Standards Documentation

## Recovered Important Documents

### 1. RALPH_PROTOCOL.md
**Purpose:** Quick start guide and overview of the RALPH Protocol
- Autonomous Dev Lead methodology
- 13 service stack configuration
- Golden credentials (admin/arknode123)
- VM setup and bootstrap procedures
- "Civilization in a Box" architecture

### 2. HANDOFF_DOCUMENT.md  
**Purpose:** Historical context and deployment procedures
- Explains how the system was originally built
- Mount configuration details
- SCP deployment procedures
- Network configuration (192.168.26.8)
- Troubleshooting mount issues

### 3. DOCKER_COMPOSE_STANDARDS.md
**Purpose:** Complete Docker Compose development guide
- Service template standards
- Adding new services checklist
- Volume mounting best practices (local vs CIFS)
- Traefik integration patterns
- Health check configurations
- Network configuration standards
- Troubleshooting procedures

### 4. CONTENT_AUDIT_REPORT.md
**Purpose:** Current deployment status
- Missing content packages analysis
- Service discrepancies (13 actual vs documented)
- Storage usage (5.8GB / 490GB expected)
- Recommendations for content deployment

## Current System Overview

**Running:** 13 containers (not 19)
- Traefik, Portainer, Homepage, Autoheal
- Ollama, Open WebUI
- Jellyfin (now with 555GB cartoons!), Audiobookshelf
- FileBrowser, Syncthing, Vaultwarden
- Kiwix (no content), Home Assistant

**Missing Services (documented but not deployed):**
- AdGuard Home
- Glances
- Watchtower
- Voice Watcher

**Missing Content (0% deployed):**
- Kiwix bundles (Wikipedia, etc.)
- Offline maps
- Public domain media
- Additional resources

## Key Standards

### Golden Credentials
- Username: `admin`
- Password: `arknode123`
- System user: `nomadty`
- System password: `laserdog09`

### Storage Rules
- **Local SSD (`/opt/ark/configs`)**: SQLite databases, configs
- **CIFS Mount (`/mnt/dock`)**: Media files, AI models, large data
- **Never**: SQLite on CIFS (will corrupt)

### Port Assignments
- 80: Traefik
- 3000: Homepage
- 3001: Open WebUI
- 8080: Traefik Dashboard
- 8081: FileBrowser
- 8082: Vaultwarden
- 8083: Kiwix
- 8096: Jellyfin
- 8123: Home Assistant
- 8384: Syncthing
- 9000: Portainer
- 11434: Ollama
- 13378: Audiobookshelf

### Network
- Bridge network: `ark_network`
- VM IP: 192.168.26.8
- Domain pattern: `*.ark.local`

## Recent Changes

✅ **Cartoons Library Added** (Jan 15, 2026)
- Mounted E:\Cartoons (555GB) to /mnt/cartoons
- Added to Jellyfin container
- Made mount permanent in /etc/fstab

## Next Steps

1. Deploy Kiwix content (~7GB minimal)
2. Download offline maps (~10GB)
3. Fix service documentation mismatch
4. Optional: Add missing services (AdGuard, Glances, etc.)

---

**Location:** `/opt/ark/`
**Last Updated:** Jan 15, 2026
