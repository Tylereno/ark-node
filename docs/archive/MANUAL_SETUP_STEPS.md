# 🛠️ ARK MANUAL SETUP STEPS

**Complete Guide for Public GitHub Launch**

---

## Overview

This document provides step-by-step instructions for securing your ARK installation before making your repository public on GitHub.

**Time Required:** 30-60 minutes  
**Skill Level:** Intermediate  
**Prerequisites:** ARK installed and running

---

## Phase 1: Secret Vault Configuration (15 minutes)

### Step 1.1: Create Your Secret Vault

```bash
cd /opt/ark

# Copy the template
cp vessel_secrets.example vessel_secrets.env

# Edit with your credentials
nano vessel_secrets.env
```

### Step 1.2: Change ALL Default Passwords

In `vessel_secrets.env`, replace these values:

```bash
# CHANGE THESE:
ARK_ADMIN_PASSWORD=arknode123           → ARK_ADMIN_PASSWORD=YourStrong!Pass123
CODE_SERVER_PASSWORD=arknode123         → CODE_SERVER_PASSWORD=Another!Strong456
CODE_SERVER_SUDO_PASSWORD=arknode123    → CODE_SERVER_SUDO_PASSWORD=Sudo!Pass789
FILEBROWSER_ADMIN_TOKEN=arknode123      → FILEBROWSER_ADMIN_TOKEN=Token!XYZ999

# UPDATE THESE if using:
ARK_NODE_IP=192.168.26.8                → ARK_NODE_IP=your.actual.ip
ARK_DOMAIN=tylereno.me                  → ARK_DOMAIN=your-domain.com
```

**Password Requirements:**
- Minimum 16 characters
- Include uppercase, lowercase, numbers, symbols
- Unique for each service
- Generated with password manager (recommended)

### Step 1.3: Add Optional Credentials

If using these services, add their credentials to `vessel_secrets.env`:

```bash
# Tailscale (for remote VPN access)
TAILSCALE_AUTHKEY=tskey-auth-xxxxx-yyyyy

# Cloudflare (for tunneling/CDN)
CLOUDFLARE_TUNNEL_TOKEN=xxx
CLOUDFLARE_API_TOKEN=xxx
CLOUDFLARE_ZONE_ID=xxx

# SMTP (for email notifications)
SMTP_HOST=smtp.gmail.com
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Step 1.4: Secure the Vault

```bash
# Set restrictive permissions
chmod 600 /opt/ark/vessel_secrets.env

# Verify it's gitignored
git check-ignore vessel_secrets.env
# Should output: vessel_secrets.env

# Backup to password manager
# Copy contents to Bitwarden, 1Password, etc.
```

---

## Phase 2: Docker Compose Update (5 minutes)

### Step 2.1: Verify Environment Variable Support

Your `docker-compose.yml` should now use environment variables:

```yaml
# GOOD (uses environment variables):
environment:
  - PASSWORD=${CODE_SERVER_PASSWORD:-arknode123}
  
# BAD (hardcoded):
environment:
  - PASSWORD=arknode123
```

The syntax `${VAR:-default}` means: use environment variable `VAR`, or fall back to `default` if not set.

### Step 2.2: Load Secrets Before Starting Services

```bash
# Load secrets into environment
source /opt/ark/vessel_secrets.env

# Start services (they'll use the loaded variables)
docker compose up -d

# Verify services started
docker ps
```

### Step 2.3: Test Access with New Passwords

```bash
# Homepage (should work with no auth)
curl http://192.168.26.8:3000

# Code-Server (should require new password)
# Visit: http://192.168.26.8:8443
# Enter: Your new CODE_SERVER_PASSWORD

