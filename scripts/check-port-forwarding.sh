#!/bin/bash
################################################################################
# CHECK-PORT-FORWARDING.SH - Verify Port Forwarding Works
# Part of: Project Nomad (ARK Node)
# Purpose: Test if SSH port forwarding is configured correctly
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         PORT FORWARDING CHECK - ARK DEPLOYMENT                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get public IP
echo -e "${YELLOW}Detecting public IP...${NC}"
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "unknown")
echo -e "Public IP: ${BLUE}$PUBLIC_IP${NC}"
echo ""

# Get private IP
echo -e "${YELLOW}Detecting private IP...${NC}"
PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo -e "Private IP: ${BLUE}$PRIVATE_IP${NC}"
echo ""

# Check SSH service
echo -e "${YELLOW}Checking SSH service...${NC}"
if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    echo -e "${GREEN}✓ SSH service is running${NC}"
else
    echo -e "${RED}✗ SSH service is not running${NC}"
    echo "  Start with: sudo systemctl start ssh"
fi
echo ""

# Check firewall
echo -e "${YELLOW}Checking firewall...${NC}"
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(sudo ufw status | head -1)
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        echo -e "${GREEN}✓ Firewall is active${NC}"
        if sudo ufw status | grep -q "22/tcp"; then
            echo -e "${GREEN}✓ Port 22 is allowed${NC}"
        else
            echo -e "${YELLOW}⚠ Port 22 not explicitly allowed${NC}"
            echo "  Allow with: sudo ufw allow 22/tcp"
        fi
    else
        echo -e "${YELLOW}⚠ Firewall is inactive${NC}"
    fi
else
    echo -e "${YELLOW}⚠ UFW not installed (using other firewall?)${NC}"
fi
echo ""

# Check if SSH is listening
echo -e "${YELLOW}Checking if SSH is listening...${NC}"
if sudo netstat -tlnp 2>/dev/null | grep -q ":22 " || sudo ss -tlnp 2>/dev/null | grep -q ":22 "; then
    echo -e "${GREEN}✓ SSH is listening on port 22${NC}"
else
    echo -e "${RED}✗ SSH is not listening on port 22${NC}"
    echo "  Check: sudo systemctl status ssh"
fi
echo ""

# Test port forwarding (requires external tool)
echo -e "${YELLOW}Testing port forwarding...${NC}"
echo "This requires checking from outside your network."
echo ""
echo "Option 1: Use online tool"
echo -e "  Visit: ${BLUE}https://canyouseeme.org${NC}"
echo -e "  Enter port: ${BLUE}22${NC}"
echo -e "  Should say: ${GREEN}Success: I can see your service${NC}"
echo ""
echo "Option 2: Test from external network"
echo -e "  Run: ${BLUE}nc -zv $PUBLIC_IP 22${NC}"
echo "  (from a device not on your network)"
echo ""

# Router configuration reminder
echo -e "${YELLOW}Router Configuration Required:${NC}"
echo ""
echo "1. Access router: http://192.168.1.1 or http://192.168.0.1"
echo "2. Find 'Port Forwarding' or 'Virtual Server' section"
echo "3. Add rule:"
echo -e "   External Port: ${BLUE}22${NC}"
echo -e "   Internal Port: ${BLUE}22${NC}"
echo -e "   Internal IP: ${BLUE}$PRIVATE_IP${NC}"
echo -e "   Protocol: ${BLUE}TCP${NC}"
echo "4. Save and apply"
echo ""

# GitHub Secrets reminder
echo -e "${YELLOW}GitHub Secrets Configuration:${NC}"
echo ""
echo "Go to: Repository → Settings → Secrets → Actions"
echo ""
echo "Update:"
echo -e "  SSH_HOST: ${BLUE}$PUBLIC_IP${NC}  (NOT your domain if Cloudflare proxy is on)"
echo -e "  SSH_PORT: ${BLUE}22${NC}"
echo ""
echo -e "${RED}⚠ IMPORTANT:${NC} If using Cloudflare proxy (orange cloud),"
echo "   use your PUBLIC IP, not tylereno.me"
echo "   Cloudflare only proxies HTTP/HTTPS, not SSH"
echo ""

# Alternative solutions
echo -e "${YELLOW}Alternative Solutions (No Port Forwarding):${NC}"
echo ""
echo "1. Cloudflare Tunnel (Recommended)"
echo "   - No port forwarding needed"
echo "   - More secure"
echo "   - See: docs/guides/PORT_FORWARDING_SETUP.md"
echo ""
echo "2. Tailscale"
echo "   - Most secure"
echo "   - Zero trust network"
echo "   - See: docs/guides/PORT_FORWARDING_SETUP.md"
echo ""

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    CHECK COMPLETE                             ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
