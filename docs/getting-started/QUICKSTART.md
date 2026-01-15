# ARK Quickstart Guide

**Get your Nomad Node running in 10 minutes.**

---

## Prerequisites

Before you begin, ensure you have:

- ✅ Ubuntu 24.04 LTS (or similar Linux distro)
- ✅ Docker Engine 20.10+ installed
- ✅ Docker Compose v2 installed
- ✅ 50GB+ free storage (500GB+ recommended for full content)
- ✅ Static IP configured (recommended: 192.168.26.8)
- ✅ Internet connection (for initial setup and downloads)

---

## Installation (3 Steps)

### Step 1: Clone the Repository

```bash
# Clone to /opt/ark (recommended location)
sudo git clone https://github.com/YOUR_USERNAME/ark /opt/ark
cd /opt/ark

# Set ownership
sudo chown -R $USER:$USER /opt/ark
```

### Step 2: Configure Storage (Optional)

If you have a separate storage mount for large media files:

```bash
# Ensure your storage is mounted
sudo mkdir -p /mnt/dock
# Mount your storage (adjust for your setup)
# Example: sudo mount //192.168.26.1/DOCK /mnt/dock -t cifs -o credentials=/etc/cifs-credentials
```

Or use local storage by editing `docker-compose.yml` to change `/mnt/dock` paths to `/opt/ark/data`.

### Step 3: Deploy the Stack

```bash
# Start all 16 services
docker compose up -d

# Check status (wait ~60 seconds for all to start)
docker ps

# View logs if needed
docker compose logs -f
```

---

## First Access

Open your browser and visit:

**🏠 Main Dashboard:** http://192.168.26.8:3000

This is your Homepage - your command center for all services.

**Default Credentials:** 
- Username: `admin`
- Password: `arknode123`

---

## Essential Setup Wizards

Complete these setup wizards on first access:

### 1. Portainer (Container Management)
- URL: http://192.168.26.8:9000
- Create admin account (minimum 12 characters)
- Select "Get Started" for local environment

### 2. Home Assistant (Automation)
- URL: http://192.168.26.8:8123
- Complete onboarding wizard
- Create your admin account
- Skip integrations for now

### 3. Jellyfin (Media Server)
- URL: http://192.168.26.8:8096
- Set language and create admin user
- Add media libraries pointing to `/media` paths
- Skip metadata providers (works offline)

### 4. Vaultwarden (Password Manager)
- URL: http://192.168.26.8:8082
- Create your first account (this becomes admin)
- Install Bitwarden browser extension
- Point it to your Vaultwarden instance

### 5. Gitea (Git Repository)
- URL: http://192.168.26.8:3002
- Initial config is pre-set (SQLite database)
- Create admin account on first visit
- Start pushing your code!

### 6. Open WebUI (AI Interface)
- URL: http://192.168.26.8:3001
- Create account (first user is admin)
- Go to Settings > Models
- Pull your first model: `granite4:3b` (lightweight, 2GB)

---

## Download Offline Content

ARK includes scripts to download offline knowledge:

```bash
# Wikipedia (90GB, run overnight)
nohup /opt/ark/scripts/download-wikipedia.sh --unattended > /tmp/wikipedia.log 2>&1 &

# Essential ZIM pack (WikiMed, WikiHow, TED - 14GB)
/opt/ark/scripts/download-additional-zims.sh --essential

# Survival guides (PDFs)
/opt/ark/scripts/download-survival.sh

# Check download progress
/opt/ark/scripts/check-downloads.sh
```

---

## Verify Everything Works

Run this health check:

```bash
# All containers should show "Up" status
docker ps

# Check Homepage is accessible
curl -s http://192.168.26.8:3000 | grep -q "Homepage" && echo "✓ Homepage OK"

# Check Ollama AI is ready
curl -s http://192.168.26.8:11434/api/tags | grep -q "models" && echo "✓ Ollama OK"

# Check storage mount (if using /mnt/dock)
mountpoint -q /mnt/dock && echo "✓ Storage mounted" || echo "⚠ Storage not mounted"
```

---

## Next Steps

### Secure Your Setup
- Change default passwords in `docker-compose.yml`
- Set up Tailscale for secure remote access
- Configure firewall rules

### Add Content
- Upload media to Jellyfin
- Add audiobooks to Audiobookshelf
- Download AI models via Open WebUI
- Sync files with Syncthing

### Customize
- Edit Homepage config: `/opt/ark/configs/homepage/services.yaml`
- Add custom bookmarks and widgets
- Configure Home Assistant automations

---

## Troubleshooting

**Container won't start?**
```bash
# View logs for specific service
docker logs <container-name>

# Restart a service
docker compose restart <service-name>

# Restart everything
docker compose restart
```

**Out of disk space?**
```bash
# Check usage
df -h /opt/ark
df -h /mnt/dock

# Clean unused images
docker system prune -a
```

**Can't access a service?**
```bash
# Check if port is listening
sudo netstat -tlnp | grep <port>

# Check if container is healthy
docker ps --filter "name=<container>"
```

**Ollama AI not responding?**
```bash
# Check if model is loaded
docker exec ollama ollama list

# Pull a small test model
docker exec ollama ollama pull granite4:3b

# Restart ollama
docker compose restart ollama
```

---

## Get Help

- 📖 **Full Documentation:** `/opt/ark/docs/`
- 🐛 **Known Issues:** `/opt/ark/CHANGELOG.md`
- 💬 **Community:** GitHub Discussions
- 📧 **Support:** GitHub Issues

---

## What's Running?

Here's what you just deployed:

| Service | Port | What It Does |
|---------|------|--------------|
| Homepage | 3000 | Your dashboard |
| Open WebUI | 3001 | Chat with AI |
| Gitea | 3002 | Git hosting |
| Traefik | 8080 | Reverse proxy |
| FileBrowser | 8081 | File manager |
| Vaultwarden | 8082 | Passwords |
| Kiwix | 8083 | Offline wiki |
| Jellyfin | 8096 | Media server |
| Home Assistant | 8123 | Automation |
| Syncthing | 8384 | File sync |
| Portainer | 9000 | Docker GUI |
| Ollama | 11434 | AI engine |
| Audiobookshelf | 13378 | Audiobooks |
| Code-Server | 8443 | VS Code |

---

**🎉 Welcome to ARK! Your digital life is now untethered.**

**Next:** Check out the [User Guide](../guides/USER_GUIDE.md) for detailed service walkthroughs.
