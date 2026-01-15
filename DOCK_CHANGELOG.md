# Nomad Node - Changelog

All notable changes to Nomad Node will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v0.4.0
- Automated testing suite
- GPU passthrough for Ollama (Hyper-V DDA)
- Performance optimizations
- Additional integrations

## [0.3.0] - 2026-01-14 (RALPH Protocol Implementation)

### Added - Phase 0 (Rescue & Unlock)
- **0_unlock.ps1**: Emergency permission fix script for E:\DOCK and D:\NomadVM
- **generate_env.py**: Golden Config generator with hardcoded credentials
- **.gitattributes**: CRLF killer - forces LF line endings for shell scripts
- **Git safety**: Added E:\DOCK to safe.directory for external drive support

### Added - Phase 1 (Infrastructure)
- **1_setup_hyperv.ps1**: Complete Hyper-V architect script
  - Creates ArkBridge virtual switch
  - Creates ARK-NODE-01 VM with Ubuntu Server
  - Auto-detects Ubuntu ISO from Installers/
  - Configures auto-start and integration services
- **bootstrap.sh**: VM bootstrap script with Docker, CIFS mount, and caching
- **backup_configs.sh**: Nightly rsync backup to E:\DOCK/data/_backup
- **Canonical directory structure**: scripts/host/, scripts/vm/, config/, data/

### Added - Phase 2 (The 13 Services)
- **Traefik**: Reverse proxy with *.ark.local routing
- **Portainer**: Container management UI
- **Homepage**: Main dashboard with all service links
- **Autoheal**: Container watchdog for auto-restart
- **Ollama**: AI LLM API (CPU mode, GPU passthrough pending)
- **Open WebUI**: Chat interface for Ollama
- **Jellyfin**: Media server
- **Audiobookshelf**: Audiobooks & podcasts
- **FileBrowser**: Web file manager
- **Syncthing**: Device sync
- **Vaultwarden**: Self-hosted password manager
- **Kiwix**: Offline Wikipedia/medical reference
- **Home Assistant**: IoT control

### Added - Phase 3 (Automation)
- **START.bat**: One-click launcher with admin elevation
  - Runs unlock script silently
  - Starts VM if not running
  - Dynamically injects hosts file entries
  - Waits for services to come online
  - Launches browser to hub.ark.local
- **2_start_ark.ps1**: PowerShell version of launcher
- **Voice Watcher**: Infinite loop guard implemented (moves processed files)
- **Homepage config**: services.yaml, settings.yaml, widgets.yaml

### Changed - Major Refactoring
- **Directory structure**: Reorganized to canonical structure per charter
- **Scripts folder**: Archived legacy Scripts to _archive/Scripts_legacy
- **Ollama models**: Moved .ollama to data/models (5.77GB preserved)
- **Golden Credentials**: Standardized across all services
  - User: nomad / admin
  - Password: arknode123
  - Hostname: ark.local

### Fixed - Critical Issues
- **Line endings**: .gitattributes ensures LF for shell scripts
- **Git ownership**: Added safe.directory for external SSD
- **SMB mount permissions**: uid=1000,gid=1000,file_mode=0775
- **Voice watcher loop**: Moves files to /processed after processing

## [0.2.0] - 2026-01-XX

### Added - v0.2.0 Features
- **Voice Watcher Containerized**: Voice watcher now runs as Docker container, auto-starts with services
- **Health Dashboard Integration**: System health status added to Homepage dashboard
- **Improved Documentation**: Better VM IP detection documentation, consolidated application layer docs
- **Structure Improvements**: Consolidated `apps/` directory, moved docs to proper location

### Changed - v0.2.0 Improvements
- **Application Layer Documentation**: Moved `apps/README_APPS.md` to `docs/1.6_APPLICATION_LAYER.md`
- **Voice Watcher**: Now containerized and integrated into main docker-compose.yml
- **Health Monitoring**: Added health status widget to Homepage dashboard
- **Documentation Organization**: Improved structure and cross-references

### Fixed - v0.2.0 Fixes
- Removed `apps/` directory (consolidated into docs)
- Improved VM IP detection documentation
- Better integration of voice watcher with Docker stack

## [0.1.0] - 2026-01-XX

