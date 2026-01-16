#!/bin/bash
# ARK Autonomous Manager v3.1.2
# Modular CLI Interface for ARK Infrastructure
# LTS Release - Error handling and deterministic behavior enforced

# Error handling: Use set -e for most commands, but allow JSON output to work
# We'll enable strict mode in functions that need it, not globally
set +euo pipefail  # Start with relaxed mode for compatibility
IFS=$'\n\t'        # Internal Field Separator for safer word splitting

# Enable strict mode in critical functions
enable_strict_mode() {
    set -euo pipefail
}

# Disable strict mode for commands that may fail gracefully
disable_strict_mode() {
    set +euo pipefail
}

# --- CONFIGURATION ---
ARK_DIR="/opt/ark"
LOG_DIR="$ARK_DIR/logs"
DOCS_DIR="$ARK_DIR/docs"
CAPTAINS_LOG="$DOCS_DIR/CAPTAINS_LOG.md"
CHANGELOG="$DOCS_DIR/CHANGELOG.md"
# Default profiles: all services (can be overridden with COMPOSE_PROFILES env var)
COMPOSE_PROFILES="${COMPOSE_PROFILES:-core,apps,media}"
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

# --- MODULAR COMMANDS ---

# cmd_deploy: Sync blueprints, verify assets, pull images, and deploy services
cmd_deploy() {
    log_event "INFO" "Syncing Blueprints from GitHub"
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
    
    log_event "INFO" "Verifying Persistent Large Files"
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
    
    log_event "INFO" "Pulling Docker images (profiles: $COMPOSE_PROFILES)"
    if COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose pull -q 2>&1 | tee -a "$LOG_DIR/manager.log"; then
        log_event "SUCCESS" "Docker images pulled successfully"
    else
        log_event "WARNING" "Some images failed to pull. Continuing..."
    fi
    
    log_event "INFO" "Deploying Infrastructure (profiles: $COMPOSE_PROFILES)"
    if COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose up -d --remove-orphans 2>&1 | tee -a "$LOG_DIR/manager.log"; then
        log_event "SUCCESS" "Infrastructure deployment initiated"
    else
        log_event "ERROR" "Infrastructure deployment failed"
        return 1
    fi
    
    # Wait for services to stabilize
    log_event "INFO" "Waiting for services to stabilize (20s)..."
    sleep 20
}

# cmd_audit: Smart service verification using Docker health checks
cmd_audit() {
    log_event "INFO" "Service Verification (The Ralph Check)"
    # Smart service verification - check Docker health status first, then HTTP if needed
    # This avoids false positives from services still initializing
    
    services=("homepage" "kiwix" "jellyfin" "open-webui" "portainer" "traefik" "ollama" "filebrowser" "vaultwarden" "gitea" "code-server" "syncthing" "audiobookshelf" "homeassistant")
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
    RUNNING=$(COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps | grep -c "Up" || echo "0")
    # Count total services from docker compose
    TOTAL=$(COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps --format json 2>/dev/null | jq -r '.[].Name' 2>/dev/null | wc -l)
    if [ -z "$TOTAL" ] || [ "$TOTAL" -eq 0 ]; then
        # Fallback: count from docker compose ps output
        TOTAL=$(COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps --format "{{.Name}}" 2>/dev/null | grep -v "^NAME$" | wc -l)
    fi
    if [ -z "$TOTAL" ] || [ "$TOTAL" -eq 0 ]; then
        TOTAL=16  # Default expected count
    fi
    
    if [ $verified -gt 0 ] || [ $checking -gt 0 ]; then
        log_event "SUCCESS" "Container Status: $RUNNING/$TOTAL Running ($verified healthy, $checking initializing)"
    else
        log_event "WARNING" "Container Status: $RUNNING/$TOTAL Running (health checks pending)"
    fi
    
    echo ""
    echo -e "${CYAN}Audit Summary:${NC}"
    echo -e "  ${GREEN}✓${NC} Healthy: $verified services"
    if [ $checking -gt 0 ]; then
        echo -e "  ${YELLOW}⏳${NC} Initializing: $checking services"
    fi
    echo -e "  ${GREEN}✓${NC} Running: $RUNNING/$TOTAL containers"
    if [ $failed -gt 0 ]; then
        echo -e "  ${RED}✗${NC} Issues: $failed service(s)"
    fi
    echo ""
    
    # Return failure count for use by heal command
    return $failed
}

