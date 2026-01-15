# ARK - Autonomous Resilience Kit

**Version:** 1.1.0  
**Platform:** Nomad Node  
**Status:** Production Ready

---

## What is ARK?

ARK (Autonomous Resilience Kit) is a self-hosted, off-grid capable software stack designed for the **Nomad Node** platform. It provides AI capabilities, media services, file management, and system automation in a single, cohesive deployment.

### The Stack

**16 containerized services** providing:
- 🤖 **AI & LLM**: Ollama + Open WebUI
- 📺 **Media**: Jellyfin, Audiobookshelf  
- 📁 **Storage**: FileBrowser, Syncthing, Vaultwarden
- 🏠 **Automation**: Home Assistant
- 🌐 **Networking**: Traefik reverse proxy, Tailscale VPN
- 🔧 **Management**: Portainer, Homepage dashboard
- 📚 **Knowledge**: Kiwix (offline Wikipedia)
- 💻 **Development**: Gitea (Git hosting), Code-Server (VS Code)

---

## Quick Start

### Prerequisites
- Ubuntu 24.04 LTS (or similar)
- Docker Engine 20.10+
- Docker Compose v2
- 50GB+ free storage
- Static IP recommended

### Installation

```bash
# Clone the repository
git clone <repo-url> /opt/ark
cd /opt/ark

# Deploy the stack
docker-compose up -d

# Check status
docker ps
```

### Access

Once deployed, access the dashboard at:
- **Homepage**: http://192.168.26.8:3000
- **Service links**: See `ARK_NODE_LINKS.txt`

**Default credentials**: `admin` / `arknode123`

---

## Documentation

Complete documentation available at `/mnt/dock/docs/`:
- **Developer**: Architecture, API reference, testing
- **End-User**: Setup guides, troubleshooting, services
- **Technical**: V1 scope, roadmap, legal
- **Business**: Business model, feature comparison

---

## Architecture

### Storage Strategy
- **Local SSD** (`/opt/ark/configs`): SQLite databases, configs
- **CIFS Mount** (`/mnt/dock`): Media files, AI models, large data

### Network
- **Static IP**: 192.168.26.8
- **Domain**: *.ark.local (via local DNS)
- **Bridge network**: ark_network

### Services

| Service | Port | Purpose |
|---------|------|---------|
| Homepage | 3000 | Main dashboard |
| Open WebUI | 3001 | AI chat interface |
| Gitea | 3002 | Git repository hosting |
| Traefik | 8080 | Reverse proxy dashboard |
| FileBrowser | 8081 | File manager |
| Vaultwarden | 8082 | Password manager |
| Kiwix | 8083 | Offline Wikipedia |
| Jellyfin | 8096 | Media server |
| Home Assistant | 8123 | Automation |
| Syncthing | 8384 | File sync |
| Portainer | 9000 | Container management |
| Ollama | 11434 | LLM API |
| Audiobookshelf | 13378 | Audiobooks |
| Code-Server | 8443 | VS Code in browser |
| Gitea SSH | 2222 | Git SSH access |
| Tailscale | Host | Secure remote access |

---

## Configuration

### Ralph Protocol

ARK implements the **Ralph Protocol** for consistency:
- Standardized port assignments
- Golden credentials (admin/arknode123)
- Persistent storage paths
- Health monitoring
- Auto-healing

### First-Time Setup

After deployment, complete these setup wizards:
1. **Portainer** (http://192.168.26.8:9000) - Create admin (12+ chars)
2. **Home Assistant** (http://192.168.26.8:8123) - Onboarding wizard
3. **Jellyfin** (http://192.168.26.8:8096) - Media library setup
4. **Vaultwarden** (http://192.168.26.8:8082) - Create first account
5. **Gitea** (http://192.168.26.8:3002) - Initialize admin account
6. **Code-Server** (http://192.168.26.8:8443) - Enter password (arknode123)

---

## Known Issues

- **FileBrowser**: Auth database requires reset on first run
- **Kiwix**: Requires manual .zim file downloads
- **Portainer**: Requires 12+ character password
- **Tailscale**: May require authentication via `docker exec`

See `CHANGELOG.md` for complete list.

---

## Project Structure

```
/opt/ark/
├── docker-compose.yml       # Main stack definition
├── deploy.sh               # Deployment script
├── configs/                # Service configurations
│   ├── homepage/          # Dashboard config
│   ├── portainer/         # Container management data
│   ├── jellyfin/          # Media server config
│   ├── gitea/             # Git server config
│   ├── code-server/       # VS Code config
│   └── ...
├── scripts/               # Utility scripts
│   ├── download-wikipedia.sh
│   ├── download-survival.sh
│   ├── download-maps.sh
│   ├── download-books.sh
│   ├── check-downloads.sh
│   └── RESURRECTION.sh    # Service deployment script
├── VERSION                # Semantic version
├── CHANGELOG.md           # Version history
└── README.md              # This file

/mnt/dock/                 # CIFS shared storage
├── data/                  # Service data
│   ├── media/            # Media files
│   ├── models/           # Ollama AI models
│   └── sync/             # Syncthing shared folders
└── docs/                  # Complete documentation (42 files)
```

---

## Contributing

See `CONTRIBUTING.md` for guidelines.

---

## Project Nomad

**ARK** is the software component of **Project Nomad**, a mission to provide resilient, off-grid capable computing for digital nomads and remote locations.

- **Project Nomad**: The mission (off-grid resilience)
- **ARK**: The software (this repository)
- **Nomad Node**: The hardware platform (VM/physical device)

Learn more: [tylereno.me](https://tylereno.me)

---

## License

See `LICENSE` file for details.

---

## Support

- **Documentation**: `/mnt/dock/docs/`
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

**Built with ❤️ for digital nomads everywhere.**

## Content Download Scripts

ARK includes automated content acquisition scripts in `/opt/ark/scripts/`:

### Available Scripts

**download-wikipedia.sh** - Download Wikipedia ZIM files for Kiwix
```bash
# Interactive mode
/opt/ark/scripts/download-wikipedia.sh

# Unattended mode (90GB, run overnight)
/opt/ark/scripts/download-wikipedia.sh --unattended
```

**download-survival.sh** - Download survival and emergency guides
```bash
/opt/ark/scripts/download-survival.sh --all
```

**download-maps.sh** - Download OpenStreetMap data for OsmAnd
```bash
/opt/ark/scripts/download-maps.sh --starter
```

**download-books.sh** - Download Project Gutenberg and educational content
```bash
/opt/ark/scripts/download-books.sh --essential
```

**check-downloads.sh** - Monitor active downloads and content status
```bash
/opt/ark/scripts/check-downloads.sh
```

### Running Downloads in Background

For large downloads (like Wikipedia), use nohup:
```bash
nohup /opt/ark/scripts/download-wikipedia.sh --unattended > /tmp/wikipedia-download.log 2>&1 &

# Check progress
tail -f /tmp/wikipedia-download.log
```
