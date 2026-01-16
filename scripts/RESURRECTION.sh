#!/bin/bash
# ARK v3.1.0 | Module: Service Resurrection
# Classification: INTERNAL
# Purpose: Deploy enhanced stack and verify all services are operational

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Banner
clear 2>/dev/null || true
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}⬢ ARK v3.1.0: SERVICE RESURRECTION${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Deploying: Tailscale, Gitea, Code-Server${NC}"
echo -e "${YELLOW}Verifying: Wikipedia, Ollama Model, All Services${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

LOG_FILE="/opt/ark/scripts/logs/resurrection-$(date +%Y%m%d-%H%M%S).log"
mkdir -p /opt/ark/scripts/logs

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Resurrection initiated"

# ============================================================================
# PHASE 1: DEPLOY ENHANCED STACK
# ============================================================================
echo -e "${BOLD}[1/4] Deploying Enhanced Docker Stack...${NC}"
log "Phase 1: Deploying enhanced stack"

cd /opt/ark

if docker compose up -d 2>&1 | tee -a "$LOG_FILE"; then
    echo -e "${GREEN}✓ Stack deployment successful${NC}"
    log "Stack deployed successfully"
    sleep 3  # Give containers time to initialize
else
    echo -e "${RED}✗ Stack deployment failed${NC}"
    log "ERROR: Stack deployment failed"
    exit 1
fi

echo ""

# ============================================================================
# PHASE 2: VERIFY WIKIPEDIA DOWNLOAD
# ============================================================================
echo -e "${BOLD}[2/4] Checking Wikipedia Download...${NC}"
log "Phase 2: Checking Wikipedia download"

# Check if download process is running
if pgrep -f "download-wikipedia" > /dev/null; then
    WIKI_PID=$(pgrep -f "download-wikipedia")
    echo -e "${GREEN}✓ Wikipedia download is running (PID: $WIKI_PID)${NC}"
    log "Wikipedia download active (PID: $WIKI_PID)"
    
    # Show current size
    if [ -f /mnt/dock/data/media/kiwix/*.partial ]; then
        CURRENT_SIZE=$(du -h /mnt/dock/data/media/kiwix/*.partial 2>/dev/null | cut -f1)
        echo -e "${CYAN}  Current size: $CURRENT_SIZE${NC}"
        log "Wikipedia size: $CURRENT_SIZE"
    fi
else
    echo -e "${YELLOW}⚠ Wikipedia download not running${NC}"
    log "Wikipedia download not active, checking if needed..."
    
    # Check if already complete
    if [ -f /mnt/dock/data/media/kiwix/*.zim ] && [ ! -f /mnt/dock/data/media/kiwix/*.partial ]; then
        echo -e "${GREEN}✓ Wikipedia already downloaded!${NC}"
        log "Wikipedia download complete"
    else
        echo -e "${YELLOW}→ Resuming Wikipedia download...${NC}"
        log "Resuming Wikipedia download"
        nohup /opt/ark/scripts/download-wikipedia.sh > /opt/ark/scripts/logs/wikipedia-resumed.log 2>&1 &
        WIKI_PID=$!
        echo -e "${GREEN}✓ Download restarted (PID: $WIKI_PID)${NC}"
        log "Wikipedia download restarted (PID: $WIKI_PID)"
    fi
fi

echo ""

# ============================================================================
# PHASE 3: VERIFY GRANITE4 MODEL
# ============================================================================
echo -e "${BOLD}[3/4] Checking Ollama Granite4 Model...${NC}"
log "Phase 3: Checking Ollama model"

# Wait for Ollama to be ready
echo -e "${CYAN}  Waiting for Ollama service...${NC}"
sleep 5

if docker exec ollama ollama list 2>/dev/null | grep -q "granite4:3b"; then
    echo -e "${GREEN}✓ Granite4:3b model is loaded${NC}"
    log "Granite4:3b model available"
else
    echo -e "${YELLOW}⚠ Granite4:3b model not found${NC}"
    
    # Check if download is already running
    if docker exec ollama pgrep -f "ollama pull" > /dev/null 2>&1; then
        echo -e "${CYAN}  Model download already in progress...${NC}"
        log "Granite4 download already running"
    else
        echo -e "${YELLOW}→ Starting granite4:3b download...${NC}"
        log "Starting Granite4 download"
        docker exec -d ollama ollama pull granite4:3b
        echo -e "${GREEN}✓ Model download initiated${NC}"
        log "Granite4 download started"
    fi
    
    echo -e "${CYAN}  Note: Model is ~2GB, will take 15-20 minutes${NC}"
fi

echo ""

# ============================================================================
# PHASE 4: STATUS REPORT
# ============================================================================
echo -e "${BOLD}[4/4] System Status Report...${NC}"
log "Phase 4: Generating status report"
echo ""

# Container status
echo -e "${CYAN}┌─ Active Containers ────────────────────────────────────────────┐${NC}"
docker ps --format "  {{.Names}}\t{{.Status}}" | head -20
echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# New services check
echo -e "${CYAN}┌─ New Services Status ──────────────────────────────────────────┐${NC}"
for service in tailscale gitea code-server; do
    if docker ps | grep -q "$service"; then
        echo -e "  ${GREEN}✓${NC} $service is running"
    else
        echo -e "  ${RED}✗${NC} $service failed to start"
    fi
done
echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# Storage status
echo -e "${CYAN}┌─ Storage Status ───────────────────────────────────────────────┐${NC}"
df -h /mnt/dock | tail -1 | awk '{print "  Total: " $2 "  |  Used: " $3 "  |  Available: " $4 "  (" $5 " full)"}'
echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# Download progress
if [ -f /mnt/dock/data/media/kiwix/*.partial ]; then
    echo -e "${CYAN}┌─ Wikipedia Download ───────────────────────────────────────────┐${NC}"
    WIKI_SIZE=$(du -h /mnt/dock/data/media/kiwix/*.partial 2>/dev/null | cut -f1)
    echo -e "  Current: ${YELLOW}${WIKI_SIZE}${NC} / ~100GB"
    echo -e "  Status:  ${GREEN}Downloading${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
fi

# ============================================================================
# FINAL SUMMARY
# ============================================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}⬢ RESURRECTION COMPLETE${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Access Points:${NC}"
echo -e "  ${CYAN}Homepage:${NC}      http://192.168.26.8:3000"
echo -e "  ${CYAN}Gitea:${NC}        http://192.168.26.8:3002  ${YELLOW}(First run setup required)${NC}"
echo -e "  ${CYAN}Code-Server:${NC}  http://192.168.26.8:8443  ${YELLOW}(Password: arknode123)${NC}"
echo -e "  ${CYAN}Portainer:${NC}    http://192.168.26.8:9000"
echo ""
echo -e "${BOLD}⚠️  IMPORTANT - Tailscale Setup:${NC}"
echo -e "  Tailscale container is running but needs authentication."
echo -e "  ${YELLOW}Run this command to connect:${NC}"
echo -e "  ${CYAN}docker exec tailscale tailscale up${NC}"
echo ""
echo -e "  Follow the URL shown to authorize this device on your Tailscale network."
echo ""
echo -e "${BOLD}Monitor Operations:${NC}"
echo -e "  ${CYAN}docker ps${NC}                    # View all containers"
echo -e "  ${CYAN}docker logs -f granite4${NC}      # Watch model download"
echo -e "  ${CYAN}tail -f /opt/ark/scripts/logs/wikipedia-resumed.log${NC}  # Watch Wikipedia"
echo ""
echo -e "${BOLD}Log File:${NC} $LOG_FILE"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════${NC}"

log "Resurrection completed successfully"
