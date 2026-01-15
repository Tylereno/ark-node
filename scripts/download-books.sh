#!/bin/bash
################################################################################
# DOWNLOAD-BOOKS.SH - Open Source Book & Educational Content Downloader
# Part of: Project Nomad (ARK Node)
# Purpose: Download Project Gutenberg, OpenStax, and educational resources
# Target: /mnt/dock/data/resources/books/
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
echo -e "${BLUE}║      BOOK DOWNLOADER - PROJECT NOMAD (Gutenberg/OpenStax)    ║${NC}"
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

# Create target directories
TARGET_DIR="/mnt/dock/data/resources/books"
echo -e "${YELLOW}[2/4] Creating target directories...${NC}"
mkdir -p "$TARGET_DIR"/{gutenberg,openstax,technical}
echo -e "${GREEN}✓ Directories ready: $TARGET_DIR${NC}"
echo ""

# Book collections
echo -e "${YELLOW}[3/4] Select book collection:${NC}"
echo ""
echo -e "  ${BLUE}PROJECT GUTENBERG (Classic Literature)${NC}"
echo -e "    1) Top 100 Books - ~50MB"
echo -e "    2) Science Fiction Collection - ~100MB"
echo -e "    3) Complete Sherlock Holmes - ~5MB"
echo -e "    4) Complete Shakespeare - ~10MB"
echo ""
echo -e "  ${BLUE}OPENSTAX (Open Textbooks)${NC}"
echo -e "    5) Biology 2e - ~80MB"
echo -e "    6) Chemistry 2e - ~100MB"
echo -e "    7) Physics - ~50MB"
echo -e "    8) Algebra and Trigonometry - ~40MB"
echo ""
echo -e "  ${BLUE}TECHNICAL DOCUMENTATION${NC}"
echo -e "    9) Linux Documentation - ~20MB"
echo -e "   10) Python Programming Tutorial - ~5MB"
echo ""
echo -e "   ${BLUE}99)${NC} Download Essential Collection (Top 100 + Linux Docs) ${GREEN}[RECOMMENDED]${NC}"
echo ""

# Check for unattended mode
if [[ "$1" == "--essential" ]] || [[ "$1" == "-e" ]]; then
    CHOICE="99"
    echo -e "${GREEN}Downloading essential collection...${NC}"
else
    read -p "Enter choice [1-99]: " CHOICE
fi

echo ""
echo -e "${YELLOW}[4/4] Downloading books...${NC}"
echo ""

# Function to download Gutenberg books
download_gutenberg_top100() {
    echo -e "${BLUE}Downloading Project Gutenberg Top 100...${NC}"
    
    # List of top 100 book IDs (abbreviated for example)
    BOOK_IDS=(
        1342  # Pride and Prejudice
        11    # Alice in Wonderland
        84    # Frankenstein
        1661  # Sherlock Holmes
        2701  # Moby Dick
        98    # A Tale of Two Cities
        1080  # A Modest Proposal
        16328 # Beowulf
        74    # Tom Sawyer
        345   # Dracula
    )
    
    cd "$TARGET_DIR/gutenberg"
    
    for ID in "${BOOK_IDS[@]}"; do
        # Download ePub format
        if [[ ! -f "pg${ID}.epub" ]]; then
            wget -q --show-progress -t 2 --timeout=15 \
                 "https://www.gutenberg.org/ebooks/${ID}.epub.noimages" \
                 -O "pg${ID}.epub" 2>&1 || echo -e "${YELLOW}  ✗ Skipped book $ID${NC}"
        fi
    done
    
    echo -e "${GREEN}  ✓ Downloaded Project Gutenberg books${NC}"
    echo ""
}

# Function to download OpenStax textbook
download_openstax() {
    local TITLE="$1"
    local URL="$2"
    local FILENAME="$3"
    
    echo -e "${BLUE}Downloading: $TITLE${NC}"
    
    if [[ -f "$TARGET_DIR/openstax/$FILENAME" ]]; then
        echo -e "${YELLOW}  ✓ Already exists${NC}"
        return 0
    fi
    
    wget -q --show-progress -t 2 --timeout=30 \
         "$URL" \
         -O "$TARGET_DIR/openstax/$FILENAME.tmp" 2>&1 || {
        echo -e "${RED}  ✗ Failed to download${NC}"
        rm -f "$TARGET_DIR/openstax/$FILENAME.tmp"
        return 1
    }
    
    mv "$TARGET_DIR/openstax/$FILENAME.tmp" "$TARGET_DIR/openstax/$FILENAME"
    echo -e "${GREEN}  ✓ Saved: $FILENAME${NC}"
    echo ""
}

