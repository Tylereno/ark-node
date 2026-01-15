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

## Optional Setup

### Vaultwarden - Password Manager
**URL:** http://192.168.26.8:8082

**Setup:** Create first account
- Use to store all service passwords
- Install Bitwarden browser extension (optional)

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

**Recommended Downloads:**
- `wikipedia_en_simple_all_maxi` (~100MB) - Small test
- `wikipedia_en_all_maxi` (~90GB) - Full English Wikipedia
- `wikimed_en` (~10GB) - Medical reference
- `ted_en` (~20GB) - TED Talks

**Note:** Large downloads - use fast connection or download overnight

---

## Service Status Verification

After setup, verify all services:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

All containers should show "Up" or "healthy" status.

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

---

## Support

- Documentation: `/mnt/dock/docs/`
- Changelog: `/opt/ark/CHANGELOG.md`
- Repository: `/opt/ark/` (git v1.0.0)
