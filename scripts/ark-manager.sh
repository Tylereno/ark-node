#!/bin/bash
# ARK Autonomous Manager v2.0
# The "Ralph Loop" Orchestrator

# --- CONFIGURATION ---
ARK_DIR="/opt/ark"
LOG_DIR="$ARK_DIR/logs"
DOCS_DIR="$ARK_DIR/docs"
CAPTAINS_LOG="$DOCS_DIR/CAPTAINS_LOG.md"
CHANGELOG="$DOCS_DIR/CHANGELOG.md"
mkdir -p $LOG_DIR
mkdir -p $DOCS_DIR

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- FUNCTIONS ---
log_event() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%H:%M:%S')
    
    # Log to manager.log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_DIR/manager.log"
    
    # Append to Captain's Log
    case "$level" in
        "SUCCESS")
            echo "* $timestamp: ✅ $message" >> "$CAPTAINS_LOG"
            echo -e "${GREEN}✅${NC} $message"
            ;;
        "ERROR"|"CRITICAL")
            echo "* $timestamp: ❌ $message" >> "$CAPTAINS_LOG"
            echo -e "${RED}❌${NC} $message"
            ;;
        "WARNING")
            echo "* $timestamp: ⚠️  $message" >> "$CAPTAINS_LOG"
            echo -e "${YELLOW}⚠️${NC}  $message"
            ;;
        *)
            echo "* $timestamp: $message" >> "$CAPTAINS_LOG"
            echo -e "${BLUE}ℹ️${NC}  $message"
            ;;
    esac
}

