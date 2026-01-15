#!/bin/bash
################################################################################
# DOWNLOAD-ADDITIONAL-ZIMS.SH - Enhanced Knowledge Base
# Downloads: WikiHow, WikiMed, StackOverflow ZIMs
# Part of: Project Nomad (ARK Node)
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      ADDITIONAL ZIM DOWNLOADER - PROJECT NOMAD                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify mount
if ! mountpoint -q /mnt/dock; then
    echo -e "${RED}ERROR: /mnt/dock is NOT mounted!${NC}"
    exit 1
fi

TARGET_DIR="/mnt/dock/data/media/kiwix"
mkdir -p "$TARGET_DIR"

echo -e "${GREEN}Target: $TARGET_DIR${NC}"
echo ""

# Kiwix mirror base URL
KIWIX_MIRROR="https://download.kiwix.org/zim"

# ZIM files to download (smaller, high-value content)
declare -A ZIMS=(
    # Medical encyclopedia (high value for off-grid)
    ["wikimed_en_all_nopic"]="wikimed/wikimed_en_all_nopic_2024-01.zim|1.5GB|Medical Wikipedia (no images)"
    
    # How-to guides (survival, DIY)
    ["wikihow_en_all"]="wikihow/wikihow_en_all_nopic_2024-01.zim|4.5GB|WikiHow DIY Guides (no images)"
    
    # StackOverflow (developer reference)
    ["stackoverflow.com_en_all"]="stackoverflow.com/stackoverflow.com_en_all_2023-10.zim|130GB|StackOverflow Q&A Archive"
    
    # TED Talks (educational, smaller)
    ["ted_en_all"]="ted/ted_en_all_2024-01.zim|8GB|TED Talks (video + transcripts)"
)

download_zim() {
    local KEY="$1"
    local INFO="${ZIMS[$KEY]}"
    
    IFS='|' read -r PATH SIZE DESC <<< "$INFO"
    local FILENAME=$(basename "$PATH")
    local FULL_URL="$KIWIX_MIRROR/$PATH"
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$DESC${NC}"
    echo -e "Size: ${YELLOW}$SIZE${NC}"
    echo -e "File: ${YELLOW}$FILENAME${NC}"
    echo ""
    
    if [[ -f "$TARGET_DIR/$FILENAME" ]]; then
        echo -e "${GREEN}✓ Already downloaded${NC}"
        echo ""
        return 0
    fi
    
    echo -e "${YELLOW}Starting download...${NC}"
    echo "URL: $FULL_URL"
    echo ""
    
    # Download with resume support
    wget -c -t 0 --retry-connrefused --waitretry=5 \
         --progress=bar:force:noscroll \
         "$FULL_URL" \
         -O "$TARGET_DIR/$FILENAME.partial" 2>&1 | tee -a /tmp/zim-download.log
    
    if [[ $? -eq 0 ]]; then
        mv "$TARGET_DIR/$FILENAME.partial" "$TARGET_DIR/$FILENAME"
        echo -e "${GREEN}✓ Download complete: $FILENAME${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Download failed: $FILENAME${NC}"
        echo "Partial file saved for resume: $FILENAME.partial"
        echo ""
        return 1
    fi
}

# Menu
echo -e "${YELLOW}Available ZIM files:${NC}"
echo ""
echo "1. WikiMed (Medical Encyclopedia) - 1.5GB"
echo "2. WikiHow (DIY/Survival Guides) - 4.5GB"
echo "3. TED Talks (Education) - 8GB"
echo "4. StackOverflow (Developer Archive) - 130GB [Large!]"
echo "5. Download Essential Pack (1+2+3)"
echo "6. Download ALL (including StackOverflow)"
echo ""

if [[ "$1" == "--essential" ]]; then
    CHOICE="5"
elif [[ "$1" == "--all" ]]; then
    CHOICE="6"
else
    read -p "Select option (1-6): " CHOICE
fi

case $CHOICE in
    1)
        download_zim "wikimed_en_all_nopic"
        ;;
    2)
        download_zim "wikihow_en_all"
        ;;
    3)
        download_zim "ted_en_all"
        ;;
    4)
        download_zim "stackoverflow.com_en_all"
        ;;
    5)
        echo -e "${GREEN}Downloading Essential Pack...${NC}"
        echo ""
        download_zim "wikimed_en_all_nopic"
        download_zim "wikihow_en_all"
        download_zim "ted_en_all"
        ;;
    6)
        echo -e "${GREEN}Downloading EVERYTHING...${NC}"
        echo ""
        download_zim "wikimed_en_all_nopic"
        download_zim "wikihow_en_all"
        download_zim "ted_en_all"
        download_zim "stackoverflow.com_en_all"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    DOWNLOAD COMPLETE                          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Show inventory
echo -e "${YELLOW}Current ZIM inventory:${NC}"
ls -lh "$TARGET_DIR"/*.zim 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""

echo -e "${GREEN}Kiwix will serve these files automatically on next restart${NC}"
echo -e "Access at: ${BLUE}http://192.168.26.8:8083${NC}"
echo ""
