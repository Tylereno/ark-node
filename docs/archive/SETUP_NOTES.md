# ARK - First-Time Setup Notes

## Required Setup Steps

### 1. Portainer - Container Management
**URL:** http://192.168.26.8:9000/#!/init/admin

**Requirements:**
- Password must be **12+ characters** (Portainer requirement)
- Cannot use the standard 10-char password

**Recommended Credentials:**
- Username: `admin`
- Password: `Arknode123456` or `ArkNode2026!`

**Why:** Portainer enforces strong password policy for security.

---

### 2. Home Assistant - System Automation
**URL:** http://192.168.26.8:8123

**Setup:** Complete onboarding wizard
- Create owner account
- Set location/timezone
- Configure integrations (optional)

**Recommended Credentials:**
- Username: `admin`
- Password: `arknode123`

---

### 3. Jellyfin - Media Server
**URL:** http://192.168.26.8:8096

**Setup:** Complete setup wizard
- Set server name (e.g., "ARK Media Server")
- Create admin account
- Add media libraries (points to `/media`)

**Recommended Credentials:**
- Username: `admin`
- Password: `arknode123`

---

### 4. Audiobookshelf
**URL:** http://192.168.26.8:13378

**Setup:** Create root user
- Configure paths (defaults are fine)
- Create admin account

**Recommended Credentials:**
- Username: `admin`
- Password: `arknode123`

---

### 5. Gitea - Git Repository Server
**URL:** http://192.168.26.8:3002

**Setup:** Initial configuration wizard
- **Database Type:** SQLite3 (default, recommended)
- **Repository Root Path:** `/data/git/repositories` (default)
- **Git LFS Root Path:** `/data/git/lfs` (default)
- **Run As Username:** `git` (default)
- **Server Domain:** `192.168.26.8`
- **SSH Server Port:** `2222`
- **Gitea HTTP Listen Port:** `3000` (internal, mapped to 3002)
- **Gitea Base URL:** `http://192.168.26.8:3002/`

**Administrator Account:**
- Username: `admin`
- Password: `arknode123`
- Email: `admin@ark.local`

**Post-Setup:**
1. Login with admin credentials
2. Navigate to **Site Administration** > **Configuration**
3. Verify SSH clone URLs use port 2222
4. Test repository creation

**SSH Cloning:**
```bash
# Clone via SSH (requires SSH key setup in Gitea profile)
git clone ssh://git@192.168.26.8:2222/username/repo.git

# Clone via HTTP
git clone http://192.168.26.8:3002/username/repo.git
```

**Features:**
- Full Git repository hosting
- Issue tracking and project management
- Pull requests and code review
- Wiki and release management
- Webhook integrations

---

### 6. Code-Server - VS Code in Browser
**URL:** https://192.168.26.8:8443

**Setup:** Login with password
- **Password:** `arknode123`
- Browser will warn about self-signed certificate (this is normal)
- Click "Advanced" and proceed to site

**First-Time Configuration:**
1. Accept the self-signed certificate warning
2. Enter password: `arknode123`
3. Choose color theme and settings
4. Workspace is persistent at `/mnt/dock/data/code-server/workspace`

**Features:**
- Full VS Code experience in browser
- Extensions support (install via marketplace)
- Terminal access to container
- Git integration (can clone from Gitea)
- File synchronization with persistent storage

**Recommended Extensions:**
- Docker
- Python
- GitLens
- Markdown All in One
- YAML

**Usage Tips:**
```bash
# Access Code-Server workspace on host
cd /mnt/dock/data/code-server/workspace

# Edit files directly or via web interface
# All changes are persistent across container restarts
```

**Security Note:** Code-Server runs on HTTPS (port 8443) with a self-signed certificate. For production use, consider setting up a proper SSL certificate via Traefik.

---

## Optional Setup

### Vaultwarden - Password Manager
**URL:** http://192.168.26.8:8082

**Setup:** Create first account
- Use to store all service passwords
- Install Bitwarden browser extension (optional)

---

### Tailscale - Secure Remote Access
**Status:** Requires authentication

**Setup:**
```bash
# View authentication URL
docker logs tailscale

# Or run authentication command
docker exec tailscale tailscale up

# Follow the URL to authenticate with your Tailscale account
```

**Post-Setup:**
- All ARK services accessible via Tailscale network
- Use Tailscale IP instead of 192.168.26.8 when remote
- Zero-trust secure access from anywhere

---

## Known Issues & Workarounds

### FileBrowser - Authentication Issue
**Problem:** Default credentials don't work (403 Forbidden)

**Solution 1 - Database Reset:**
```bash
docker stop filebrowser
sudo docker run --rm -v /opt/ark/configs/filebrowser:/config \
  filebrowser/filebrowser:latest config init --database /config/database/filebrowser.db
docker start filebrowser
# Try: admin/admin
```

**Solution 2 - Fresh Start:**
```bash
docker stop filebrowser
sudo rm -rf /var/lib/docker/volumes/*/filebrowser.db
docker start filebrowser
# Default: admin/admin
```

---

### Kiwix - Offline Wikipedia
**Status:** Exits immediately if no .zim files present (by design)

**Setup Required:**
1. Download .zim files from https://download.kiwix.org/zim/
2. Place in `/mnt/dock/data/media/kiwix/`
3. Restart Kiwix: `docker restart kiwix`

**Or use the automated script:**
```bash
# Interactive mode
/opt/ark/scripts/download-wikipedia.sh

# Unattended mode (downloads 90GB+ content)
/opt/ark/scripts/download-wikipedia.sh --unattended
```

**Recommended Downloads:**
- `wikipedia_en_simple_all_maxi` (~100MB) - Small test
- `wikipedia_en_all_maxi` (~90GB) - Full English Wikipedia
- `wikimed_en` (~10GB) - Medical reference
- `ted_en` (~20GB) - TED Talks

**Note:** Large downloads - use fast connection or download overnight

---

### Gitea - SSH Key Setup
**Problem:** Need SSH access to repositories

**Solution:**
1. Generate SSH key (if you don't have one):
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

2. Copy public key:
```bash
cat ~/.ssh/id_ed25519.pub
```

3. In Gitea web UI:
   - Click profile icon > **Settings**
   - Navigate to **SSH / GPG Keys**
   - Click **Add Key**
   - Paste public key and save

4. Test connection:
```bash
ssh -T git@192.168.26.8 -p 2222
```

---

## Service Status Verification

After setup, verify all services:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

All containers should show "Up" or "healthy" status.

**Expected service count:** 16 containers

---

## Access Dashboard

Main dashboard: http://192.168.26.8:3000

All service links available at: `/mnt/dock/ARK_NODE_LINKS.txt`

---

## Troubleshooting

**Container won't start:**
```bash
docker logs <container-name>
```

**Reset a service:**
```bash
docker restart <container-name>
```

**Full stack restart:**
```bash
cd /opt/ark
docker-compose restart
```

**Check service health:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## Post-Setup Checklist

- [ ] Portainer admin created (12+ char password)
- [ ] Home Assistant onboarding complete
- [ ] Jellyfin media libraries configured
- [ ] Audiobookshelf root user created
- [ ] Gitea admin account initialized
- [ ] Code-Server password tested (arknode123)
- [ ] Tailscale authenticated (if using remote access)
- [ ] Vaultwarden first account created
- [ ] All 16 services showing "Up" status

---

## Support

- Documentation: `/mnt/dock/docs/`
- Changelog: `/opt/ark/CHANGELOG.md`
- Repository: `/opt/ark/` (git v1.1.0)