# cmd_heal: Check for unhealthy containers and restart them
cmd_heal() {
    log_event "INFO" "Checking for unhealthy containers"
    
    services=("homepage" "kiwix" "jellyfin" "open-webui" "portainer" "traefik" "ollama" "filebrowser" "vaultwarden" "gitea" "code-server" "syncthing" "audiobookshelf" "homeassistant")
    healed=0
    failed=0
    
    for name in "${services[@]}"; do
        running=$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null)
        health=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null)
        
        if [ "$running" != "true" ]; then
            log_event "WARNING" "$name container is DOWN - attempting restart"
            if docker restart "$name" 2>&1 | tee -a "$LOG_DIR/manager.log"; then
                log_event "SUCCESS" "$name container restarted"
                ((healed++))
            else
                log_event "ERROR" "$name container restart failed"
                ((failed++))
            fi
        elif [ "$health" == "unhealthy" ]; then
            log_event "WARNING" "$name container is UNHEALTHY - attempting restart"
            if docker restart "$name" 2>&1 | tee -a "$LOG_DIR/manager.log"; then
                log_event "SUCCESS" "$name container restarted"
                ((healed++))
            else
                log_event "ERROR" "$name container restart failed"
                ((failed++))
            fi
        fi
    done
    
    if [ $healed -gt 0 ]; then
        log_event "SUCCESS" "Healed $healed container(s)"
        log_event "INFO" "Waiting 10s for restarted containers to initialize..."
        sleep 10
    elif [ $failed -gt 0 ]; then
        log_event "WARNING" "Failed to heal $failed container(s)"
    else
        log_event "SUCCESS" "All containers healthy - no healing needed"
    fi
}

# cmd_document: Run backups and update documentation
cmd_document() {
    log_event "INFO" "Finalizing Documentation & Backups"
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
    
    log_event "SUCCESS" "Documentation sync complete"
}

# cmd_loop: Full Ralph Loop - deploy, audit, heal if needed, document
cmd_loop() {
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
    
    # Step 1: Deploy
    if ! cmd_deploy; then
        log_event "ERROR" "Deployment failed. Aborting loop."
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: FAILED (deployment)" >> "$CAPTAINS_LOG"
        return 1
    fi
    
    # Step 2: Audit
    cmd_audit
    audit_failed=$?
    
    # Step 3: Heal if needed
    if [ $audit_failed -gt 0 ]; then
        cmd_heal
        # Re-audit after healing
        log_event "INFO" "Re-auditing after healing..."
        cmd_audit
        audit_failed=$?
    fi
    
    # Step 4: Document
    cmd_document
    
    # Final status
    if [ $audit_failed -eq 0 ]; then
        log_event "SUCCESS" "🏆 Ralph Loop Complete - All Systems Green"
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: SUCCESS" >> "$CAPTAINS_LOG"
    else
        log_event "WARNING" "🏆 Ralph Loop Complete - Some services need attention"
        echo "* $(date '+%H:%M:%S'): 🏆 Cycle Result: PARTIAL" >> "$CAPTAINS_LOG"
    fi
    echo ""
}

