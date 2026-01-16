#!/bin/bash
# ARK Node Deployment Script
# Deploys configuration updates and verifies all services

set -e

echo "=========================================="
echo "ARK Node Deployment Script"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to ARK directory
cd /opt/ark || exit 1

echo "📋 Checking Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"

echo ""
echo "🔄 Restarting Homepage with new configuration..."
docker compose restart homepage
sleep 5

# Wait for homepage to be healthy
echo "⏳ Waiting for homepage to be ready..."
for i in {1..30}; do
    if docker ps --filter name=homepage --filter health=healthy | grep -q homepage; then
        echo -e "${GREEN}✓ Homepage is healthy${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ Homepage failed to become healthy${NC}"
        docker logs homepage --tail 20
        exit 1
    fi
    sleep 1
done

echo ""
echo "🔍 Verifying all services..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|traefik|portainer|homepage|ollama|openwebui|open-webui|jellyfin|syncthing|vaultwarden|audiobookshelf|homeassistant|kiwix|autoheal|filebrowser"

echo ""
echo "📊 Service health check..."
RUNNING=$(docker ps --filter status=running | wc -l)
TOTAL=$(docker ps -a | wc -l)
echo "Running: $((RUNNING-1)) / $((TOTAL-1)) containers"

echo ""
echo "🌐 Testing homepage API..."
if curl -sf http://localhost:3000/api/services > /dev/null; then
    echo -e "${GREEN}✓ Homepage API responding${NC}"
    
    # Count service groups
    SERVICE_GROUPS=$(curl -s http://localhost:3000/api/services | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
    echo "  Service groups configured: $SERVICE_GROUPS"
else
    echo -e "${RED}✗ Homepage API not responding${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ ARK Node deployment complete!${NC}"
echo "=========================================="
echo ""
echo "📚 Access points:"
echo "  Dashboard:       http://$(hostname -I | awk '{print $1}'):3000"
echo "  Portainer:       http://$(hostname -I | awk '{print $1}'):9000"
echo "  Traefik:         http://$(hostname -I | awk '{print $1}'):8080"
echo "  Open WebUI:      http://$(hostname -I | awk '{print $1}'):3001"
echo "  Jellyfin:        http://$(hostname -I | awk '{print $1}'):8096"
echo "  Home Assistant:  http://$(hostname -I | awk '{print $1}'):8123"
echo ""