### Added - Core Features
- **Single Entry Point**: `INSTALL.bat` auto-detects system and runs appropriate installer
- **VM IP Detection**: Automatic VM IP detection and display after VM creation
- **Health Verification**: `1.3_verify_installation.ps1` comprehensive system check
- **Application Layer**: Portainer and Syncthing integrated into main docker-compose.yml
- **Voice Watcher**: Complete implementation with Whisper transcription and Ollama summarization
- **Uninstall Script**: `0.1_UNINSTALL.ps1` for clean removal
- **Helper Functions**: `_helpers.ps1` with standardized logging, validation, and error handling

### Changed - Major Improvements
- **Removed Legacy Mode**: Eliminated Windows + Docker Desktop installation path
- **Simplified Installation**: Single installation method (Windows + Linux VM only)
- **Unified Startup**: `START_SERVER.bat` works in both Windows and Linux
- **Documentation Cleanup**: Removed all Legacy Mode references, simplified guides
- **VM Troubleshooting**: Added comprehensive VM-specific troubleshooting section

### Fixed - Critical Issues
- VM IP not displayed after creation
- No way to verify installation success
- Application layer (Portainer/Syncthing) not integrated
- Voice watcher incomplete (all TODOs)
- Confusing dual installation modes
- No uninstall capability

### Improved - Code Quality
- Standardized error handling across all scripts
- Input validation helpers for drive letters, IPs, ports, paths
- Logging framework with file output support
- Better error messages with actionable guidance
- Consistent script naming and organization

### Documentation
- Updated all installation guides to reflect single method
- Added VM-specific troubleshooting to `4.2_COMMON_FAILURES.md`
- Consolidated installation guide into main `README.md`
- Updated `Scripts/README.md` to remove Legacy Mode
- Added helper function documentation

### Technical Details
- **Services**: 12 total (10 core + 2 application layer)
  - Core: Homepage, Open WebUI, Jellyfin, Audiobookshelf, AdGuard, FileBrowser, Home Assistant, Glances, Watchtower, Kiwix
  - Application: Portainer, Syncthing
- **Scripts**: 15 total
  - Installation: 2 (Windows VM setup, Linux installer)
  - Verification: 1 (health check)
  - Optional: 1 (resource downloads)
  - Maintenance: 4 (watchdog, health logger, backup, backup setup)
  - Premium: 2 (updates, USB creation)
  - Utility: 1 (uninstall)
  - Helpers: 1 (shared functions)

## [0.0.9] - 2026-01-XX (Pre-Release)

### Added
- P53 optimization (GPU-P, NVIDIA Container Toolkit)
- Application layer structure (services/voice_watcher/)
- Environment variable centralization (.env)
- Ollama model location customization (F:\DOCK\.ollama)

### Changed
- Model stack updated to P53 optimized (granite4:3b, qwen2.5-coder:3b, qwen3-vl:2b, nomic-embed-text)
- VM storage defaults to D: drive
- Python dependencies pinned (crewai==0.30.11, langchain==0.1.20)

## [0.0.8] - 2026-01-XX (Pre-Release)

### Added
- Script audit and improvements
- Disk space validation
- Docker post-install verification
- GPU validation
- Download resume capability
- Email/Slack notification framework
- Restic auto-installation

## [0.0.7] - 2026-01-XX (Pre-Release)

### Added
- Documentation consolidation and renumbering
- Installation verification checklist
- Quick diagnostics guide
- Common failures documentation

## [0.0.6] - 2026-01-XX (Pre-Release)

### Added
- Linux VM installer script
- Windows VM host setup script
- GPU passthrough configuration
- Creator Mode documentation

## [0.0.5] - 2026-01-XX (Pre-Release)

### Added
- Core Docker Compose configuration
- 10 core services
- Environment variable system
- Basic automation scripts

## [0.0.1] - 2026-01-XX (Initial)

### Added
- Project structure
- Basic documentation
- Initial concept and design

---

## Version History Summary

- **0.1.0** (Current): Beta release - Single installation method, all critical features complete
- **0.0.9**: P53 optimizations, application layer
- **0.0.8**: Script improvements, validation
- **0.0.7**: Documentation consolidation
- **0.0.6**: VM-based installation
- **0.0.5**: Core infrastructure
- **0.0.1**: Initial project

## Version Numbering

Following semantic versioning (0.x.y):
- **0.x.y** = Pre-1.0 releases (beta/alpha)
- **x** = Major feature additions or architectural changes
- **y** = Minor improvements, bug fixes, documentation

**Current Version**: **0.1.0** (Beta Release)

---

**Note**: This changelog replaces the old `BUS_SERVER_REPO/docs/7.3_CHANGELOG.md` which was version 1.0 focused. This new changelog tracks actual development progress from 0.x through to 1.0.

