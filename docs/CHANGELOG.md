# Changelog

All notable changes to ARK (Autonomous Resilience Kit) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-15 - Resurrection Update

### 🚀 Major Update - Expanded Service Stack

ARK now includes **16 services** (up from 13), with new development tools and secure remote access capabilities.

### Added

#### New Services
- **Gitea** - Self-hosted Git repository server
  - Web UI: Port 3002
  - SSH access: Port 2222
  - Complete Git hosting solution
  - Issue tracking and project management
- **Code-Server** - VS Code in the browser
  - Port 8443 (HTTPS)
  - Full VS Code experience remotely
  - Password: `arknode123`
  - Persistent workspace at `/mnt/dock/data/code-server`
- **Tailscale** - Secure remote access via WireGuard VPN
  - Host network mode
  - Zero-config mesh networking
  - Secure remote access to all ARK services

#### Content Automation
- **Download Scripts** - Automated content acquisition suite in `/opt/ark/scripts/`:
  - `download-wikipedia.sh` - Wikipedia ZIM files for Kiwix (90GB+ option)
  - `download-survival.sh` - Survival and emergency preparedness guides
  - `download-maps.sh` - OpenStreetMap data for offline navigation
  - `download-books.sh` - Project Gutenberg and educational content
  - `check-downloads.sh` - Monitor active downloads and storage status

#### Infrastructure
- **Agent Farm** - CrewAI framework setup in `/opt/ark/agents/`
  - Marketing agent crew with Python environment
  - Extensible multi-agent architecture
- **Voice Watcher Service** - Custom service framework in `/opt/ark/services/voice_watcher/`
- **RESURRECTION.sh** - Service deployment and resurrection script
- **night-shift.sh** - Background maintenance automation

#### Documentation
- `.clinerules` - ARK Protocols v2.0 for AI agent operations
- `CLINERULES_FULL.md` - Comprehensive protocol documentation
- `RALPH_PROTOCOL.md` - Recovered architecture reference
- `DOCKER_COMPOSE_STANDARDS.md` - Complete Docker guide
- `PROTOCOL_SUMMARY.md` - Overview of all standards
- `AGENT_FARM_SETUP.md` - Agent framework documentation
- `QUICK_REFERENCE.md` - Quick reference guide
- Additional historical documentation (see /docs/archive/)

#### Content Libraries
- Cartoons library mount (555GB) via `/mnt/cartoons`
- E:\Cartoons CIFS share integrated with Jellyfin

### Changed
- **Service count**: 13 → 16 services
- **Docker Compose**: Updated to Ralph Protocol v1.1 standards
- **README.md**: Updated with new services and port assignments
- **SETUP_NOTES.md**: Added Gitea and Code-Server setup procedures
- **Jellyfin**: Now has read-only access to `/mnt/cartoons` mount
- **Storage**: Expanded CIFS mount configuration for new content
- **Repository structure**: Documentation reorganization (historical docs → `/docs/archive/`)

### Fixed
- Service count documentation (previously inconsistent)
- Content package deployment status clarification
- Port mapping documentation completeness

### Security Notes
- All new services use Ralph Protocol golden credentials (`admin`/`arknode123`)
- Code-Server operates over HTTPS (port 8443)
- Tailscale provides zero-trust network access
- Gitea SSH uses non-standard port 2222

---

## [1.0.0] - 2026-01-15

### 🎉 Initial Release - ARK v1.0 "Foundation"

The first production-ready release of ARK (Autonomous Resilience Kit) for Nomad Node.

### Added

#### Core Infrastructure
- **13-service Docker stack** with automatic health monitoring
  - Traefik reverse proxy with dashboard
  - Portainer for container management
  - Homepage unified dashboard
  - Autoheal container watchdog

#### AI & Intelligence
- **Ollama** - Local LLM API server
- **Open WebUI** - Modern AI chat interface
  - No authentication required (local-first design)
  - Integrated with Ollama backend

#### Media & Content
- **Jellyfin** - Full-featured media server
  - GPU transcoding support (with CPU fallback)
  - Setup wizard for first-time configuration
- **Audiobookshelf** - Audiobook and podcast manager
- **Kiwix** - Offline Wikipedia and reference materials
  - Requires manual .zim file downloads
  - Configured to auto-start when content available

#### Storage & Sync
- **FileBrowser** - Web-based file manager
  - Access to entire /mnt/dock CIFS mount
- **Syncthing** - Continuous file synchronization
- **Vaultwarden** - Self-hosted password manager
  - Bitwarden-compatible
  - Local-only deployment

#### Automation
- **Home Assistant** - System monitoring and automation
  - IoT device control
  - System health monitoring

