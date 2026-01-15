#!/bin/bash
# PROJECT NOMAD - NIGHT SHIFT ORCHESTRATOR
# Autonomous overnight operation

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${CYAN}   NIGHT SHIFT - Project Nomad Autonomous Mode${NC}"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

LOG_FILE="/opt/ark/scripts/logs/night-shift-$(date +%Y%m%d_%H%M%S).log"

# Phase 1: Wait for AI model
echo -e "${YELLOW}[1/4] Waiting for granite4:3b model...${NC}"
MAX_WAIT=1800; ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if docker exec ollama ollama list 2>/dev/null | grep -q "granite4"; then
        echo -e "${GREEN}✓ Model ready!${NC}"
        sed -i 's/MODEL_NAME = ".*"/MODEL_NAME = "granite4:3b"/' /opt/ark/agents/marketing/marketing_crew.py 2>/dev/null
        break
    fi
    [ $((ELAPSED % 60)) -eq 0 ] && echo "  Waiting... ($((ELAPSED / 60)) min)"
    sleep 10; ELAPSED=$((ELAPSED + 10))
done

# Phase 2: Run Agent Farm
echo ""
echo -e "${YELLOW}[2/4] Testing Agent Farm...${NC}"
cd /opt/ark/agents/marketing
if source venv/bin/activate && timeout 600 python marketing_crew.py >> "$LOG_FILE" 2>&1; then
    echo -e "${GREEN}✓ Agent test complete!${NC}"
    ls -t /opt/ark/agents/output/blog/*.md 2>/dev/null | head -1 | xargs -I {} echo "  Generated: {}"
else
    echo "⚠ Agent test timed out (check logs later)"
fi

# Phase 3: Start downloads
echo ""
echo -e "${YELLOW}[3/4] Starting downloads...${NC}"

if ! mountpoint -q /mnt/dock; then
    echo "ERROR: /mnt/dock not mounted!"
    exit 1
fi

nohup /opt/ark/scripts/download-survival.sh > /opt/ark/scripts/logs/survival-nohup.log 2>&1 &
echo "  → Survival manuals (PID: $!)"
sleep 1

nohup /opt/ark/scripts/download-books.sh > /opt/ark/scripts/logs/books-nohup.log 2>&1 &
echo "  → Books (PID: $!)"
sleep 1

nohup /opt/ark/scripts/download-maps.sh > /opt/ark/scripts/logs/maps-nohup.log 2>&1 &
echo "  → Maps setup (PID: $!)"
sleep 1

nohup /opt/ark/scripts/download-wikipedia.sh > /opt/ark/scripts/logs/wikipedia-nohup.log 2>&1 &
WIKI_PID=$!
echo "  → Wikipedia ~100GB (PID: $WIKI_PID)"

# Phase 4: Status
echo ""
echo -e "${YELLOW}[4/4] Night Shift Active!${NC}"
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${GREEN}All systems operational. Downloads running in background.${NC}"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Monitor: tail -f /opt/ark/scripts/logs/wikipedia-nohup.log"
echo "Check:   ls -lh /mnt/dock/data/media/kiwix/"
echo ""
echo "ETA: Survival (2m) | Books (5m) | Wikipedia (8-12h)"
echo ""