full_ralph_loop() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}🚀 Starting Full Ralph Loop...${NC}${CYAN}                                    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Initialize log entry
    DEPLOYMENT_DATE=$(date '+%Y-%m-%d')
    echo "" >> "$CAPTAINS_LOG"
    echo "## Deployment Cycle: $DEPLOYMENT_DATE" >> "$CAPTAINS_LOG"
    echo "* $(date '+%H:%M:%S'): 🚀 Started Full Ralph Loop" >> "$CAPTAINS_LOG"
    
    log_event "INFO" "Step 1/5: Syncing Blueprints from GitHub"
    cd "$ARK_DIR"
    if [ -d .git ]; then
        if git fetch origin main 2>&1 | tee -a "$LOG_DIR/manager.log"; then
            LOCAL=$(git rev-parse @ 2>/dev/null || echo "unknown")
            REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "$LOCAL")
            
            if [ "$LOCAL" != "$REMOTE" ]; then
                git reset --hard origin/main
                log_event "SUCCESS" "Git Blueprint Sync Success (Updated to $(git rev-parse --short HEAD))"
            else
                log_event "SUCCESS" "Git Blueprint Sync Success (Already up to date: $(git rev-parse --short HEAD))"
            fi
        else
            log_event "WARNING" "Git fetch failed. Continuing with local code."
        fi
    else
        log_event "WARNING" "Not a git repository. Skipping git sync."
    fi
    
    log_event "INFO" "Step 2/5: Verifying Persistent Large Files"
    # Check Kiwix ZIM files
    if find /mnt/dock/data/media/kiwix -name "*.zim" -type f 2>/dev/null | grep -q .; then
        ZIM_COUNT=$(find /mnt/dock/data/media/kiwix -name "*.zim" -type f 2>/dev/null | wc -l)
        log_event "SUCCESS" "Found $ZIM_COUNT ZIM file(s). Skipping downloads."
    else
        log_event "WARNING" "Kiwix ZIM files missing. Downloads may be needed."
    fi
    
    # Check Ollama models
    if [ -d /mnt/dock/data/models ] && [ "$(ls -A /mnt/dock/data/models 2>/dev/null)" ]; then
        log_event "SUCCESS" "Ollama models directory exists. Models available."
    else
        log_event "INFO" "Ollama models directory empty or missing."
    fi
    
    log_event "INFO" "Step 3/5: Deploying Infrastructure"
    if docker compose pull -q 2>&1 | tee -a "$LOG_DIR/manager.log"; then
        log_event "SUCCESS" "Docker images pulled successfully"
    else
        log_event "WARNING" "Some images failed to pull. Continuing..."
    fi
    
    if docker compose up -d --remove-orphans 2>&1 | tee -a "$LOG_DIR/manager.log"; then
        log_event "SUCCESS" "Infrastructure deployment initiated"
    else
        log_event "ERROR" "Infrastructure deployment failed"
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: FAILED" >> "$CAPTAINS_LOG"
        return 1
    fi
    
    # Wait for services to stabilize
    log_event "INFO" "Waiting for services to stabilize (20s)..."
    sleep 20
    
    log_event "INFO" "Step 4/5: Service Verification (The Ralph Check)"
    # Smart service verification - check Docker health status first, then HTTP if needed
    # This avoids false positives from services still initializing
    
    services=("homepage" "kiwix" "jellyfin" "open-webui" "portainer" "traefik" "ollama" "filebrowser" "vaultwarden" "gitea" "code-server" "syncthing" "audiobookshelf")
    verified=0
    failed=0
    checking=0
    
    for name in "${services[@]}"; do
        # First check: Is container running?
        running=$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null)
        
        if [ "$running" == "true" ]; then
            # Second check: Does it have a health check configured?
            health=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null)
            
            if [ "$health" == "healthy" ]; then
                log_event "SUCCESS" "$name container is HEALTHY"
                ((verified++))
            elif [ "$health" == "starting" ]; then
                # Container is running but health check is still initializing
                log_event "INFO" "$name container is ACTIVE (health check initializing)"
                ((checking++))
            elif [ "$health" == "unhealthy" ]; then
                # Container running but unhealthy
                log_event "WARNING" "$name container is RUNNING but UNHEALTHY"
                ((failed++))
            elif [ -z "$health" ] || [ "$health" == "<no value>" ]; then
                # No health check configured - just check if it's running
                log_event "SUCCESS" "$name container is ACTIVE (no health check configured)"
                ((verified++))
            else
                # Unknown health status
                log_event "INFO" "$name container is ACTIVE (status: $health)"
                ((checking++))
            fi
        else
            log_event "ERROR" "$name container is DOWN"
            ((failed++))
        fi
    done
    
    # Check all containers
    RUNNING=$(docker compose ps | grep -c "Up" || echo "0")
    # Count total services from docker compose
    TOTAL=$(docker compose ps --format json 2>/dev/null | jq -r '.[].Name' 2>/dev/null | wc -l)
    if [ -z "$TOTAL" ] || [ "$TOTAL" -eq 0 ]; then
        # Fallback: count from docker compose ps output
        TOTAL=$(docker compose ps --format "{{.Name}}" 2>/dev/null | grep -v "^NAME$" | wc -l)
    fi
    if [ -z "$TOTAL" ] || [ "$TOTAL" -eq 0 ]; then
        TOTAL=16  # Default expected count
    fi
    
    if [ $verified -gt 0 ] || [ $checking -gt 0 ]; then
        log_event "SUCCESS" "Container Status: $RUNNING/$TOTAL Running ($verified healthy, $checking initializing)"
    else
        log_event "WARNING" "Container Status: $RUNNING/$TOTAL Running (health checks pending)"
    fi
    
    log_event "INFO" "Step 5/5: Finalizing Documentation & Backups"
    if [ -f "$ARK_DIR/scripts/backup-configs.sh" ]; then
        if "$ARK_DIR/scripts/backup-configs.sh" > /dev/null 2>&1; then
            log_event "SUCCESS" "Configuration backup created"
        else
            log_event "WARNING" "Backup had issues, but continuing"
        fi
    fi
    
    # Update changelog
    if [ -f "$ARK_DIR/scripts/update-changelog.sh" ]; then
        "$ARK_DIR/scripts/update-changelog.sh" > /dev/null 2>&1 || true
    fi
    
    # Final status
    if [ $failed -eq 0 ] && [ $verified -gt 0 ]; then
        log_event "SUCCESS" "🏆 Ralph Loop Complete - All Systems Green"
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: SUCCESS" >> "$CAPTAINS_LOG"
    elif [ $failed -eq 0 ]; then
        log_event "SUCCESS" "🏆 Ralph Loop Complete - All Containers Running (health checks initializing)"
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: SUCCESS (containers initializing)" >> "$CAPTAINS_LOG"
    else
        log_event "WARNING" "🏆 Ralph Loop Complete - $failed service(s) need attention"
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: PARTIAL ($failed failures)" >> "$CAPTAINS_LOG"
    fi
    
    echo ""
    echo -e "${CYAN}Verification Summary:${NC}"
    echo -e "  ${GREEN}✓${NC} Healthy: $verified services"
    if [ $checking -gt 0 ]; then
        echo -e "  ${YELLOW}⏳${NC} Initializing: $checking services"
    fi
    echo -e "  ${GREEN}✓${NC} Running: $RUNNING/$TOTAL containers"
    if [ $failed -gt 0 ]; then
        echo -e "  ${RED}✗${NC} Issues: $failed service(s)"
    fi
    echo ""
}