#### Documentation
- **42 comprehensive documentation files** organized by category:
  - Developer documentation (4 files)
  - End-user guides (27 files)
  - Technical reference (8 files)
  - Business documentation (4 files)

#### Configuration Management
- **Ralph Protocol** implementation
  - Standardized ports (3000-13378 range)
  - Golden credentials (admin/arknode123)
  - Persistent storage at /mnt/dock
  - Static IP configuration (192.168.26.8)
  - *.ark.local domain routing

#### Networking
- Traefik reverse proxy with automatic service discovery
- Static IP assignment (192.168.26.8)
- Local DNS with *.ark.local routing
- All services isolated on ark_network bridge

#### Storage Architecture
- **Hybrid storage approach**:
  - Local SSD: SQLite databases, configs (/opt/ark/configs)
  - CIFS mount: Media, models, large files (/mnt/dock)
  - Prevents SMB corruption issues with databases

#### Health Monitoring
- Autoheal watchdog (60-second check interval)
- Per-service health checks
- Automatic container restart on failure
- 5-minute startup grace period

### Configuration

#### Standardized Credentials
- Default admin username: `admin`
- Default admin password: `arknode123`
- Portainer requires 12+ character passwords

#### Port Assignments
- 80: Traefik HTTP entrypoint
- 3000: Homepage dashboard
- 3001: Open WebUI
- 8080: Traefik dashboard
- 8081: FileBrowser
- 8082: Vaultwarden
- 8083: Kiwix
- 8096: Jellyfin
- 8123: Home Assistant
- 8384: Syncthing
- 9000: Portainer
- 11434: Ollama API
- 13378: Audiobookshelf

### Known Issues

#### Service Setup Required
- **Portainer**: Requires admin user creation on first visit (12+ char password)
- **Home Assistant**: Requires onboarding wizard completion
- **Jellyfin**: Requires setup wizard and library configuration
- **Audiobookshelf**: Requires root user creation

#### Service-Specific
- **FileBrowser**: Database authentication issue (requires manual reset)
- **Kiwix**: Exits if no .zim files present (by design)
- **Ollama**: Initial health check takes ~5 minutes on first boot

### Technical Details

#### Platform
- Target: Ubuntu 24.04 LTS on Hyper-V
- Docker Engine: 20.10+
- Docker Compose: v2
- Storage: Hybrid (local + CIFS)

#### Resource Requirements
- Minimum: 4GB RAM, 50GB storage
- Recommended: 8GB RAM, 200GB+ storage (for media)
- Network: Static IP required for reliable service access

### Migration Notes

This release includes migration of documentation from legacy locations:
- Consolidated 42 files from multiple sources
- Reorganized into logical categories
- Used rsync for CIFS-safe transfer (Ralph Protocol)

### Documentation Locations

- Complete docs: `/mnt/dock/docs/`
- Service links: `/mnt/dock/ARK_NODE_LINKS.txt`
- Repository audit: `/tmp/REPOSITORY_AUDIT.md`
- Phase 2 status: `/tmp/ARK_PHASE2_COMPLETE_REPORT.md`

### Credits

- **Project Lead**: Tyler Eno (tylereno.me)
- **Architecture**: Ralph Protocol implementation
- **Testing**: Production deployment on Nomad Node VM
- **Documentation**: Comprehensive 42-file knowledge base

---

## [Unreleased]

### Planned for v1.2
- FileBrowser authentication fix
- Automated Kiwix .zim download helper
- Improved first-run setup wizard
- Health check dashboard integration
- Tailscale authentication automation

### Planned for v2.0 (See v2-roadmap.md)
- Linux bare-metal support
- Multi-platform installer
- Web-based configuration UI
- Automated backup system
- Fleet management (Mission Control)
- Multi-architecture support (ARM64)

---

## Version History

- **v1.1.0** (2026-01-15) - Resurrection Update (16 services)
- **v1.0.0** (2026-01-15) - Initial production release (13 services)
- **v0.2.x** (2025-12-xx) - Beta testing phase
- **v0.1.x** (2025-11-xx) - Alpha development

[1.1.0]: https://github.com/tylereno/ark/releases/tag/v1.1.0
[1.0.0]: https://github.com/tylereno/ark/releases/tag/v1.0.0

## [2026-01-16] - Deployment 69592adb

### Changes
- **Commit**: 69592adb
- **Message**: Industrial Refactor: Sanitized root folder, organized docs/scripts, added auto-cleanup

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---

## [2026-01-16] - Deployment 69592adb

### Changes
- **Commit**: 69592adb
- **Message**: Industrial Refactor: Sanitized root folder, organized docs/scripts, added auto-cleanup

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---

