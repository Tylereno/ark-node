#!/bin/bash
################################################################################
# CHECK-DOWNLOADS.SH - Monitor Active Downloads
# Part of: Project Nomad (ARK Node)
################################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         DOWNLOAD STATUS - PROJECT NOMAD                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Wikipedia download
echo -e "${YELLOW}Wikipedia Download:${NC}"
if pgrep -f "download-wikipedia" > /dev/null; then
    echo -e "  Status: ${GREEN}RUNNING${NC}"
    if [[ -f /mnt/dock/data/media/kiwix/wikipedia_en_all_maxi_2024-01.zim.partial ]]; then
        SIZE=$(du -h /mnt/dock/data/media/kiwix/wikipedia_en_all_maxi_2024-01.zim.partial | cut -f1)
        echo -e "  Current Size: ${BLUE}$SIZE${NC} / ~90GB"
        PERCENT=$(echo "scale=1; $(du -b /mnt/dock/data/media/kiwix/wikipedia_en_all_maxi_2024-01.zim.partial | cut -f1) / 96636764160 * 100" | bc 2>/dev/null || echo "calculating...")
        echo -e "  Progress: ${BLUE}${PERCENT}%${NC}"
    fi
    echo -e "  Log: /tmp/wikipedia-download.log"
else
    echo -e "  Status: ${YELLOW}NOT RUNNING${NC}"
    if [[ -f /mnt/dock/data/media/kiwix/wikipedia_en_all_maxi_2024-01.zim ]]; then
        SIZE=$(du -h /mnt/dock/data/media/kiwix/wikipedia_en_all_maxi_2024-01.zim | cut -f1)
        echo -e "  Status: ${GREEN}COMPLETE${NC} ($SIZE)"
    fi
fi
echo ""

# Check storage
echo -e "${YELLOW}Storage Status:${NC}"
df -h /mnt/dock | tail -1 | awk '{print "  Total: " $2 "\n  Used: " $3 " (" $5 ")\n  Available: " $4}'
echo ""

# Content inventory
echo -e "${YELLOW}Content Inventory:${NC}"
KIWIX_COUNT=$(ls -1 /mnt/dock/data/media/kiwix/*.zim 2>/dev/null | wc -l)
BOOKS_COUNT=$(find /mnt/dock/data/resources/books -name "*.epub" -o -name "*.pdf" 2>/dev/null | wc -l)
SURVIVAL_COUNT=$(ls -1 /mnt/dock/data/resources/survival/*.pdf 2>/dev/null | wc -l)
MAPS_COUNT=$(ls -1 /mnt/dock/data/media/maps/*.zip 2>/dev/null | wc -l)

echo -e "  Kiwix ZIMs: ${BLUE}$KIWIX_COUNT files${NC}"
echo -e "  Books: ${BLUE}$BOOKS_COUNT files${NC}"
echo -e "  Survival Guides: ${BLUE}$SURVIVAL_COUNT files${NC}"
echo -e "  Maps: ${BLUE}$MAPS_COUNT files${NC}"
echo ""

# Running processes
if pgrep -f "download-" > /dev/null; then
    echo -e "${YELLOW}Active Downloads:${NC}"
    ps aux | grep -E "download-|wget" | grep -v grep | awk '{print "  " $11 " " $12 " " $13}'
    echo ""
fi