# FileBrowser (create new admin account)
# Visit: http://192.168.26.8:8081
```

---

## Phase 3: Cloudflare Setup (30 minutes)

### Step 3.1: Get a Domain

**Option A: Free Student Domain**
1. Visit GitHub Student Developer Pack: https://education.github.com/pack
2. Claim free `.me` domain from Namecheap
3. Choose: `yourname.me` or `ark-yourname.me`

**Option B: Purchase Domain**
1. Visit Cloudflare Registrar, Namecheap, or Porkbun
2. Purchase domain ($10-15/year)
3. Recommended: Short, memorable name

### Step 3.2: Add Domain to Cloudflare

1. **Create Cloudflare Account**
   - Go to: https://cloudflare.com
   - Sign up (use your student email for extra features)
   - Verify email

2. **Add Your Site**
   - Click: "Add a Site"
   - Enter: `yourdomain.com`
   - Select: Free plan ($0/month)
   - Click: "Add Site"

3. **Review DNS Records**
   - Cloudflare will scan existing DNS records
   - Review and confirm (or skip if new domain)
   - Click: "Continue"

4. **Update Nameservers**
   - Cloudflare shows 2 nameservers (e.g., `val.ns.cloudflare.com`)
   - Go to your domain registrar (Namecheap, etc.)
   - Find "Nameservers" or "DNS" settings
   - Change to "Custom Nameservers"
   - Replace with Cloudflare's nameservers
   - Save changes

5. **Wait for Activation**
   - Takes 5-60 minutes typically
   - Cloudflare will email when active
   - Dashboard will show "Active" status

### Step 3.3: Configure DNS Records

In Cloudflare DNS panel, add these A records:

| Type | Name | Content | Proxy | TTL |
|------|------|---------|-------|-----|
| A | @ | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | ark | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | ai | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | media | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | files | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | vault | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | code | YOUR_HOME_IP | 🟠 Proxied | Auto |
| A | git | YOUR_HOME_IP | 🟠 Proxied | Auto |
| CNAME | www | yourdomain.com | 🟠 Proxied | Auto |

**Important:** 
- 🟠 Orange Cloud = Proxied = Your real IP is hidden
- 🔒 Gray Cloud = DNS Only = Your real IP is exposed
- **Always use Orange Cloud (Proxied)** for privacy

### Step 3.4: Set Up Cloudflare Tunnel (Advanced)

**Why Tunnel?**
- No port forwarding needed
- No exposed ports on your router
- More secure than traditional reverse proxy
- Automatic SSL certificates

**Installation:**

```bash
# 1. Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# 2. Authenticate with Cloudflare
cloudflared tunnel login
# This opens browser - log in to your Cloudflare account

# 3. Create tunnel
cloudflared tunnel create ark-node
# Note the Tunnel ID shown (e.g., abc123-def456...)

# 4. Configure tunnel
nano /opt/ark/cloudflare_tunnel.yml
# Replace YOUR_TUNNEL_ID_HERE with actual ID
# Replace tylereno.me with your domain

# 5. Route DNS for each subdomain
cloudflared tunnel route dns ark-node ark.yourdomain.com
cloudflared tunnel route dns ark-node ai.yourdomain.com
cloudflared tunnel route dns ark-node media.yourdomain.com
# Repeat for each subdomain you want

# 6. Test tunnel
cloudflared tunnel run ark-node
# Should show "Connection established" messages
# Test access: https://ark.yourdomain.com

# 7. Install as system service
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared

# 8. Verify service
sudo systemctl status cloudflared
# Should show: active (running)
```

### Step 3.5: Update Vessel Secrets

```bash
nano /opt/ark/vessel_secrets.env

# Add your domain
ARK_DOMAIN=yourdomain.com

# Add Cloudflare credentials (from dashboard)
CLOUDFLARE_API_TOKEN=your-token-here
CLOUDFLARE_ZONE_ID=your-zone-id-here
CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
```

---

## Phase 4: Firewall Configuration (10 minutes)

### Step 4.1: Enable UFW (Ubuntu Firewall)

```bash
# Enable firewall
sudo ufw enable

# Allow SSH (CRITICAL - don't lock yourself out!)
sudo ufw allow 22/tcp