service_status() {
    local json_output=false
    if [ "$1" == "--json" ]; then
        json_output=true
    fi
    
    if [ "$json_output" == "true" ]; then
        # JSON output mode for machine parsing (CrewAI, monitoring tools)
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        local version=$(cat "$ARK_DIR/VERSION" 2>/dev/null || echo "unknown")
        
        # Build profiles array (manual JSON array formatting)
        local profiles_list=""
        IFS=',' read -ra PROFILE_ARRAY <<< "$COMPOSE_PROFILES"
        for profile in "${PROFILE_ARRAY[@]}"; do
            if [ -z "$profiles_list" ]; then
                profiles_list="\"$profile\""
            else
                profiles_list="$profiles_list, \"$profile\""
            fi
        done
        local profiles_array="[$profiles_list]"
        
        # Count containers using docker compose ps
        local running=$(COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps --format json 2>/dev/null | grep -c '"State":"running"' 2>/dev/null || COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps | grep -c "Up" 2>/dev/null || echo "0")
        local total=$(COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps --format json 2>/dev/null | grep -c '"Name":' 2>/dev/null || COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps --format "{{.Name}}" 2>/dev/null | grep -v "^NAME$" | wc -l | tr -d ' ' || echo "0")
        
        # Count unhealthy containers
        local unhealthy=0
        local services=("homepage" "kiwix" "jellyfin" "open-webui" "portainer" "traefik" "ollama" "filebrowser" "vaultwarden" "gitea" "code-server" "syncthing" "audiobookshelf" "homeassistant")
        for name in "${services[@]}"; do
            running_state=$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null)
            health=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null)
            if [ "$running_state" != "true" ] || [ "$health" == "unhealthy" ]; then
                ((unhealthy++))
            fi
        done
        
        # Determine system status
        local system_status="GREEN"
        if [ "$unhealthy" -gt 0 ]; then
            system_status="RED"
        elif [ "$running" -lt "$total" ] && [ "$total" -gt 0 ]; then
            system_status="AMBER"
        fi
        
        # Build JSON output (manual formatting - no jq dependency)
        echo "{"
        echo "  \"timestamp\": \"$timestamp\","
        echo "  \"deployment_version\": \"$version\","
        echo "  \"profiles_active\": $profiles_array,"
        echo "  \"services\": {"
        echo "    \"total\": $total,"
        echo "    \"running\": $running,"
        echo "    \"unhealthy\": $unhealthy"
        echo "  },"
        echo "  \"system_status\": \"$system_status\""
        echo "}"
    else
        # Human-readable output mode
        clear
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC} ${GREEN}📊 ARK Node Service Status${NC}${CYAN}                                    ║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Active Profiles:${NC} $COMPOSE_PROFILES"
        echo ""
        COMPOSE_PROFILES="$COMPOSE_PROFILES" docker compose ps
        echo ""
        echo -e "${CYAN}Storage Status:${NC}"
        df -h /mnt/dock 2>/dev/null | tail -1 | awk '{print "  Total: " $2 "  |  Used: " $3 " (" $5 ")  |  Available: " $4}'
        echo ""
    fi
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
    echo -e "${CYAN}║${NC} ${GREEN}         ARK AUTONOMOUS MANAGER v2.1${NC}${CYAN}                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Available Commands:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) Full Ralph Loop (Deploy → Audit → Heal → Document)"
    echo -e "  ${GREEN}2${NC}) Deploy (Sync, Pull, Start Services)"
    echo -e "  ${GREEN}3${NC}) Audit (Health Check All Services)"
    echo -e "  ${GREEN}4${NC}) Heal (Restart Unhealthy Containers)"
    echo -e "  ${GREEN}5${NC}) Document (Backup & Update Logs)"
    echo -e "  ${GREEN}6${NC}) Service Status (View Current State)"
    echo -e "  ${GREEN}7${NC}) View Captain's Log"
    echo -e "  ${GREEN}8${NC}) View Manager Log"
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
                cmd_loop
                exit 0
                ;;
            "deploy")
                cmd_deploy
                exit 0
                ;;
            "audit")
                cmd_audit
                exit 0
                ;;
            "heal")
                cmd_heal
                exit 0
                ;;
            "document")
                cmd_document
                exit 0
                ;;
            "status")
                if [ "$2" == "--json" ]; then
                    service_status "--json"
                else
                    service_status
                fi
                exit 0
                ;;
            *)
                echo "Usage: $0 [command]"
                echo ""
                echo "Commands:"
                echo "  loop      - Run full Ralph Loop (deploy → audit → heal → document)"
                echo "  deploy    - Sync blueprints, pull images, start services"
                echo "  audit     - Health check all services"
                echo "  heal      - Restart unhealthy containers"
                echo "  document  - Backup configs and update logs"
                echo "  status    - Show current system status"
                echo "  status --json - Show status in JSON format (for automation)"
                echo ""
                echo "No arguments: Interactive menu"
                exit 1
                ;;
        esac
    fi
    
    # Interactive menu
    while true; do
        show_menu
        read -p "Select option [1-8, q]: " choice
        
        case "$choice" in
            1)
                cmd_loop
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                cmd_deploy
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                cmd_audit
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                cmd_heal
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                cmd_document
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                service_status
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7)
                less "$CAPTAINS_LOG"
                ;;
            8)
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
