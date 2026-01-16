# ARK Configuration Backup System

## 🎯 Overview

Your ARK node now has automated backup protection for all critical configuration files. Backups are stored on your persistent storage (`/mnt/dock`) so they survive container restarts and system updates.

## 📦 What Gets Backed Up

- `docker-compose.yml` - Your entire service stack configuration
- `.env` - Environment variables (if exists)
- `vessel_secrets.env` - Secret credentials (if exists)
- `.github/workflows/` - GitHub Actions deployment scripts
- `configs/homepage/` - Homepage dashboard configurations

## 🔄 Backup Triggers

### 1. Automatic (After Each Deployment)
Every time GitHub Actions successfully deploys, a backup is automatically created.

### 2. Manual Backup
Run anytime:
```bash
/opt/ark/scripts/backup-configs.sh
```

### 3. Scheduled Daily Backups (Optional)
To enable daily backups at 2 AM:
```bash
/opt/ark/scripts/setup-backup-cron.sh
```

## 📁 Backup Location

All backups are stored in:
```
/mnt/dock/backups/ark-configs/
```

Each backup includes:
- Timestamped directory with all files
- Compressed `.tar.gz` archive
- `backup-info.txt` with metadata and restore instructions

## 🔍 Viewing Backups

```bash
# List all backups
ls -lh /mnt/dock/backups/ark-configs/

# View backup metadata
cat /mnt/dock/backups/ark-configs/YYYYMMDD_HHMMSS/backup-info.txt
```

## 🔄 Restoring from Backup

1. **Stop services:**
   ```bash
   cd /opt/ark
   docker compose down
   ```

2. **Restore files:**
   ```bash
   # Extract the backup
   cd /mnt/dock/backups/ark-configs
   tar -xzf ark-configs-YYYYMMDD_HHMMSS.tar.gz
   
   # Copy files back
   cp -r YYYYMMDD_HHMMSS/* /opt/ark/
   ```

3. **Restart services:**
   ```bash
   cd /opt/ark
   docker compose up -d
   ```

## 🧹 Automatic Cleanup

The backup system automatically keeps only the **last 10 backups** to prevent disk space issues. Older backups are automatically removed.

## 📊 Backup Size

Typical backup size: **~100-200KB** (compressed)
- Very lightweight
- Stored on persistent storage
- Won't impact system performance

## ✅ Verification

Test your backup system:
```bash
# Run manual backup
/opt/ark/scripts/backup-configs.sh

# Verify it was created
ls -lh /mnt/dock/backups/ark-configs/ | tail -5
```

## 🚨 Important Notes

- Backups are stored on `/mnt/dock` (persistent storage)
- Backups do NOT include:
  - Docker volumes (data is already persistent)
  - Large media files
  - Downloaded ZIM files
- Only configuration files are backed up
- Secrets are included - keep backups secure!

## 🎉 Benefits

✅ **Zero-touch backups** - Automatic after each deployment  
✅ **Lightweight** - Only configs, not data  
✅ **Persistent** - Stored on your mounted storage  
✅ **Easy restore** - Simple copy commands  
✅ **Auto-cleanup** - Never runs out of space  

---

**Your ARK is now bulletproof!** 🛡️
