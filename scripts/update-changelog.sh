#!/bin/bash
################################################################################
# UPDATE-CHANGELOG.SH - Automated Changelog Generator
# Part of: Project Nomad (ARK Node)
# Purpose: Generate changelog from git commits and Docker image changes
################################################################################

set -e

ARK_ROOT="/opt/ark"
CHANGELOG="$ARK_ROOT/docs/CHANGELOG.md"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Updating CHANGELOG.md...${NC}"

cd "$ARK_ROOT"

# Get current date
DATE=$(date -u +"%Y-%m-%d")

# Get git commit info
if [ -d .git ]; then
    COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    COMMIT_MSG=$(git log -1 --pretty=%B 2>/dev/null || echo "No commit message")
else
    COMMIT="unknown"
    COMMIT_MSG="Not a git repository"
fi

# Get Docker image versions
echo -e "${YELLOW}Checking Docker image versions...${NC}"

# Extract service names and images from docker-compose.yml
SERVICES=$(grep -E "^\s+[a-z-]+:" docker-compose.yml | sed 's/://' | sed 's/^[[:space:]]*//')

# Create changelog entry
cat >> "$CHANGELOG" << EOF

## [$DATE] - Deployment $COMMIT

### Changes
- **Commit**: $COMMIT
- **Message**: $COMMIT_MSG

### Service Versions
EOF

# Get current image versions
while IFS= read -r service; do
    if [ -n "$service" ]; then
        # Get image from docker-compose.yml
        IMAGE=$(grep -A 5 "^  $service:" docker-compose.yml | grep "image:" | head -1 | awk '{print $2}' | tr -d '"' || echo "unknown")
        
        # Get running container image
        RUNNING_IMAGE=$(docker compose ps --format json 2>/dev/null | jq -r ".[] | select(.Service==\"$service\") | .Image" 2>/dev/null | head -1 || echo "not running")
        
        if [ "$RUNNING_IMAGE" != "not running" ] && [ -n "$RUNNING_IMAGE" ]; then
            echo "- **$service**: $RUNNING_IMAGE" >> "$CHANGELOG"
        else
            echo "- **$service**: $IMAGE (not running)" >> "$CHANGELOG"
        fi
    fi
done <<< "$SERVICES"

echo "" >> "$CHANGELOG"
echo "---" >> "$CHANGELOG"

echo -e "${GREEN}✓ Changelog updated${NC}"
