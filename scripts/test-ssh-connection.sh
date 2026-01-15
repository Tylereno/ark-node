#!/bin/bash
################################################################################
# TEST-SSH-CONNECTION.SH - Verify SSH Key Works
# Part of: Project Nomad (ARK Node)
# Purpose: Test SSH connection before GitHub Actions deployment
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           SSH CONNECTION TEST - ARK DEPLOYMENT                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if key file exists
KEY_FILE="$HOME/.ssh/github_actions_ark"
if [ ! -f "$KEY_FILE" ]; then
    echo -e "${RED}✗ SSH key not found: $KEY_FILE${NC}"
    echo ""
    echo "Generate it with:"
    echo "  ssh-keygen -t ed25519 -C \"github-actions-ark\" -f $KEY_FILE"
    echo "  (Press Enter for no passphrase - required for automation)"
    exit 1
fi

echo -e "${GREEN}✓ SSH key found: $KEY_FILE${NC}"

# Check if key has passphrase
if ssh-keygen -y -f "$KEY_FILE" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Key has no passphrase (good for automation)${NC}"
else
    echo -e "${RED}✗ Key requires passphrase (will fail in GitHub Actions)${NC}"
    echo ""
    echo "Regenerate without passphrase:"
    echo "  ssh-keygen -t ed25519 -C \"github-actions-ark\" -f $KEY_FILE"
    echo "  (Press Enter when asked for passphrase)"
    exit 1
fi

# Get server details
read -p "Enter server IP or hostname: " SERVER_HOST
read -p "Enter SSH username [default: $USER]: " SERVER_USER
SERVER_USER=${SERVER_USER:-$USER}
read -p "Enter SSH port [default: 22]: " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-22}

echo ""
echo -e "${YELLOW}Testing SSH connection...${NC}"
echo "Host: $SERVER_HOST"
echo "User: $SERVER_USER"
echo "Port: $SERVER_PORT"
echo "Key: $KEY_FILE"
echo ""

# Test connection
if ssh -i "$KEY_FILE" -p "$SERVER_PORT" -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
   "$SERVER_USER@$SERVER_HOST" "echo 'SSH connection successful!'" 2>&1; then
    echo ""
    echo -e "${GREEN}✅ SSH CONNECTION SUCCESSFUL${NC}"
    echo ""
    
    # Test Docker access
    echo -e "${YELLOW}Testing Docker access...${NC}"
    if ssh -i "$KEY_FILE" -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" \
       "docker --version && docker compose version" 2>&1; then
        echo -e "${GREEN}✅ Docker access confirmed${NC}"
    else
        echo -e "${YELLOW}⚠ Docker not accessible (may need sudo)${NC}"
    fi
    
    # Test ARK directory
    echo ""
    echo -e "${YELLOW}Testing ARK directory...${NC}"
    if ssh -i "$KEY_FILE" -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" \
       "cd /opt/ark && pwd && ls -la docker-compose.yml" 2>&1; then
        echo -e "${GREEN}✅ ARK directory accessible${NC}"
    else
        echo -e "${YELLOW}⚠ ARK directory not found or not accessible${NC}"
        echo "  Create it with: sudo mkdir -p /opt/ark"
    fi
    
    # Check authorized_keys
    echo ""
    echo -e "${YELLOW}Checking authorized_keys...${NC}"
    PUB_KEY=$(ssh-keygen -y -f "$KEY_FILE")
    if ssh -i "$KEY_FILE" -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" \
       "grep -q '$(echo "$PUB_KEY" | cut -d' ' -f1-2)' ~/.ssh/authorized_keys 2>/dev/null && echo 'found' || echo 'not found'" 2>&1 | grep -q "found"; then
        echo -e "${GREEN}✅ Public key found in authorized_keys${NC}"
    else
        echo -e "${RED}✗ Public key NOT in authorized_keys${NC}"
        echo ""
        echo "Add it with:"
        echo "  cat $KEY_FILE.pub | ssh $SERVER_USER@$SERVER_HOST 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'"
    fi
    
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    TEST COMPLETE                              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Your SSH setup looks good for GitHub Actions!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Copy private key to GitHub Secrets:"
    echo "   cat $KEY_FILE"
    echo "   (Copy entire output, including -----BEGIN and -----END lines)"
    echo ""
    echo "2. Add to GitHub:"
    echo "   Repository → Settings → Secrets → Actions → New secret"
    echo "   Name: SSH_PRIVATE_KEY"
    echo "   Value: (paste the private key)"
    echo ""
    echo "3. Add other secrets:"
    echo "   SSH_HOST: $SERVER_HOST"
    echo "   SSH_USERNAME: $SERVER_USER"
    echo "   SSH_PORT: $SERVER_PORT"
    
else
    echo ""
    echo -e "${RED}✗ SSH CONNECTION FAILED${NC}"
    echo ""
    echo "Common issues:"
    echo "1. Public key not in server's ~/.ssh/authorized_keys"
    echo "   Fix: cat $KEY_FILE.pub | ssh $SERVER_USER@$SERVER_HOST 'cat >> ~/.ssh/authorized_keys'"
    echo ""
    echo "2. Firewall blocking port $SERVER_PORT"
    echo "   Fix: sudo ufw allow $SERVER_PORT/tcp"
    echo ""
    echo "3. SSH service not running"
    echo "   Fix: sudo systemctl status ssh"
    echo ""
    echo "4. Wrong username or host"
    echo "   Fix: Verify server details"
    exit 1
fi
