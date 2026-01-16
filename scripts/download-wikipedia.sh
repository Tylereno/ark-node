#!/bin/bash
# ARK v3.1.0 | Module: Wikipedia ZIM Downloader
# Classification: INTERNAL
# Purpose: Download Wikipedia ZIM archives for offline access via Kiwix
# Target: /mnt/dock/data/media/kiwix/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         WIKIPEDIA ZIM DOWNLOADER - ARK v3.1.0                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Critical: Verify /mnt/dock mount
echo -e "${YELLOW}[1/5] Verifying /mnt/dock mount...${NC}"
if ! mountpoint -q /mnt/dock; then
    echo -e "${RED}ERROR: /mnt/dock is NOT mounted!${NC}"
    echo -e "${RED}Cannot continue - would fill local VM disk and crash system.${NC}"
    exit 1
fi

AVAILABLE=$(df -h /mnt/dock | awk 'NR==2 {print $4}')
echo -e "${GREEN}✓ Mount verified - ${AVAILABLE} available${NC}"
echo ""

# Create target directory
TARGET_DIR="/mnt/dock/data/media/kiwix"
echo -e "${YELLOW}[2/5] Creating target directory...${NC}"
mkdir -p "$TARGET_DIR"
echo -e "${GREEN}✓ Directory ready: $TARGET_DIR${NC}"
echo ""

# Wikipedia options
echo -e "${YELLOW}[3/5] Select Wikipedia package:${NC}"
echo -e "  ${BLUE}1)${NC} Simple English (5GB) - Basic articles"
echo -e "  ${BLUE}2)${NC} English No Pictures (35GB) - All articles, no images"
echo -e "  ${BLUE}3)${NC} English Maxi (90GB) - Full Wikipedia with images ${GREEN}[RECOMMENDED]${NC}"
echo -e "  ${BLUE}4)${NC} Custom URL"
echo -e "  ${BLUE}5)${NC} Unattended Mode - Download Maxi (90GB) automatically"
echo ""

# Check for unattended mode flag
if [[ "$1" == "--unattended" ]] || [[ "$1" == "-u" ]]; then
    CHOICE="5"
    echo -e "${GREEN}Running in UNATTENDED mode - downloading Wikipedia Maxi...${NC}"
else
    read -p "Enter choice [1-5]: " CHOICE
fi

case $CHOICE in
    1)
        ZIM_URL="https://download.kiwix.org/zim/wikipedia/wikipedia_en_simple_all_maxi_2024-01.zim"
        ZIM_FILE="wikipedia_en_simple_all_maxi_2024-01.zim"
        SIZE="~5GB"
        ;;
    2)
        ZIM_URL="https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_nopic_2024-01.zim"
        ZIM_FILE="wikipedia_en_all_nopic_2024-01.zim"
        SIZE="~35GB"
        ;;
    3|5)
        ZIM_URL="https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2024-01.zim"
        ZIM_FILE="wikipedia_en_all_maxi_2024-01.zim"
        SIZE="~90GB"
        ;;
    4)
        read -p "Enter custom ZIM URL: " ZIM_URL
        ZIM_FILE=$(basename "$ZIM_URL")
        SIZE="Unknown"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}[4/5] Download details:${NC}"
echo -e "  File: ${BLUE}$ZIM_FILE${NC}"
echo -e "  Size: ${BLUE}$SIZE${NC}"
echo -e "  URL:  ${BLUE}$ZIM_URL${NC}"
echo -e "  Path: ${BLUE}$TARGET_DIR/$ZIM_FILE${NC}"
echo ""

# Check if file already exists
if [[ -f "$TARGET_DIR/$ZIM_FILE" ]]; then
    EXISTING_SIZE=$(du -h "$TARGET_DIR/$ZIM_FILE" | cut -f1)
    echo -e "${YELLOW}⚠ File already exists (${EXISTING_SIZE})${NC}"
    if [[ "$CHOICE" != "5" ]]; then
        read -p "Resume download? [Y/n]: " RESUME
        if [[ "$RESUME" == "n" ]] || [[ "$RESUME" == "N" ]]; then
            echo "Download cancelled."
            exit 0
        fi
    else
        echo -e "${GREEN}Will resume existing download...${NC}"
    fi
fi

echo -e "${YELLOW}[5/5] Starting download...${NC}"
echo -e "${BLUE}Note: wget will resume if interrupted (Ctrl+C to pause)${NC}"
echo ""

# Download with resume capability
cd "$TARGET_DIR"
wget -c -t 0 --retry-connrefused --progress=bar:force:noscroll \
     --show-progress \
     "$ZIM_URL" \
     -O "$ZIM_FILE.partial"

# Move to final name when complete
mv "$ZIM_FILE.partial" "$ZIM_FILE"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 DOWNLOAD COMPLETE!                            ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "File saved to: ${BLUE}$TARGET_DIR/$ZIM_FILE${NC}"
echo -e "Size: ${BLUE}$(du -h "$TARGET_DIR/$ZIM_FILE" | cut -f1)${NC}"
echo ""

# Restart Kiwix container to pick up new content
echo -e "${YELLOW}Restarting Kiwix container...${NC}"
if command -v docker &> /dev/null; then
    docker restart kiwix 2>/dev/null || echo -e "${YELLOW}Could not restart Kiwix (may not be running)${NC}"
fi

echo ""
echo -e "${GREEN}✓ Access Wikipedia at: http://nomad-node:8081${NC}"
echo ""
