#!/bin/bash
################################################################################
# SECURITY-SCAN.SH - Pre-Commit Security Audit
# Part of: Project Nomad (ARK Node)
# Purpose: Scan for accidentally committed secrets before pushing to GitHub
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISSUES_FOUND=0

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           ARK SECURITY SCAN - Pre-Commit Audit                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

cd /opt/ark

# ----------------------------------------
# 1. Check for default password
# ----------------------------------------
echo -e "${YELLOW}[1/8] Scanning for default password (arknode123)...${NC}"
if git ls-files | xargs grep -l "arknode123" 2>/dev/null | grep -v ".md" | grep -v "scripts/"; then
    echo -e "${RED}✗ FAIL: Default password found in tracked files!${NC}"
    echo -e "${RED}  Action: Remove or replace with environment variables${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ PASS: No default passwords in code${NC}"
fi
echo ""

# ----------------------------------------
# 2. Check for hardcoded IPs (informational)
# ----------------------------------------
echo -e "${YELLOW}[2/8] Checking for hardcoded IP addresses...${NC}"
IP_COUNT=$(git ls-files | xargs grep -l "192.168.26.8" 2>/dev/null | wc -l)
if [ $IP_COUNT -gt 10 ]; then
    echo -e "${YELLOW}⚠ WARNING: $IP_COUNT files contain hardcoded IP${NC}"
    echo -e "${YELLOW}  Note: Some references in docs are OK${NC}"
else
    echo -e "${GREEN}✓ PASS: Minimal IP hardcoding ($IP_COUNT files)${NC}"
fi
echo ""

# ----------------------------------------
# 3. Verify vessel_secrets.env is ignored
# ----------------------------------------
echo -e "${YELLOW}[3/8] Verifying secret files are gitignored...${NC}"
if git check-ignore vessel_secrets.env >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS: vessel_secrets.env is ignored${NC}"
else
    echo -e "${RED}✗ FAIL: vessel_secrets.env is NOT ignored!${NC}"
    echo -e "${RED}  Action: Add to .gitignore immediately${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# ----------------------------------------
# 4. Check for .env files in tracked files
# ----------------------------------------
echo -e "${YELLOW}[4/8] Checking for tracked .env files...${NC}"
if git ls-files | grep "\.env$" | grep -v "example" | grep -v "gitignore"; then
    echo -e "${RED}✗ FAIL: .env files are tracked by Git!${NC}"
    echo -e "${RED}  Action: git rm --cached .env and add to .gitignore${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ PASS: No .env files tracked${NC}"
fi
echo ""

# ----------------------------------------
# 5. Check for API keys/tokens
# ----------------------------------------
echo -e "${YELLOW}[5/8] Scanning for API keys and tokens...${NC}"
if git ls-files | xargs grep -iE "api[_-]?key|api[_-]?token|secret[_-]?key" 2>/dev/null | grep -v "example" | grep -v "template" | grep -v ".md:" | grep -v "#"; then
    echo -e "${YELLOW}⚠ WARNING: Potential API keys found${NC}"
    echo -e "${YELLOW}  Review above lines - are they examples or real keys?${NC}"
else
    echo -e "${GREEN}✓ PASS: No obvious API keys detected${NC}"
fi
echo ""

# ----------------------------------------
# 6. Check for private keys
# ----------------------------------------
echo -e "${YELLOW}[6/8] Checking for private keys...${NC}"
if git ls-files | xargs grep -l "PRIVATE KEY" 2>/dev/null; then
    echo -e "${RED}✗ FAIL: Private keys found in tracked files!${NC}"
    echo -e "${RED}  Action: Remove immediately and rotate keys${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ PASS: No private keys detected${NC}"
fi
echo ""

# ----------------------------------------
# 7. Check for credentials in docker-compose
# ----------------------------------------
echo -e "${YELLOW}[7/8] Checking docker-compose.yml for hardcoded credentials...${NC}"
if grep -E "password:|token:|secret:" docker-compose.yml | grep -v "PASSWORD=" | grep -v "TOKEN=" | grep -v "#" | grep -v "\${"; then
    echo -e "${YELLOW}⚠ WARNING: Potential credentials in docker-compose.yml${NC}"
    echo -e "${YELLOW}  Review above - should use environment variables${NC}"
else
    echo -e "${GREEN}✓ PASS: docker-compose.yml uses environment variables${NC}"
fi
echo ""

# ----------------------------------------
# 8. Check what would be committed
# ----------------------------------------
echo -e "${YELLOW}[8/8] Reviewing staged changes...${NC}"
if git diff --cached --quiet; then
    echo -e "${YELLOW}  No staged changes${NC}"
else
    echo -e "${BLUE}  Staged files:${NC}"
    git diff --cached --name-only | sed 's/^/    /'
    
    # Check staged changes for secrets
    if git diff --cached | grep -iE "password|secret|token|key" | grep -v "example" | grep -v "template" | grep -v "#"; then
        echo -e "${YELLOW}⚠ WARNING: Potential secrets in staged changes${NC}"
        echo -e "${YELLOW}  Review carefully before committing${NC}"
    fi
fi
echo ""

# ----------------------------------------
# Summary
# ----------------------------------------
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                     SCAN SUMMARY                              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ SECURITY SCAN PASSED${NC}"
    echo -e "${GREEN}  No critical issues found${NC}"
    echo -e "${GREEN}  Repository appears safe for public release${NC}"
    echo ""
    echo -e "${YELLOW}Recommendations:${NC}"
    echo -e "  1. Review warnings above (if any)"
    echo -e "  2. Verify vessel_secrets.env contains your actual credentials"
    echo -e "  3. Test services after deployment"
    echo -e "  4. Complete SECURITY_CHECKLIST.md"
    echo ""
    exit 0
else
    echo -e "${RED}✗ SECURITY SCAN FAILED${NC}"
    echo -e "${RED}  Critical issues found: $ISSUES_FOUND${NC}"
    echo ""
    echo -e "${YELLOW}Required Actions:${NC}"
    echo -e "  1. Fix all FAIL items above"
    echo -e "  2. Run this scan again"
    echo -e "  3. Do NOT push to GitHub until passing"
    echo ""
    exit 1
fi
