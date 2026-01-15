# Changelog

All notable changes to ARK (Autonomous Resilience Kit) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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


### Added - 2026-01-15
- [Content] Cartoons library mount (555GB) via /mnt/cartoons
- [Content] E:\Cartoons shared and mounted to Jellyfin container
- [Scripts] Content download automation suite in `/opt/ark/scripts/`:
  - `download-wikipedia.sh` - Wikipedia ZIM files for Kiwix (interactive/unattended modes)
  - `download-survival.sh` - Survival and emergency guides
  - `download-maps.sh` - OpenStreetMap data for OsmAnd
  - `download-books.sh` - Project Gutenberg and educational content
  - `check-downloads.sh` - Monitor active downloads and content status
- [Agents] Marketing agent crew with CrewAI framework in `/opt/ark/agents/`
- [Services] Voice watcher service in `/opt/ark/services/voice_watcher/`
- [Docs] .clinerules protocol file (ARK Protocols v2.0)
- [Docs] CLINERULES_FULL.md comprehensive protocol documentation
- [Docs] RALPH_PROTOCOL.md recovered from /mnt/dock
- [Docs] HANDOFF_DOCUMENT.md historical deployment procedures
- [Docs] DOCKER_COMPOSE_STANDARDS.md complete Docker guide
- [Docs] PROTOCOL_SUMMARY.md overview of all standards
- [Docs] CONTENT_AUDIT_REPORT.md deployment status analysis
- [Docs] PROGRESS_REPORT.md comprehensive project status
- [Docs] AGENT_FARM_SETUP.md - Agent framework documentation
- [Docs] DOCK_CHANGELOG.md - Storage system changelog
- [Docs] DOWNLOAD_STATUS.md - Content download tracking
- [Docs] D_DOCK_AUDIT.md - Dock storage audit report
- [Docs] HANDOFF_TO_NEW_CHAT.md - Context handoff procedures
- [Docs] MISSION_SUMMARY_20260115.txt - Daily mission summary
- [Docs] QUICK_REFERENCE.md - Quick reference guide
- [Config] Updated jellyfin volumes in docker-compose.yml for cartoons
- [Config] /etc/fstab entry for persistent cartoons mount

### Changed - 2026-01-15
- [Storage] Jellyfin now has read-only access to /mnt/cartoons
- [Network] CIFS mount added for E:\Cartoons share (555GB content)
- [Docs] README.md updated with content download scripts documentation and usage examples

### Fixed - 2026-01-15
- [Docs] Service count documented (13 actual, not 19)
- [Docs] Content package status clarified (0% deployed except cartoons)

### Planned for v1.1
- FileBrowser authentication fix
- Automated Kiwix .zim download helper
- Improved first-run setup wizard
- Health check dashboard integration

### Planned for v2.0 (See v2-roadmap.md)
- Linux bare-metal support
- Multi-platform installer
- Web-based configuration UI
- Automated backup system
- Fleet management (Mission Control)

---

## Version History

- **v1.0.0** (2026-01-15) - Initial production release
- **v0.2.x** (2025-12-xx) - Beta testing phase
- **v0.1.x** (2025-11-xx) - Alpha development

[1.0.0]: https://github.com/tylereno/ark/releases/tag/v1.0.0
