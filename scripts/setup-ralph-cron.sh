#!/bin/bash
################################################################################
# SETUP-RALPH-CRON.SH - Setup Automated Ralph Loop Cron Job
# Part of: Project Nomad (ARK Node)
# Purpose: Install cron job for automated daily Ralph Loops
################################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} ${CYAN}      SETUP AUTOMATED RALPH LOOP CRON JOB${NC}${BLUE}                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

ARK_DIR="/opt/ark"
SCRIPT_PATH="$ARK_DIR/ark-manager.sh"
LOG_FILE="$ARK_DIR/logs/ralph-cron.log"

# Verify script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}ERROR: ARK Manager script not found at $SCRIPT_PATH${NC}"
    exit 1
fi

# Create logs directory
mkdir -p "$ARK_DIR/logs"

# Default schedule: Daily at 4 AM
SCHEDULE="${1:-0 4 * * *}"

# Cron job command
CRON_JOB="$SCHEDULE cd $ARK_DIR && $SCRIPT_PATH loop >> $LOG_FILE 2>&1"

echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Script: ${CYAN}$SCRIPT_PATH${NC}"
echo -e "  Schedule: ${CYAN}$SCHEDULE${NC} (Daily at 4:00 AM)"
echo -e "  Log File: ${CYAN}$LOG_FILE${NC}"
echo ""

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH.*loop"; then
    echo -e "${YELLOW}⚠ Cron job already exists. Updating...${NC}"
    crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH.*loop" | crontab -
fi

# Add cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✓ Automated Ralph Loop cron job installed${NC}"
echo ""

# Show current crontab entries
echo -e "${CYAN}Current ARK-related cron jobs:${NC}"
crontab -l 2>/dev/null | grep -E "(ark-manager|RALPH)" || echo "  (No ARK-related cron jobs found)"
echo ""

# Show how to view logs
echo -e "${CYAN}To view Ralph Loop logs:${NC}"
echo -e "  ${YELLOW}tail -f $LOG_FILE${NC}"
echo ""

# Show how to disable
echo -e "${CYAN}To disable automated Ralph Loop:${NC}"
echo -e "  ${YELLOW}crontab -e${NC}  (then remove the line with ark-manager.sh)"
echo ""

echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${CYAN}Your ARK will now perform automated Ralph Loops every day at 4 AM.${NC}"
echo ""
