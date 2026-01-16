#!/bin/bash
################################################################################
# CLEANUP-ROOT.SH - Sanitize Root Folder
# Part of: Project Nomad (ARK Node)
# Purpose: Move docs to /docs, scripts to /scripts, archive old files
################################################################################

set -e

ARK_DIR="/opt/ark"
DOCS_DIR="$ARK_DIR/docs"
ARCHIVE_DIR="$DOCS_DIR/archive"
SCRIPTS_DIR="$ARK_DIR/scripts"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} ${GREEN}         ROOT FOLDER SANITIZATION${NC}${BLUE}                              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Ensure directories exist
mkdir -p "$DOCS_DIR"
mkdir -p "$ARCHIVE_DIR"
mkdir -p "$SCRIPTS_DIR"

# 1. Move essential scripts to /scripts (if not already there)
echo -e "${YELLOW}[1/4] Moving scripts to /scripts...${NC}"
if [ -f "$ARK_DIR/install_ark.sh" ]; then
    mv "$ARK_DIR/install_ark.sh" "$SCRIPTS_DIR/" 2>/dev/null && echo -e "${GREEN}✓${NC} Moved install_ark.sh"
fi
if [ -f "$ARK_DIR/deploy.sh" ]; then
    mv "$ARK_DIR/deploy.sh" "$SCRIPTS_DIR/" 2>/dev/null && echo -e "${GREEN}✓${NC} Moved deploy.sh"
fi
echo ""

# 2. Move core documentation to /docs
echo -e "${YELLOW}[2/4] Moving core documentation to /docs...${NC}"

# Essential docs that should be in /docs
ESSENTIAL_DOCS=(
    "INDUSTRIAL_GRADE_SETUP.md"
    "TRAEFIK_DOMAINS.md"
    "BACKUP_SYSTEM.md"
    "ARK_MANAGER_GUIDE.md"
    "RALPH_LOOP_COMPLETE.md"
)

for doc in "${ESSENTIAL_DOCS[@]}"; do
    if [ -f "$ARK_DIR/$doc" ]; then
        mv "$ARK_DIR/$doc" "$DOCS_DIR/" 2>/dev/null && echo -e "${GREEN}✓${NC} Moved $doc"
    fi
done

# Move Captain's Log and Changelog to /docs (paths updated in ark-manager.sh)
if [ -f "$ARK_DIR/CAPTAINS_LOG.md" ]; then
    mv "$ARK_DIR/CAPTAINS_LOG.md" "$DOCS_DIR/" 2>/dev/null && echo -e "${GREEN}✓${NC} Moved CAPTAINS_LOG.md"
fi
if [ -f "$ARK_DIR/CHANGELOG.md" ]; then
    mv "$ARK_DIR/CHANGELOG.md" "$DOCS_DIR/" 2>/dev/null && echo -e "${GREEN}✓${NC} Moved CHANGELOG.md"
fi

echo ""

# 3. Archive old/redundant documentation files
echo -e "${YELLOW}[3/4] Archiving old documentation...${NC}"

# Files to archive (old status reports, phase docs, etc.)
ARCHIVE_PATTERNS=(
    "RALPH_LOOP_*.md"
    "RALPH_PROTOCOL*.md"
    "PHASE_*.md"
    "VESSEL_STATUS*.md"
    "GOLD_MASTER*.md"
    "MISSION_*.md"
    "HANDOFF*.md"
    "PROGRESS*.md"
    "DEPLOYMENT*.md"
    "SECURITY_*.md"
    "NO_LEAK*.md"
    "BRAIN_SURGERY*.md"
    "FIRST_CONTACT*.md"
    "CAPTAIN_LOG.md"
    "PROTOCOL*.md"
    "MARKETING*.md"
    "LANDING_PAGE*.md"
    "SETUP_NOTES.md"
    "QUICK_REFERENCE.md"
    "OPERATOR_HANDBOOK.md"
    "PROJECT_CHARTER.md"
    "AGENT_FARM*.md"
    "CLINERULES*.md"
    "DOCKER_COMPOSE_STANDARDS.md"
    "GITHUB_ACTIONS*.md"
    "MANUAL_SETUP*.md"
    "PORT_FORWARDING*.md"
    "TAILSCALE_STATE*.md"
)

ARCHIVED_COUNT=0
for pattern in "${ARCHIVE_PATTERNS[@]}"; do
    # Use find to match patterns more reliably
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            mv "$file" "$ARCHIVE_DIR/" 2>/dev/null && {
                echo -e "${GREEN}✓${NC} Archived $(basename "$file")"
                ((ARCHIVED_COUNT++))
            }
        fi
    done < <(find "$ARK_DIR" -maxdepth 1 -name "$pattern" -type f 2>/dev/null)
done

if [ $ARCHIVED_COUNT -eq 0 ]; then
    echo -e "${BLUE}ℹ${NC}  No files to archive"
else
    echo -e "${GREEN}✓${NC} Archived $ARCHIVED_COUNT file(s)"
fi
echo ""

# 4. Remove any remaining clutter (be very careful here)
echo -e "${YELLOW}[4/4] Final cleanup...${NC}"

# Only remove files that are clearly temporary or redundant
# Keep README.md, MASTER_LIST.txt, docker-compose.yml, .env files, etc.
CLUTTER_PATTERNS=(
    "*.txt"  # But keep MASTER_LIST.txt
    "*.log"  # Old log files
)

# Actually, let's be more conservative - just report what could be cleaned
echo -e "${BLUE}ℹ${NC}  Checking for remaining clutter..."

# List markdown files in root (excluding essential ones)
ESSENTIAL_ROOT_FILES=("README.md" "MASTER_LIST.txt" "crewai-system-prompt.md")
REMAINING_MD=$(find "$ARK_DIR" -maxdepth 1 -name "*.md" -type f | while read f; do
    basename "$f"
done)

for file in $REMAINING_MD; do
    is_essential=false
    for essential in "${ESSENTIAL_ROOT_FILES[@]}"; do
        if [ "$file" = "$essential" ]; then
            is_essential=true
            break
        fi
    done
    if [ "$is_essential" = false ]; then
        echo -e "${YELLOW}⚠${NC}  $file could be moved to /docs or archived"
    fi
done

echo ""

# Summary
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} ${GREEN}                    CLEANUP COMPLETE${NC}${BLUE}                          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓${NC} Scripts moved to: ${BLUE}$SCRIPTS_DIR${NC}"
echo -e "${GREEN}✓${NC} Documentation moved to: ${BLUE}$DOCS_DIR${NC}"
echo -e "${GREEN}✓${NC} Old files archived to: ${BLUE}$ARCHIVE_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Update ark-manager.sh paths if needed"
echo -e "  2. Review archived files in $ARCHIVE_DIR"
echo -e "  3. Update MASTER_LIST.txt if structure changed"
echo ""