# Check status
sudo ufw status
```

### Step 4.2: Configure Rules

**If Using Cloudflare Tunnel:**
```bash
# Only allow Cloudflare IPs (most secure)
sudo ufw allow from 173.245.48.0/20
sudo ufw allow from 103.21.244.0/22
sudo ufw allow from 103.22.200.0/22
sudo ufw allow from 103.31.4.0/22
sudo ufw allow from 141.101.64.0/18
sudo ufw allow from 108.162.192.0/18
sudo ufw allow from 190.93.240.0/20
sudo ufw allow from 188.114.96.0/20
sudo ufw allow from 197.234.240.0/22
sudo ufw allow from 198.41.128.0/17
sudo ufw allow from 2400:cb00::/32
sudo ufw allow from 2606:4700::/32
sudo ufw allow from 2803:f800::/32
sudo ufw allow from 2405:b500::/32
sudo ufw allow from 2405:8100::/32
sudo ufw allow from 2a06:98c0::/29
sudo ufw allow from 2c0f:f248::/32
```

**If NOT Using Cloudflare Tunnel:**
```bash
# Allow specific service ports
sudo ufw allow 3000/tcp  # Homepage
sudo ufw allow 3001/tcp  # Open WebUI
sudo ufw allow 3002/tcp  # Gitea
sudo ufw allow 8081/tcp  # FileBrowser
sudo ufw allow 8082/tcp  # Vaultwarden
sudo ufw allow 8096/tcp  # Jellyfin
sudo ufw allow 8443/tcp  # Code-Server
```

### Step 4.3: Install Fail2Ban

```bash
# Install
sudo apt update
sudo apt install fail2ban

# Configure
sudo nano /etc/fail2ban/jail.local
```

Add:
```ini
[DEFAULT]
bantime = 3600
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = %(sshd_log)s
```

```bash
# Start service
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status sshd
```

---

## Phase 5: GitHub Preparation (10 minutes)

### Step 5.1: Run Security Scan

```bash
cd /opt/ark

# Run comprehensive security scan
./scripts/security-scan.sh
```

**Expected Output:**
```
✓ SECURITY SCAN PASSED
  No critical issues found
  Repository appears safe for public release
```

**If scan fails:** Fix all issues before continuing.

### Step 5.2: Review What Will Be Published

```bash
# Check git status
git status

# List all tracked files
git ls-files

# Verify no secrets in tracked files
git ls-files | xargs grep -i "arknode123" || echo "✓ Clean"

# Check what's ignored
git status --ignored | head -20
```

### Step 5.3: Create GitHub Repository

1. **Go to GitHub.com**
2. **Click:** "New Repository"
3. **Settings:**
   - Name: `ark` or `project-nomad`
   - Description: "Autonomous Resilience Kit - Self-hosted stack for digital nomads"
   - Visibility: Public (or Private initially)
   - **DO NOT** initialize with README (you have one)
4. **Create Repository**

### Step 5.4: Add Remote and Push

```bash
cd /opt/ark

# Add GitHub as remote
git remote add origin https://github.com/YOUR-USERNAME/ark.git

# Or use SSH (if keys configured)
git remote add origin git@github.com:YOUR-USERNAME/ark.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 5.5: Add GitHub Secrets (for Actions)

If using GitHub Actions for CI/CD:

1. **Go to:** Repository Settings → Secrets and variables → Actions
2. **Add Secrets:**
   - Click "New repository secret"
   - Add each variable from `vessel_secrets.env`:
     - `ARK_ADMIN_PASSWORD`
     - `CODE_SERVER_PASSWORD`
     - `TAILSCALE_AUTHKEY`
     - `CLOUDFLARE_API_TOKEN`
     - etc.

---

## Phase 6: Final Verification (10 minutes)

### Step 6.1: Test Local Access

```bash
# Load secrets
source /opt/ark/vessel_secrets.env

# Restart services
docker compose restart

# Check all containers
docker ps

# Test each service
curl http://192.168.26.8:3000  # Homepage
curl http://192.168.26.8:3001  # Open WebUI
curl http://192.168.26.8:8096  # Jellyfin
```

### Step 6.2: Test Remote Access (if Cloudflare configured)

```bash
# Test from external network or use your phone (off WiFi)
curl -I https://ark.yourdomain.com
# Should return: 200 OK

# Visit in browser
# https://ark.yourdomain.com
# https://ai.yourdomain.com
# https://media.yourdomain.com
```

### Step 6.3: Complete Security Checklist

```bash
# Open checklist
nano /opt/ark/SECURITY_CHECKLIST.md

# Go through each item
# Check off completed items
```

### Step 6.4: Backup Everything

