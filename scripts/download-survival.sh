#!/bin/bash
################################################################################
# DOWNLOAD-SURVIVAL.SH - Survival & Emergency Resource Downloader
# Part of: Project Nomad (ARK Node)
# Purpose: Download critical survival guides and emergency preparedness docs
# Target: /mnt/dock/data/resources/survival/
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
echo -e "${BLUE}║      SURVIVAL GUIDE DOWNLOADER - PROJECT NOMAD                ║${NC}"
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
TARGET_DIR="/mnt/dock/data/resources/survival"
echo -e "${YELLOW}[2/4] Creating target directory...${NC}"
mkdir -p "$TARGET_DIR"
echo -e "${GREEN}✓ Directory ready: $TARGET_DIR${NC}"
echo ""

# Resource list
echo -e "${YELLOW}[3/4] Available survival resources:${NC}"
echo ""

# Array of resources with working URLs
declare -a RESOURCE_NAMES=(
    "FEMA Emergency Guide"
    "Red Cross First Aid"
    "Army Survival Manual FM 21-76"
    "SAS Survival Handbook"
    "Basic First Aid Reference"
)

declare -a RESOURCE_URLS=(
    "https://www.fema.gov/sites/default/files/documents/fema_2020_individual-family-emergency-preparedness-guide.pdf"
    "https://www.redcross.org/content/dam/redcross/atg/PDF_s/Preparedness___Disaster_Recovery/General_Preparedness___Recovery/Home/ARC_Family_Disaster_Plan.pdf"
    "https://www.survivalebooks.com/freeebooks/FM21-76SurvivalManual.pdf"
    "https://www.ar15.com/media/ar15com_library/SAS_Survival_Handbook.pdf"
    "https://www.redcross.org/content/dam/redcross/atg/PDF_s/Health___Safety_Services/Training/Babysitting_safety/FastFacts_Allergy.pdf"
)

declare -a RESOURCE_FILES=(
    "fema_emergency_preparedness.pdf"
    "red_cross_family_plan.pdf"
    "army_survival_manual_fm21-76.pdf"
    "sas_survival_handbook.pdf"
    "first_aid_basics.pdf"
)

# Display menu
for i in "${!RESOURCE_NAMES[@]}"; do
    echo -e "  ${BLUE}$((i+1)))${NC} ${RESOURCE_NAMES[$i]}"
done
echo -e "  ${BLUE}99)${NC} Download ALL resources ${GREEN}[RECOMMENDED]${NC}"
echo ""

# Check for unattended mode
if [[ "$1" == "--all" ]] || [[ "$1" == "-a" ]]; then
    CHOICE="99"
    echo -e "${GREEN}Downloading ALL survival resources...${NC}"
else
    read -p "Enter choice [1-99]: " CHOICE
fi

echo ""
echo -e "${YELLOW}[4/4] Downloading resources...${NC}"
echo ""

# Function to download a resource
download_resource() {
    local NAME="$1"
    local URL="$2"
    local FILE="$3"
    
    echo -e "${BLUE}Downloading: $NAME${NC}"
    
    # Check if already exists
    if [[ -f "$TARGET_DIR/$FILE" ]]; then
        echo -e "${YELLOW}  ✓ Already exists: $FILE${NC}"
        return 0
    fi
    
    # Download with retry
    wget -c -t 3 --timeout=30 -q --show-progress \
         "$URL" \
         -O "$TARGET_DIR/$FILE.tmp" 2>&1 || {
        echo -e "${RED}  ✗ Failed to download: $NAME${NC}"
        rm -f "$TARGET_DIR/$FILE.tmp"
        return 1
    }
    
    mv "$TARGET_DIR/$FILE.tmp" "$TARGET_DIR/$FILE"
    echo -e "${GREEN}  ✓ Saved: $FILE${NC}"
    echo ""
}

# Download based on choice
if [[ "$CHOICE" == "99" ]]; then
    # Download all
    for i in "${!RESOURCE_NAMES[@]}"; do
        download_resource "${RESOURCE_NAMES[$i]}" "${RESOURCE_URLS[$i]}" "${RESOURCE_FILES[$i]}"
    done
else
    # Download single resource
    IDX=$((CHOICE-1))
    if [[ $IDX -ge 0 ]] && [[ $IDX -lt ${#RESOURCE_NAMES[@]} ]]; then
        download_resource "${RESOURCE_NAMES[$IDX]}" "${RESOURCE_URLS[$IDX]}" "${RESOURCE_FILES[$IDX]}"
    else
        echo -e "${RED}Invalid choice${NC}"
        exit 1
    fi
fi

# Create README
cat > "$TARGET_DIR/README.md" << 'EOF'
# Survival & Emergency Resources

This directory contains critical survival and emergency preparedness documentation.

## Contents

- **FEMA Emergency Guide**: Comprehensive disaster preparedness from FEMA
- **Red Cross First Aid**: Basic first aid procedures and medical emergencies
- **Army Survival Manual**: FM 21-76 - Military survival techniques
- **SAS Survival Handbook**: Elite survival training guide
- **First Aid Basics**: Quick reference for common medical emergencies

## Usage

These PDFs are designed to be accessed offline during emergencies. Familiarize yourself with the content BEFORE emergencies occur.

## Updates

Check source websites periodically for updated versions:
- FEMA: https://www.fema.gov
- Red Cross: https://www.redcross.org

Part of Project Nomad - Offline Emergency Preparedness System
EOF

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              SURVIVAL RESOURCES DOWNLOADED!                   ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Location: ${BLUE}$TARGET_DIR${NC}"
echo -e "Files: ${BLUE}$(ls -1 "$TARGET_DIR"/*.pdf 2>/dev/null | wc -l) PDFs${NC}"
echo ""
echo -e "${GREEN}✓ Access via Filebrowser: http://nomad-node:8084${NC}"
echo ""