## [2026-01-16] - Deployment 69592adb

### Changes
- **Commit**: 69592adb
- **Message**: Industrial Refactor: Sanitized root folder, organized docs/scripts, added auto-cleanup

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---

## [2026-01-16] - Deployment 69592adb

### Changes
- **Commit**: 69592adb
- **Message**: Industrial Refactor: Sanitized root folder, organized docs/scripts, added auto-cleanup

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---

## [2026-01-16] - Deployment 967e8070

### Changes
- **Commit**: 967e8070
- **Message**: Final Polish: ARK Manager v3.0 with Smart Health Checks

- Updated ark-manager.sh to v3.0 with Docker-native health checks
- Eliminated false positives from HTTP curl checks
- Added non-interactive mode for GitHub Actions/cron
- Updated service verification to use Docker health status
- Fixed container count logic
- Updated CrewAI system prompt for Tier 1 Autonomous Agent
- Organized documentation structure
- Added auto-cleanup to GitHub Actions

Status: Gold Standard - Production Ready

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---

## [2026-01-16] - Deployment 6af44dde

### Changes
- **Commit**: 6af44dde
- **Message**: Add CrewAI agent integration and command cheat sheet

- Created ark_agent.py Python wrapper for CrewAI
- Added COMMAND_CHEAT_SHEET.md with essential commands
- Added requirements.txt for Python dependencies
- Added README_CREWAI.md setup guide
- Complete autonomous agent integration ready

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---

## [2026-01-16] - Deployment 6af44dde

### Changes
- **Commit**: 6af44dde
- **Message**: Add CrewAI agent integration and command cheat sheet

- Created ark_agent.py Python wrapper for CrewAI
- Added COMMAND_CHEAT_SHEET.md with essential commands
- Added requirements.txt for Python dependencies
- Added README_CREWAI.md setup guide
- Complete autonomous agent integration ready

### Service Versions
- **name ark_network**:  (not running)
- **driver bridge**:  (not running)
- **traefik**: traefik:v3.1 (not running)
- **image traefik:v3.1  # Note: 3.1+ handles newer Docker APIs better**:  (not running)
- **profiles**:  (not running)
- **environment**:  (not running)
- **command**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **portainer**: portainer/portainer-ce:latest (not running)
- **image portainer/portainer-ce:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **homepage**: ghcr.io/gethomepage/homepage:latest (not running)
- **image ghcr.io/gethomepage/homepage:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **autoheal**: willfarrell/autoheal:latest (not running)
- **image willfarrell/autoheal:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **networks**:  (not running)
- **ollama**: ollama/ollama:latest (not running)
- **image ollama/ollama:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **open-webui**: ghcr.io/open-webui/open-webui:main (not running)
- **image ghcr.io/open-webui/open-webui:main**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8080/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **jellyfin**: jellyfin/jellyfin:latest (not running)
- **image jellyfin/jellyfin:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8096/health"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **audiobookshelf**: ghcr.io/advplyr/audiobookshelf:latest (not running)
- **image ghcr.io/advplyr/audiobookshelf:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **filebrowser**: filebrowser/filebrowser:latest (not running)
- **image filebrowser/filebrowser:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **syncthing**: syncthing/syncthing:latest (not running)
- **image syncthing/syncthing:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **vaultwarden**: vaultwarden/server:latest (not running)
- **image vaultwarden/server:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **kiwix**: ghcr.io/kiwix/kiwix-serve:latest (not running)
- **image ghcr.io/kiwix/kiwix-serve:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **command ["*.zim"]**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "wget", "-q", "--spider", "http://localhost:8080/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **homeassistant**: ghcr.io/home-assistant/home-assistant:stable (not running)
- **image ghcr.io/home-assistant/home-assistant:stable**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **tailscale**: tailscale/tailscale:latest (not running)
- **image tailscale/tailscale:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **environment**:  (not running)
- **volumes**:  (not running)
- **privileged true**:  (not running)
- **command tailscaled**:  (not running)
- **gitea**: gitea/gitea:latest (not running)
- **image gitea/gitea:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:3000/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)
- **code-server**: linuxserver/code-server:latest (not running)
- **image linuxserver/code-server:latest**:  (not running)
- **profiles**:  (not running)
- **restart unless-stopped**:  (not running)
- **ports**:  (not running)
- **volumes**:  (not running)
- **environment**:  (not running)
- **networks**:  (not running)
- **labels**:  (not running)
- **healthcheck**:  (not running)
- **test ["CMD", "curl", "-f", "http://localhost:8443/"]**:  (not running)
- **interval 30s**:  (not running)
- **timeout 10s**:  (not running)
- **retries 3**:  (not running)

---