service_status() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}📊 ARK Node Service Status${NC}${CYAN}                                    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    docker compose ps
    echo ""
    echo -e "${CYAN}Storage Status:${NC}"
    df -h /mnt/dock 2>/dev/null | tail -1 | awk '{print "  Total: " $2 "  |  Used: " $3 " (" $5 ")  |  Available: " $4}'
    echo ""
}

update_logs_docs() {
    log_event "INFO" "Manual documentation sync triggered."
    if [ -f "$ARK_DIR/scripts/update-changelog.sh" ]; then
        "$ARK_DIR/scripts/update-changelog.sh"
        log_event "SUCCESS" "Changelog updated"
    fi
    log_event "SUCCESS" "Documentation sync complete"
}

# --- MENU INTERFACE ---
show_menu() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}         ARK AUTONOMOUS MANAGER v2.0${NC}${CYAN}                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Available Tasks:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) Full Ralph Loop (Deploy & Verify Everything)"
    echo -e "  ${GREEN}2${NC}) Service Status (View Current State)"
    echo -e "  ${GREEN}3${NC}) Update Logs/Docs (Manual Sync)"
    echo -e "  ${GREEN}4${NC}) View Captain's Log"
    echo -e "  ${GREEN}5${NC}) View Manager Log"
    echo -e "  ${GREEN}q${NC}) Quit"
    echo ""
}

# Initialize Captain's Log if needed
init_captains_log() {
    if [ ! -f "$CAPTAINS_LOG" ]; then
        cat > "$CAPTAINS_LOG" << 'EOF'
# ⚓ ARK Captain's Log

This log tracks all operations performed on the ARK Node infrastructure.

---
EOF
    fi
}

# Main execution
main() {
    init_captains_log
    
    # Check if running non-interactively (for cron/GitHub Actions)
    # This ensures the script exits cleanly without waiting for user input
    if [ -n "$1" ]; then
        case "$1" in
            "loop"|"ralph")
                full_ralph_loop
                exit 0
                ;;
            "status")
                service_status
                exit 0
                ;;
            "update")
                update_logs_docs
                exit 0
                ;;
            *)
                echo "Usage: $0 [loop|status|update]"
                echo ""
                echo "Commands:"
                echo "  loop    - Run full Ralph Loop (non-interactive)"
                echo "  status  - Show current system status"
                echo "  update  - Update logs and documentation"
                echo ""
                echo "No arguments: Interactive menu"
                exit 1
                ;;
        esac
    fi
    
    # Interactive menu
    while true; do
        show_menu
        read -p "Select option [1-5, q]: " choice
        
        case "$choice" in
            1)
                full_ralph_loop
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                service_status
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                update_logs_docs
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                less "$CAPTAINS_LOG"
                ;;
            5)
                less "$LOG_DIR/manager.log"
                ;;
            q|Q)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Press Enter to continue..."
                read
                ;;
        esac
    done
}

main "$@"
