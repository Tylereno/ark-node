#!/bin/bash
################################################################################
# SETUP-BACKUP-CRON.SH - Setup Automated Daily Backups
# Part of: Project Nomad (ARK Node)
# Purpose: Install cron job for daily configuration backups
################################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         SETUP AUTOMATED DAILY BACKUPS                         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

SCRIPT_PATH="/opt/ark/scripts/backup-configs.sh"
CRON_JOB="0 2 * * * $SCRIPT_PATH >> /opt/ark/logs/backup.log 2>&1"

# Check if script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}ERROR: Backup script not found at $SCRIPT_PATH${NC}"
    exit 1
fi

# Create logs directory
mkdir -p /opt/ark/logs

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
    echo -e "${YELLOW}⚠ Cron job already exists. Updating...${NC}"
    crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" | crontab -
fi

# Add cron job (runs daily at 2 AM)
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✓ Daily backup cron job installed${NC}"
echo -e "  Schedule: Daily at 2:00 AM"
echo -e "  Script: $SCRIPT_PATH"
echo -e "  Logs: /opt/ark/logs/backup.log"
echo ""

# Show current crontab
echo -e "${BLUE}Current crontab:${NC}"
crontab -l | grep -E "(backup|ARK)" || echo "  (No ARK-related cron jobs found)"
echo ""

echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
