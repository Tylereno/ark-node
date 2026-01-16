# ARK Node Folder Structure

## 📁 Professional Organization

Your ARK Node now follows industry-standard folder organization.

## Root Directory

**Essential Files Only:**
- `README.md` - Main project documentation
- `MASTER_LIST.txt` - Essential files definition
- `crewai-system-prompt.md` - CrewAI agent configuration
- `docker-compose.yml` - Service stack configuration
- `.env` - Environment variables (gitignored)
- `vessel_secrets.env` - Secrets (gitignored)
- `ark-manager.sh` - Convenience wrapper (calls scripts/ark-manager.sh)

## Directory Structure

```
/opt/ark/
│
├── docs/                          # All documentation
│   ├── CAPTAINS_LOG.md            # Operation log
│   ├── CHANGELOG.md               # Version history
│   ├── ARK_MANAGER_GUIDE.md       # Manager documentation
│   ├── INDUSTRIAL_GRADE_SETUP.md  # Setup guide
│   ├── TRAEFIK_DOMAINS.md         # Domain reference
│   ├── BACKUP_SYSTEM.md           # Backup guide
│   ├── RALPH_LOOP_COMPLETE.md     # Ralph Loop guide
│   ├── ROOT_CLEANUP_COMPLETE.md   # Cleanup summary
│   └── archive/                   # Old documentation
│       └── [39 archived files]
│
├── scripts/                       # All scripts
│   ├── ark-manager.sh             # Master control script
│   ├── backup-configs.sh          # Configuration backup
│   ├── cleanup_root.sh            # Root folder cleanup
│   ├── auto-cleanup.sh            # Automatic cleanup
│   ├── update-changelog.sh        # Changelog generator
│   ├── setup-ralph-cron.sh        # Cron job setup
│   └── [other utility scripts]
│
├── configs/                       # Service configurations
│   ├── homepage/                  # Homepage configs
│   ├── jellyfin/                  # Jellyfin configs
│   └── [other service configs]
│
├── logs/                          # Runtime logs
│   └── manager.log                # ARK Manager log
│
├── .github/workflows/             # CI/CD
│   └── deploy-ssh.yml             # Deployment workflow
│
└── [configuration files]
```

## File Organization Rules

### Root Directory
- **Keep**: Only essential files (README, configs, wrappers)
- **Move to /docs**: All documentation
- **Move to /scripts**: All executable scripts
- **Archive**: Old/redundant files

### Documentation
- **Active docs**: `/docs/` (current documentation)
- **Archived docs**: `/docs/archive/` (old status reports, phase docs)

### Scripts
- **All scripts**: `/scripts/` (centralized location)
- **Wrapper**: Root `ark-manager.sh` for convenience

## Auto-Cleanup

The `auto-cleanup.sh` script runs automatically after each deployment to:
- Move stray markdown files to archive
- Move stray scripts to /scripts
- Keep root folder clean

## Benefits

✅ **Clean Sidebar** - Easy to see actual code  
✅ **Professional Structure** - Industry-standard organization  
✅ **Easy Navigation** - Everything in logical locations  
✅ **Auto-Maintained** - Cleanup runs automatically  
✅ **GitHub Sync** - Structure matches production  

---

**Your ARK now has a professional, maintainable structure!** 🎊
