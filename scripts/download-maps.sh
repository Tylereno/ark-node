#!/bin/bash
################################################################################
# DOWNLOAD-MAPS.SH - Offline Map Downloader for OsmAnd
# Part of: Project Nomad (ARK Node)
# Purpose: Download OpenStreetMap data for offline navigation
# Target: /mnt/dock/data/media/maps/
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          MAP DOWNLOADER - PROJECT NOMAD (OsmAnd)              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify mount
echo -e "${YELLOW}[1/4] Verifying /mnt/dock mount...${NC}"
if ! mountpoint -q /mnt/dock; then
    echo -e "${RED}ERROR: /mnt/dock is NOT mounted!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Mount verified${NC}"
echo ""

# Create target directory
TARGET_DIR="/mnt/dock/data/media/maps"
echo -e "${YELLOW}[2/4] Creating target directory...${NC}"
mkdir -p "$TARGET_DIR"
echo -e "${GREEN}✓ Directory ready: $TARGET_DIR${NC}"
echo ""

# Map regions available
echo -e "${YELLOW}[3/4] Select map region(s):${NC}"
echo ""
echo -e "  ${BLUE}NORTH AMERICA${NC}"
echo -e "    1) USA - West Coast (CA, OR, WA) - ~2.5GB"
echo -e "    2) USA - East Coast (NY, FL, etc) - ~2.0GB"
echo -e "    3) USA - Complete - ~8GB"
echo -e "    4) Canada - ~2.5GB"
echo -e "    5) Mexico - ~1.5GB"
echo ""
echo -e "  ${BLUE}EUROPE${NC}"
echo -e "    6) Germany - ~3GB"
echo -e "    7) France - ~3.5GB"
echo -e "    8) UK & Ireland - ~1GB"
echo ""
echo -e "  ${BLUE}ASIA${NC}"
echo -e "    9) Japan - ~1.5GB"
echo -e "   10) India - ~2GB"
echo ""
echo -e "  ${BLUE}WORLD${NC}"
echo -e "   11) World Overview (low detail) - ~1GB"
echo ""
echo -e "   ${BLUE}99)${NC} Download Starter Pack (World + USA) ${GREEN}[RECOMMENDED]${NC}"
echo ""

# Check for unattended mode
if [[ "$1" == "--starter" ]] || [[ "$1" == "-s" ]]; then
    CHOICE="99"
    echo -e "${GREEN}Downloading starter pack...${NC}"
else
    read -p "Enter choice [1-99]: " CHOICE
fi

# Base URL for OsmAnd maps (updated to working mirror)
BASE_URL="https://download.osmand.net/download.php?file="

# Map definitions
declare -A MAP_FILES=(
    ["1"]="US-west_2.obf.zip"
    ["2"]="US-east_2.obf.zip"
    ["3"]="US_2.obf.zip"
    ["4"]="Canada_2.obf.zip"
    ["5"]="Mexico_2.obf.zip"
    ["6"]="Germany_2.obf.zip"
    ["7"]="France_2.obf.zip"
    ["8"]="UK_2.obf.zip"
    ["9"]="Japan_2.obf.zip"
    ["10"]="India_2.obf.zip"
    ["11"]="World_basemap_2.obf.zip"
)

declare -A MAP_DESCS=(
    ["1"]="USA West Coast"
    ["2"]="USA East Coast"
    ["3"]="USA Complete"
    ["4"]="Canada"
    ["5"]="Mexico"
    ["6"]="Germany"
    ["7"]="France"
    ["8"]="UK & Ireland"
    ["9"]="Japan"
    ["10"]="India"
    ["11"]="World Overview"
)

echo ""
echo -e "${YELLOW}[4/4] Downloading maps...${NC}"
echo ""

# Function to download a map
download_map() {
    local FILE="$1"
    local DESC="$2"
    
    echo -e "${BLUE}Downloading: $DESC${NC}"
    
    if [[ -f "$TARGET_DIR/$FILE" ]]; then
        echo -e "${YELLOW}  ✓ Already exists: $FILE${NC}"
        return 0
    fi
    
    wget -c -t 3 --timeout=60 -q --show-progress \
         "${BASE_URL}${FILE}" \
         -O "$TARGET_DIR/$FILE.tmp" 2>&1 || {
        echo -e "${RED}  ✗ Failed to download: $DESC${NC}"
        rm -f "$TARGET_DIR/$FILE.tmp"
        return 1
    }
    
    mv "$TARGET_DIR/$FILE.tmp" "$TARGET_DIR/$FILE"
    echo -e "${GREEN}  ✓ Saved: $FILE${NC}"
    echo ""
}

# Download based on choice
if [[ "$CHOICE" == "99" ]]; then
    # Starter pack: World + USA
    download_map "${MAP_FILES["11"]}" "${MAP_DESCS["11"]}"
    download_map "${MAP_FILES["3"]}" "${MAP_DESCS["3"]}"
elif [[ -n "${MAP_FILES[$CHOICE]}" ]]; then
    download_map "${MAP_FILES[$CHOICE]}" "${MAP_DESCS[$CHOICE]}"
else
    echo -e "${RED}Invalid choice${NC}"
    exit 1
fi

# Create README
cat > "$TARGET_DIR/README.md" << 'EOF'
# Offline Maps (OsmAnd Format)

This directory contains OpenStreetMap data in OsmAnd .obf format for offline navigation.

## Usage with OsmAnd

1. Install OsmAnd on your mobile device
2. Copy .obf.zip files to your device
3. Import in OsmAnd: Settings → Download maps → Local

## File Format

- **.obf.zip**: OsmAnd Binary Format (compressed)
- Contains roads, POIs, addresses, and topographic data
- Works completely offline after import

## Updates

Maps are updated monthly. Download latest versions from:
https://download.osmand.net

## Alternative Uses

These maps can also be used with:
- Garmin devices (convert with GPSMapEdit)
- QGIS (with plugins)
- Other OSM-compatible navigation software

Part of Project Nomad - Offline Navigation System
EOF

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 MAPS DOWNLOADED!                              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Location: ${BLUE}$TARGET_DIR${NC}"
echo -e "Files: ${BLUE}$(ls -1 "$TARGET_DIR"/*.zip 2>/dev/null | wc -l) map packages${NC}"
echo ""
echo -e "${GREEN}✓ Access via Filebrowser: http://nomad-node:8084${NC}"
echo ""
