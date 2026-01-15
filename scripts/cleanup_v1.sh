#!/bin/bash
#
# ARK Cleanup Script v1.0
# Purpose: Organize repository structure and archive historical documentation
# Date: 2026-01-15
# Author: Ralph Protocol (QA Engineer)
#
# This script performs the following actions:
#   1. Creates archive and backup directories
#   2. Moves historical documentation to archive
#   3. Moves backup files to backups directory
#   4. Consolidates duplicate scripts
#   5. Sets proper permissions on all scripts
#   6. Reports cleanup status
#

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory
ARK_ROOT="/opt/ark"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ARK Repository Cleanup v1.0${NC}"
echo -e "${BLUE}RALPH PROTOCOL: OPERATION GOLD MASTER${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Warning: Not running as root. Some operations may fail.${NC}"
    echo -e "${YELLOW}Consider running: sudo $0${NC}"
    echo ""
fi

# Change to ARK root directory
cd "$ARK_ROOT" || { echo -e "${RED}Error: Cannot access $ARK_ROOT${NC}"; exit 1; }

#
# STEP 1: Create directory structure
#
echo -e "${GREEN}[1/6] Creating directory structure...${NC}"
mkdir -p docs/archive
mkdir -p backups
echo "  ✓ Created: $ARK_ROOT/docs/archive"
echo "  ✓ Created: $ARK_ROOT/backups"
echo ""

#
# STEP 2: Archive historical documentation
#
echo -e "${GREEN}[2/6] Archiving historical documentation...${NC}"

# List of files to archive
ARCHIVE_FILES=(
    "MISSION_COMPLETE.md"
    "MISSION_SUMMARY_20260115.txt"
    "HANDOFF_DOCUMENT.md"
    "HANDOFF_TO_NEW_CHAT.md"
    "D_DOCK_AUDIT.md"
    "CONTENT_AUDIT_REPORT.md"
    "PROGRESS_REPORT.md"
    "DOWNLOAD_STATUS.md"
    "DOCK_CHANGELOG.md"
)

for file in "${ARCHIVE_FILES[@]}"; do
    if [ -f "$ARK_ROOT/$file" ]; then
        mv "$ARK_ROOT/$file" "$ARK_ROOT/docs/archive/"
        echo "  ✓ Archived: $file → docs/archive/"
    else
        echo "  ⊘ Not found: $file (skipped)"
    fi
done
echo ""

#
# STEP 3: Move backup files
#
echo -e "${GREEN}[3/6] Organizing backup files...${NC}"

# Move any .backup* files to backups directory
BACKUP_COUNT=0
for backup_file in "$ARK_ROOT"/*.backup* "$ARK_ROOT"/*backup*; do
    if [ -f "$backup_file" ]; then
        filename=$(basename "$backup_file")
        mv "$backup_file" "$ARK_ROOT/backups/"
        echo "  ✓ Moved: $filename → backups/"
        ((BACKUP_COUNT++))
    fi
done

if [ $BACKUP_COUNT -eq 0 ]; then
    echo "  ⊘ No backup files found"
fi
echo ""

#
# STEP 4: Consolidate survival download scripts
#
echo -e "${GREEN}[4/6] Consolidating duplicate scripts...${NC}"

if [ -f "$ARK_ROOT/scripts/download-survival-v2.sh" ]; then
    if [ -f "$ARK_ROOT/scripts/download-survival.sh" ]; then
        # Backup old version first
        mv "$ARK_ROOT/scripts/download-survival.sh" "$ARK_ROOT/backups/download-survival-v1.sh.backup"
        echo "  ✓ Backed up: download-survival.sh → backups/download-survival-v1.sh.backup"
    fi
    # Rename v2 to canonical name
    mv "$ARK_ROOT/scripts/download-survival-v2.sh" "$ARK_ROOT/scripts/download-survival.sh"
    echo "  ✓ Promoted: download-survival-v2.sh → download-survival.sh"
else
    echo "  ⊘ No duplicate survival scripts found"
fi
echo ""

#
# STEP 5: Set script permissions
#
echo -e "${GREEN}[5/6] Setting script permissions...${NC}"

# Set execute permission on all .sh files in scripts directory
SCRIPT_COUNT=0
for script in "$ARK_ROOT/scripts"/*.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        script_name=$(basename "$script")
        echo "  ✓ chmod +x: $script_name"
        ((SCRIPT_COUNT++))
    fi
done

# Also set permissions on root-level scripts
for script in "$ARK_ROOT"/*.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        script_name=$(basename "$script")
        echo "  ✓ chmod +x: $script_name"
        ((SCRIPT_COUNT++))
    fi
done

echo "  → Total scripts updated: $SCRIPT_COUNT"
echo ""

#
# STEP 6: Archive RESURRECTION.sh if complete
#
echo -e "${GREEN}[6/6] Checking RESURRECTION.sh status...${NC}"

if [ -f "$ARK_ROOT/scripts/RESURRECTION.sh" ]; then
    echo -e "${YELLOW}  ⚠ RESURRECTION.sh found${NC}"
    echo "  Question: Is the resurrection phase complete?"
    echo "  If yes, consider moving to: docs/archive/RESURRECTION.sh"
    echo "  Command: mv scripts/RESURRECTION.sh docs/archive/"
    echo ""
else
    echo "  ⊘ RESURRECTION.sh not found (may be already archived)"
    echo ""
fi

#
# FINAL REPORT
#
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Cleanup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Repository Structure:"
echo "  ├── /opt/ark/                  (Root - Clean)"
echo "  ├── /opt/ark/docs/archive/     (Historical documentation)"
echo "  ├── /opt/ark/backups/          (Backup files)"
echo "  ├── /opt/ark/scripts/          (Executable scripts)"
echo "  └── /opt/ark/configs/          (Service configurations)"
echo ""
echo "Summary:"
echo "  • Archived: ${#ARCHIVE_FILES[@]} documentation files"
echo "  • Organized: $BACKUP_COUNT backup files"
echo "  • Permissions: $SCRIPT_COUNT scripts made executable"
echo "  • Version: $(cat $ARK_ROOT/VERSION 2>/dev/null || echo 'unknown')"
echo ""
echo -e "${GREEN}Root directory is now clean and production-ready.${NC}"
echo -e "${BLUE}========================================${NC}"
