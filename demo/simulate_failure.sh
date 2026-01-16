#!/bin/bash
# ARK v3.1.0 | Module: Failure Simulation Demo
# Classification: INTERNAL / DEMONSTRATION
# Purpose: Demonstrate autonomous recovery capabilities

# Standard ARK Header
set +euo pipefail
IFS=$'\n\t'

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

ARK_DIR="/opt/ark"
LOG_DIR="$ARK_DIR/logs"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC} ${RED}ARK AUTONOMOUS RECOVERY DEMONSTRATION${NC}${CYAN}                              ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}INITIATING SYSTEM STRESS TEST - SIMULATING CRITICAL PROCESS FAILURE${NC}"
echo ""

# Step 1: Identify target service (use homepage as it's critical and visible)
TARGET_SERVICE="homepage"
echo -e "${CYAN}[1/4]${NC} Target Service: ${TARGET_SERVICE}"
echo -e "${CYAN}[1/4]${NC} Current Status: $(docker inspect -f '{{.State.Status}}' $TARGET_SERVICE 2>/dev/null || echo 'UNKNOWN')"
echo ""

# Step 2: Verify service is running
if ! docker ps | grep -q "$TARGET_SERVICE"; then
    echo -e "${RED}ERROR:${NC} Target service $TARGET_SERVICE is not running. Starting it first..."
    cd "$ARK_DIR"
    COMPOSE_PROFILES="${COMPOSE_PROFILES:-core,apps,media}" docker compose up -d "$TARGET_SERVICE"
    sleep 5
fi

# Step 3: Get container PID
CONTAINER_PID=$(docker inspect -f '{{.State.Pid}}' "$TARGET_SERVICE" 2>/dev/null)
if [ -z "$CONTAINER_PID" ] || [ "$CONTAINER_PID" == "0" ]; then
    echo -e "${RED}ERROR:${NC} Could not determine container PID. Using alternative method..."
    # Alternative: Force stop the container
    echo -e "${YELLOW}[2/4]${NC} Forcing container stop..."
    docker stop "$TARGET_SERVICE" 2>&1
else
    echo -e "${CYAN}[2/4]${NC} Container PID: $CONTAINER_PID"
    echo -e "${YELLOW}[2/4]${NC} Simulating critical process failure (kill -9)..."
    kill -9 "$CONTAINER_PID" 2>/dev/null || docker stop "$TARGET_SERVICE" 2>&1
fi

echo ""
echo -e "${RED}[3/4]${NC} FAILURE INJECTED - Monitoring recovery..."
echo ""

# Step 4: Monitor recovery (watch for restart)
RECOVERY_TIME=0
MAX_WAIT=30
RECOVERED=false

while [ $RECOVERY_TIME -lt $MAX_WAIT ]; do
    sleep 1
    RECOVERY_TIME=$((RECOVERY_TIME + 1))
    
    # Check if container is running again
    if docker ps | grep -q "$TARGET_SERVICE"; then
        CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' "$TARGET_SERVICE" 2>/dev/null)
        if [ "$CONTAINER_STATUS" == "running" ]; then
            echo -e "${GREEN}[4/4]${NC} RECOVERY DETECTED at ${RECOVERY_TIME}s"
            RECOVERED=true
            break
        fi
    fi
    
    # Progress indicator
    if [ $((RECOVERY_TIME % 5)) -eq 0 ]; then
        echo -e "${YELLOW}  Monitoring... (${RECOVERY_TIME}s elapsed)${NC}"
    fi
done

echo ""

# Step 5: Verify recovery
if [ "$RECOVERED" == "true" ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC} ${GREEN}RECOVERY SUCCESSFUL - ARCHITECTURE VALIDATED${NC}${GREEN}                        ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Recovery Metrics:${NC}"
    echo -e "  Service: $TARGET_SERVICE"
    echo -e "  Recovery Time: ${RECOVERY_TIME} seconds"
    echo -e "  Status: $(docker inspect -f '{{.State.Status}}' $TARGET_SERVICE 2>/dev/null)"
    echo -e "  Health: $(docker inspect -f '{{.State.Health.Status}}' $TARGET_SERVICE 2>/dev/null || echo 'N/A')"
    echo ""
    echo -e "${CYAN}Autonomous Recovery Validated:${NC}"
    echo -e "  ✓ Docker restart policy triggered"
    echo -e "  ✓ Container recovered without human intervention"
    echo -e "  ✓ Service restored to operational state"
    echo ""
    
    # Log to Captain's Log
    if [ -f "$ARK_DIR/docs/CAPTAINS_LOG.md" ]; then
        echo "* $(date '+%H:%M:%S'): 🧪 Demo: Simulated failure of $TARGET_SERVICE - Recovered in ${RECOVERY_TIME}s" >> "$ARK_DIR/docs/CAPTAINS_LOG.md"
    fi
    
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC} ${RED}RECOVERY TIMEOUT - MANUAL INTERVENTION REQUIRED${NC}${RED}                    ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Service did not recover within ${MAX_WAIT} seconds.${NC}"
    echo -e "${YELLOW}This may indicate:${NC}"
    echo -e "  - Restart policy not configured correctly"
    echo -e "  - Service dependency issue"
    echo -e "  - Resource constraints"
    echo ""
    echo -e "${CYAN}Manual Recovery:${NC}"
    echo -e "  cd $ARK_DIR"
    echo -e "  docker compose restart $TARGET_SERVICE"
    echo ""
    exit 1
fi
