# 🚀 ARK NODE - Quick Start Guide

**Version**: 0.3.0 (RALPH Protocol Complete)  
**Status**: ✅ Ready for Deployment  
**Date**: 2026-01-14

---

## 🎯 What Just Happened?

Ralph (the Autonomous Dev Lead) just completed **17 tasks** to transform your E:\DOCK folder into a fully operational **ARK NODE** - "Civilization in a Box."

### ✅ What's Ready
- **13 Services** configured and ready to deploy
- **One-Click Launcher** (`START.bat`)
- **5.77GB of AI models** preserved and organized
- **Golden Credentials** applied across all services
- **Automatic hosts file injection** for *.ark.local routing

---

## 🔑 Golden Credentials

Use these everywhere:

```
Username: admin
Password: arknode123

System User: nomad
System Password: arknode123
```

---

## 🚦 Quick Start (3 Steps)

### Step 1: Create the VM
Open **PowerShell as Administrator**:

```powershell
E:\DOCK\scripts\host\1_setup_hyperv.ps1
```

This will:
- Enable Hyper-V (if needed)
- Create "ArkBridge" virtual switch
- Create "ARK-NODE-01" VM
- Attach Ubuntu ISO
- Configure auto-start

**Time**: ~5 minutes

---

### Step 2: Install Ubuntu
1. Start the VM:
   ```powershell
   Start-VM -Name ARK-NODE-01
   vmconnect localhost ARK-NODE-01
   ```

2. Install Ubuntu Server 24.04 LTS:
   - Username: `nomad`
   - Password: `arknode123`
   - ✅ Enable OpenSSH server

**Time**: ~15 minutes

---

### Step 3: Bootstrap the VM
Inside the Ubuntu VM (via SSH or console):

```bash
# Copy the bootstrap script to the VM
# Option A: Via SCP from Windows
scp E:\DOCK\scripts\vm\bootstrap.sh nomad@<vm-ip>:~/

# Option B: Via git clone (if you have internet)
git clone <your-repo-url> ~/ark
cd ~/ark/scripts/vm

# Run bootstrap
sudo bash bootstrap.sh
```

This will:
- Install Docker & Docker Compose
- Mount E:\DOCK to /mnt/dock
- Load cached Docker images (if available)
- Create directory structure

**Time**: ~10 minutes

---

### Step 4: Share E:\DOCK from Windows
1. Right-click `E:\DOCK` → Properties → Sharing → Advanced Sharing
2. Share name: `DOCK`
3. Permissions: Grant `nomad` user **Full Control**
4. Click OK

---

### Step 5: Launch ARK NODE
Double-click:

```
E:\DOCK\START.bat
```

This will:
- ✅ Unlock file permissions
- ✅ Start the VM (if not running)
- ✅ Detect VM IP address
- ✅ Inject *.ark.local entries into hosts file
- ✅ Wait for services to come online
- ✅ Launch browser to http://hub.ark.local

**Time**: ~2 minutes (first launch may take longer)

---

## 🌐 Access Your Services

Once `START.bat` completes, open your browser:

| Service | URL | Description |
|---------|-----|-------------|
| **Dashboard** | http://hub.ark.local | Main control panel |
| **AI Chat** | http://openwebui.ark.local | Chat with AI models |
| **Movies** | http://jellyfin.ark.local | Media server |
| **Files** | http://filebrowser.ark.local | Web file manager |
| **Passwords** | http://vaultwarden.ark.local | Password manager |
| **Containers** | http://portainer.ark.local | Docker management |
| **Wikipedia** | http://kiwix.ark.local | Offline reference |
| **Smart Home** | http://homeassistant.ark.local | IoT control |

**Full list**: See `EXECUTION_LOG.md`

---

## 📦 What's Included?

### The 13 Services
1. **Traefik** - Reverse proxy
2. **Portainer** - Container management
3. **Homepage** - Dashboard
4. **Autoheal** - Container watchdog
5. **Ollama** - AI model API
6. **Open WebUI** - AI chat interface
7. **Jellyfin** - Media server
8. **Audiobookshelf** - Audiobooks & podcasts
9. **FileBrowser** - File manager
10. **Syncthing** - Device sync
11. **Vaultwarden** - Password manager
12. **Kiwix** - Offline Wikipedia
13. **Home Assistant** - Smart home control

### Bonus
- **Voice Watcher** - Transcribes audio files with Whisper + Ollama

---

## 🛠️ Scripts Reference

### Host Scripts (Windows)
- `scripts/host/0_unlock.ps1` - Emergency permission fix
- `scripts/host/1_setup_hyperv.ps1` - Create VM
- `scripts/host/2_start_ark.ps1` - Start VM & inject hosts
- `scripts/host/_helpers.ps1` - Helper functions

### VM Scripts (Ubuntu)
- `scripts/vm/bootstrap.sh` - Install Docker & mount E:\DOCK
- `scripts/vm/backup_configs.sh` - Backup configs to E:\DOCK

### Utilities
- `scripts/generate_env.py` - Generate config/.env with Golden Credentials
- `START.bat` - One-click launcher (Windows)

---

## 📊 Directory Structure

```
E:\DOCK/
├── START.bat                    # ← Double-click to launch
├── scripts/
│   ├── host/                    # Windows scripts
│   └── vm/                      # Ubuntu scripts
├── config/
│   └── .env                     # Golden config (auto-generated)
├── data/
│   ├── models/                  # Ollama models (5.77GB)
│   ├── media/                   # Movies, audiobooks, etc.
│   ├── sync/                    # Syncthing folder
│   └── _backup/                 # Nightly backups
├── BUS_SERVER_REPO/
│   ├── docker-compose.yml       # The 13 services
│   └── homepage/                # Dashboard config
└── services/
    └── voice_watcher/           # Audio transcription
```

---

## 🔧 Troubleshooting

### VM won't start
```powershell
Get-VM -Name ARK-NODE-01
Start-VM -Name ARK-NODE-01
```

### Can't access *.ark.local
Run as Administrator:
```powershell
E:\DOCK\scripts\host\2_start_ark.ps1
```

### Services not starting
Inside VM:
```bash
cd /opt/ark
docker compose logs
```

### Mount failed
Inside VM:
```bash
sudo mount /mnt/dock
# Check /etc/ark-smb-credentials
```

---

## 📚 Documentation

- **Full Execution Log**: `EXECUTION_LOG.md`
- **Changelog**: `CHANGELOG.md`
- **Detailed Docs**: `BUS_SERVER_REPO/docs/`

---

## 🎓 What Ralph Did

Ralph executed the **RALPH Protocol** to:
1. ✅ Fix permissions (Phase 0)
2. ✅ Create VM infrastructure (Phase 1)
3. ✅ Configure 13 services (Phase 2)
4. ✅ Build one-click launcher (Phase 3)

**Total**: 98 files changed, 13,299 lines added

---

## 🚀 Next Steps

1. Run `1_setup_hyperv.ps1` to create the VM
2. Install Ubuntu Server in the VM
3. Run `bootstrap.sh` inside the VM
4. Share E:\DOCK from Windows
5. Double-click `START.bat`

**You're 5 steps away from "Civilization in a Box"!**

---

## 🆘 Need Help?

- Check `EXECUTION_LOG.md` for detailed logs
- Check `BUS_SERVER_REPO/docs/4.2_COMMON_FAILURES.md`
- All scripts have built-in error messages

---

**Built by Ralph, the Autonomous Dev Lead**  
*Protocol Version: 0.3.0*  
*Date: 2026-01-14*

🎉 **Welcome to ARK NODE!**
