#!/bin/bash
################################################################################
# BACKUP-CONFIGS.SH - Automated Backup for ARK Configuration
# Part of: Project Nomad (ARK Node)
# Purpose: Backup .env, docker-compose.yml, and critical configs
# Target: /mnt/dock/backups/ark-configs/
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         ARK CONFIGURATION BACKUP                              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify mount
if ! mountpoint -q /mnt/dock; then
    echo -e "${RED}ERROR: /mnt/dock is NOT mounted!${NC}"
    echo -e "${RED}Cannot backup - would fill local VM disk.${NC}"
    exit 1
fi

# Setup backup directory
BACKUP_DIR="/mnt/dock/backups/ark-configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"
ARK_ROOT="/opt/ark"

echo -e "${YELLOW}[1/4] Creating backup directory...${NC}"
mkdir -p "$BACKUP_PATH"
echo -e "${GREEN}✓ Backup location: $BACKUP_PATH${NC}"
echo ""

# Backup critical files
echo -e "${YELLOW}[2/4] Backing up configuration files...${NC}"

# Docker Compose
if [ -f "$ARK_ROOT/docker-compose.yml" ]; then
    cp "$ARK_ROOT/docker-compose.yml" "$BACKUP_PATH/docker-compose.yml"
    echo -e "${GREEN}✓ docker-compose.yml${NC}"
fi

# Environment file (if exists)
if [ -f "$ARK_ROOT/.env" ]; then
    cp "$ARK_ROOT/.env" "$BACKUP_PATH/.env"
    echo -e "${GREEN}✓ .env${NC}"
fi

# Vessel secrets (if exists)
if [ -f "$ARK_ROOT/vessel_secrets.env" ]; then
    cp "$ARK_ROOT/vessel_secrets.env" "$BACKUP_PATH/vessel_secrets.env"
    echo -e "${GREEN}✓ vessel_secrets.env${NC}"
fi

# GitHub Actions workflow
if [ -d "$ARK_ROOT/.github/workflows" ]; then
    mkdir -p "$BACKUP_PATH/.github/workflows"
    cp -r "$ARK_ROOT/.github/workflows"/* "$BACKUP_PATH/.github/workflows/"
    echo -e "${GREEN}✓ GitHub Actions workflows${NC}"
fi

# Homepage configs (critical dashboard config)
if [ -d "$ARK_ROOT/configs/homepage" ]; then
    cp -r "$ARK_ROOT/configs/homepage" "$BACKUP_PATH/homepage-configs"
    echo -e "${GREEN}✓ Homepage configurations${NC}"
fi

echo ""

# Create metadata
echo -e "${YELLOW}[3/4] Creating backup metadata...${NC}"
cat > "$BACKUP_PATH/backup-info.txt" << EOF
ARK Configuration Backup
========================
Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Hostname: $(hostname)
Git Commit: $(cd "$ARK_ROOT" && git rev-parse HEAD 2>/dev/null || echo "Not a git repo")
Git Branch: $(cd "$ARK_ROOT" && git branch --show-current 2>/dev/null || echo "N/A")

Files Backed Up:
- docker-compose.yml
- .env (if exists)
- vessel_secrets.env (if exists)
- .github/workflows/
- configs/homepage/

Restore Instructions:
1. Stop services: cd /opt/ark && docker compose down
2. Restore files: cp -r $BACKUP_PATH/* /opt/ark/
3. Restart services: docker compose up -d
EOF
echo -e "${GREEN}✓ Metadata created${NC}"
echo ""

# Create compressed archive
echo -e "${YELLOW}[4/4] Creating compressed archive...${NC}"
ARCHIVE_NAME="ark-configs-$TIMESTAMP.tar.gz"
cd "$BACKUP_DIR"
tar -czf "$ARCHIVE_NAME" "$TIMESTAMP" 2>/dev/null
ARCHIVE_SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
echo -e "${GREEN}✓ Archive created: $ARCHIVE_NAME ($ARCHIVE_SIZE)${NC}"
echo ""

# Cleanup old backups (keep last 10)
echo -e "${YELLOW}Cleaning up old backups (keeping last 10)...${NC}"
cd "$BACKUP_DIR"
ls -t | grep "^ark-configs-.*\.tar\.gz$" | tail -n +11 | while read -r old_backup; do
    echo "  Removing: $old_backup"
    rm -f "$old_backup"
done
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# Summary
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    BACKUP COMPLETE                            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Backup Location: ${BLUE}$BACKUP_PATH${NC}"
echo -e "Archive: ${BLUE}$BACKUP_DIR/$ARCHIVE_NAME${NC} ($ARCHIVE_SIZE)"
echo ""
echo -e "${GREEN}✓ Configuration backup successful!${NC}"
echo ""