```bash
# Backup configs
tar -czf ~/ark-configs-backup-$(date +%Y%m%d).tar.gz /opt/ark/configs/

# Backup vessel_secrets.env to password manager
# (Copy contents to Bitwarden, 1Password, etc.)

# Export to USB drive (if available)
cp /opt/ark/vessel_secrets.env /media/usb-drive/ark-secrets-backup.env
```

---

## Phase 7: Going Public (5 minutes)

### Step 7.1: Announce on Social Media

**Hacker News:**
```
Title: Show HN: ARK - Self-hosted stack for digital nomads
URL: https://github.com/YOUR-USERNAME/ark

ARK (Autonomous Resilience Kit) is a 16-service Docker stack providing AI,
media, files, and automation for digital nomads and off-grid living.

Works offline, respects privacy, zero subscriptions. Built with Ollama,
Jellyfin, Vaultwarden, and more.
```

**Reddit (r/selfhosted):**
```
Title: [PROJECT] ARK - Complete self-hosted stack for digital nomads

I built ARK, a comprehensive self-hosted platform optimized for nomadic
lifestyles and off-grid scenarios. Includes AI (Ollama), media (Jellyfin),
passwords (Vaultwarden), offline Wikipedia, and 12 other services.

GitHub: [link]
Docs: Well... comprehensive
Status: Production-ready (running on my Node for 6+ months)
```

### Step 7.2: Monitor Initial Response

- Watch GitHub Stars/Forks
- Respond to issues promptly
- Engage in discussions
- Fix bugs quickly
- Gather feedback

---

## Troubleshooting

### "Docker won't start with environment variables"

```bash
# Make sure to source secrets first
source /opt/ark/vessel_secrets.env

# Then start
docker compose up -d

# Verify variables loaded
echo $ARK_ADMIN_PASSWORD
```

### "Cloudflare tunnel not connecting"

```bash
# Check tunnel status
cloudflared tunnel list

# View logs
sudo journalctl -u cloudflared -f

# Test connectivity
cloudflared tunnel run ark-node

# Verify config
cat /opt/ark/cloudflare_tunnel.yml
```

### "Can't access services remotely"

1. Check Cloudflare proxy is ON (orange cloud)
2. Verify DNS records are correct
3. Check firewall: `sudo ufw status`
4. Test local access first: `curl http://192.168.26.8:3000`
5. Check tunnel logs: `sudo journalctl -u cloudflared -f`

### "Security scan failing"

```bash
# Run scan
./scripts/security-scan.sh

# Fix reported issues
# Most common: Remove hardcoded passwords from docker-compose.yml

# Re-run until passing
./scripts/security-scan.sh
```

---

## Post-Launch Maintenance

### Weekly
- [ ] Check for Docker image updates
- [ ] Review access logs
- [ ] Verify backups working

### Monthly
- [ ] Update system packages: `sudo apt update && sudo apt upgrade`
- [ ] Review security advisories
- [ ] Test backup restoration
- [ ] Rotate passwords (optional)

### Quarterly
- [ ] Full security audit
- [ ] Review firewall rules
- [ ] Update documentation
- [ ] Check for new Cloudflare features

---

## Quick Reference Commands

```bash
# Load secrets
source /opt/ark/vessel_secrets.env

# Start services
docker compose up -d

# Check status
docker ps

# View logs
docker compose logs -f

# Restart service
docker compose restart servicename

# Security scan
./scripts/security-scan.sh

# Firewall status
sudo ufw status

# Tunnel status
sudo systemctl status cloudflared

# Download status
bash /opt/ark/scripts/check-downloads.sh
```

---

## Support

- **Documentation:** `/opt/ark/docs/`
- **Security Guide:** `/opt/ark/docs/guides/SECURITY_SETUP.md`
- **GitHub Issues:** Your repo's Issues tab
- **Discord/Forum:** (If you create community channels)

---

## Conclusion

**You've successfully:**
- ✅ Secured your ARK installation
- ✅ Protected secrets from Git
- ✅ Configured Cloudflare for privacy
- ✅ Set up firewall protection
- ✅ Published to GitHub
- ✅ Launched publicly

**Your ARK is now ready for the world!** 🚀

---

*"Your Digital Life, Untethered"*

**Version:** 1.0  
**Last Updated:** 2026-01-15  
**Status:** Production Ready