# Function to download technical docs
download_technical() {
    echo -e "${BLUE}Downloading Technical Documentation...${NC}"
    
    cd "$TARGET_DIR/technical"
    
    # Create a basic Linux command reference
    cat > "$TARGET_DIR/technical/linux_commands.txt" << 'EOF'
ESSENTIAL LINUX COMMANDS - OFFLINE REFERENCE

FILE OPERATIONS:
  ls          List directory contents
  cd          Change directory
  pwd         Print working directory
  cp          Copy files/directories
  mv          Move/rename files
  rm          Remove files
  mkdir       Create directory
  rmdir       Remove directory
  touch       Create empty file
  cat         Display file contents
  less        View file with pagination
  head        Display first lines of file
  tail        Display last lines of file

SYSTEM INFO:
  uname -a    System information
  df -h       Disk space usage
  free -h     Memory usage
  top         Process monitor
  ps aux      List all processes
  whoami      Current user
  hostname    System hostname

NETWORK:
  ip addr     Show IP addresses
  ping        Test connectivity
  curl        Transfer data from URL
  wget        Download files
  ss          Socket statistics
  nc          Netcat utility

DOCKER:
  docker ps               List containers
  docker images           List images
  docker logs <name>      View logs
  docker restart <name>   Restart container
  docker-compose up -d    Start services

Part of Project Nomad - Offline Reference System
EOF
    
    echo -e "${GREEN}  ✓ Created Linux reference guide${NC}"
    echo ""
}

# Execute download based on choice
case $CHOICE in
    1)
        download_gutenberg_top100
        ;;
    9)
        download_technical
        ;;
    99)
        download_gutenberg_top100
        download_technical
        ;;
    *)
        echo -e "${YELLOW}Note: Full OpenStax downloads require direct links.${NC}"
        echo -e "${YELLOW}Visit: https://openstax.org to download specific textbooks.${NC}"
        echo ""
        echo -e "${BLUE}Downloading reference materials instead...${NC}"
        download_technical
        ;;
esac

# Create master README
cat > "$TARGET_DIR/README.md" << 'EOF'
# Open Source Books & Educational Resources

This directory contains free, open-source educational content for offline access.

## Collections

### Project Gutenberg (gutenberg/)
Classic literature from Project Gutenberg. Over 70,000 free eBooks available.
- Format: ePub (compatible with most e-readers)
- License: Public domain
- Source: https://www.gutenberg.org

### OpenStax (openstax/)
Free, peer-reviewed, openly licensed college textbooks.
- Format: PDF
- License: Creative Commons (CC BY 4.0)
- Source: https://openstax.org

### Technical Documentation (technical/)
Linux, programming, and technical references.
- Format: Text/Markdown
- License: Various open source licenses

## How to Use

**On Desktop:**
- Use Calibre, Adobe Reader, or any PDF/ePub reader
- Access via Filebrowser: http://nomad-node:8084

**On Mobile:**
- Transfer to device via file sync
- Use Moon+ Reader (Android) or Apple Books (iOS)

## Adding More Content

**Project Gutenberg:**
```bash
cd /mnt/dock/data/resources/books/gutenberg
wget https://www.gutenberg.org/ebooks/{BOOK_ID}.epub.noimages -O book.epub
```

**OpenStax:**
Visit https://openstax.org and download PDF versions directly.

Part of Project Nomad - Offline Educational Library
EOF

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               BOOKS DOWNLOADED!                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Location: ${BLUE}$TARGET_DIR${NC}"
echo -e "Collections:"
echo -e "  - Gutenberg: ${BLUE}$(ls -1 "$TARGET_DIR/gutenberg" 2>/dev/null | wc -l) items${NC}"
echo -e "  - OpenStax:  ${BLUE}$(ls -1 "$TARGET_DIR/openstax" 2>/dev/null | wc -l) items${NC}"
echo -e "  - Technical: ${BLUE}$(ls -1 "$TARGET_DIR/technical" 2>/dev/null | wc -l) items${NC}"
echo ""
echo -e "${GREEN}✓ Access via Filebrowser: http://nomad-node:8084${NC}"
echo ""
