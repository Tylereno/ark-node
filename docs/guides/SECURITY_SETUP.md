# ARK Security Setup Guide

**Preparing ARK for Public Deployment**

---

## Overview

This guide walks you through securing your ARK installation before making your repository public or exposing services to the internet.

**Security Principles:**
1. 🔒 Never commit secrets to Git
2. 🌐 Hide your home IP with Cloudflare
3. 🔑 Use strong, unique passwords
4. 📝 Keep sensitive data in secure vaults
5. 🛡️ Enable firewall and fail2ban

---

## Step 1: Secret Management

### Create Your Secret Vault

```bash
# Copy the example template
cp /opt/ark/vessel_secrets.example /opt/ark/vessel_secrets.env

# Edit with your actual credentials
nano /opt/ark/vessel_secrets.env
```

### Change Default Passwords

**CRITICAL:** Change these immediately:

```bash
# In vessel_secrets.env, replace:
ARK_ADMIN_PASSWORD=arknode123      # Change to strong password
CODE_SERVER_PASSWORD=arknode123    # Change to strong password
FILEBROWSER_ADMIN_TOKEN=arknode123 # Change to strong token
```

**Password Requirements:**
- Minimum 16 characters
- Mix of uppercase, lowercase, numbers, symbols
- Use a password manager (Bitwarden/Vaultwarden)
- Different password for each service

### Load Secrets

```bash
# Source the secrets before starting services
source /opt/ark/vessel_secrets.env
docker compose up -d
```

---

## Step 2: Git Protection

### Verify .gitignore

Your `.gitignore` already protects:
- `vessel_secrets.env`
- `.env` and `.env.*`
- All `*.key`, `*.pem`, `*.crt` files
- `configs/` directories with sensitive data

### Scan for Leaks

```bash
# Check for accidentally committed secrets
cd /opt/ark
git ls-files | xargs grep -l "arknode123" || echo "✓ No default passwords in tracked files"

# Check for IP addresses (less critical but good practice)
git ls-files | xargs grep -l "192.168" || echo "✓ No hardcoded IPs in tracked files"
```

### Before Pushing to GitHub

```bash
# Final security scan
./scripts/security-scan.sh

# Review what will be committed
git status
git diff

# Never add vessel_secrets.env!
git add .
git commit -m "Public release preparation"
git push origin main
```

---

## Step 3: Cloudflare Setup (Recommended)

Cloudflare protects your home IP and provides free SSL certificates.

### 3.1: Get a Domain

**Option A: Free Student Domain**
- Use GitHub Student Developer Pack
- Get `.me` domain free via Namecheap
- Recommended: `your name.me`

**Option B: Purchase Domain**
- Any registrar (Namecheap, Cloudflare, Porkbun)
- Cost: $10-15/year

### 3.2: Add Domain to Cloudflare

1. **Create Cloudflare Account**
   - Go to: https://cloudflare.com
   - Sign up (free plan works perfectly)

2. **Add Your Site**
   - Dashboard → Add Site
   - Enter your domain (e.g., `tylereno.me`)
   - Select Free plan

3. **Update Nameservers**
   - Cloudflare will show 2 nameservers
   - Go to your domain registrar
   - Replace nameservers with Cloudflare's
   - Wait 5-60 minutes for propagation

4. **Verify Setup**
   - Cloudflare will email when active
   - Status will show "Active" in dashboard

### 3.3: Create DNS Records

In Cloudflare DNS settings:

```
Type    Name    Content           Proxy   TTL
A       @       YOUR_HOME_IP      🟠 On   Auto
A       ark     YOUR_HOME_IP      🟠 On   Auto
A       ai      YOUR_HOME_IP      🟠 On   Auto
A       media   YOUR_HOME_IP      🟠 On   Auto
A       files   YOUR_HOME_IP      🟠 On   Auto
A       vault   YOUR_HOME_IP      🟠 On   Auto
CNAME   www     tylereno.me       🟠 On   Auto
```

**Important:** Orange cloud (🟠) = Proxied = Your real IP is hidden!

### 3.4: Set Up Cloudflare Tunnel (Advanced)

**Why:** Even more secure than port forwarding.

1. **Install cloudflared**
   ```bash
   wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
   sudo dpkg -i cloudflared-linux-amd64.deb
   ```

2. **Authenticate**
   ```bash
   cloudflared tunnel login
   # Opens browser, log in to Cloudflare
   ```

3. **Create Tunnel**
   ```bash
   cloudflared tunnel create ark-node
   # Note the tunnel ID shown
   ```

4. **Configure Tunnel**
   ```bash
   # Edit the config
   nano /opt/ark/cloudflare_tunnel.yml
   
   # Add your tunnel ID (replace YOUR_TUNNEL_ID_HERE)
   # Customize the hostnames for your domain
   ```

5. **Route DNS**
   ```bash
   cloudflared tunnel route dns ark-node ark.tylereno.me
   cloudflared tunnel route dns ark-node ai.tylereno.me
   # Repeat for each subdomain
   ```

6. **Start Tunnel**
   ```bash
   # Test run
   cloudflared tunnel run ark-node
   
   # If working, install as service
   sudo cloudflared service install
   sudo systemctl start cloudflared
   sudo systemctl enable cloudflared
   ```

7. **Verify**
   ```bash
   # Check status
   sudo systemctl status cloudflared
   
   # Test access
   curl https://ark.tylereno.me
   ```

---

## Step 4: Firewall Configuration

### UFW (Ubuntu Firewall)

```bash
# Enable firewall
sudo ufw enable

# Allow SSH (IMPORTANT - don't lock yourself out!)
sudo ufw allow 22/tcp

# If using Cloudflare Tunnel, ONLY allow Cloudflare IPs
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

# OR if NOT using Cloudflare Tunnel, allow your services
sudo ufw allow 3000/tcp  # Homepage
sudo ufw allow 3001/tcp  # Open WebUI
sudo ufw allow 8096/tcp  # Jellyfin
# etc.

# Check status
sudo ufw status
```

### Fail2Ban (Brute Force Protection)

```bash
# Install
sudo apt install fail2ban

# Create jail for SSH
sudo nano /etc/fail2ban/jail.local
```

Add:
```ini
[sshd]
enabled = true
port = 22
maxretry = 5
bantime = 3600
```

```bash
# Start service
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status sshd
```

---

## Step 5: GitHub Secrets (For CI/CD)

If using GitHub Actions:

1. **Go to GitHub Repository Settings**
   - Settings → Secrets and variables → Actions

2. **Add Repository Secrets**
   - Click "New repository secret"
   - Add each variable from `vessel_secrets.env`:
     - `ARK_ADMIN_PASSWORD`
     - `CLOUDFLARE_API_TOKEN`
     - `TAILSCALE_AUTHKEY`
     - etc.

3. **Reference in Workflows**
   ```yaml
   - name: Deploy ARK
     env:
       ARK_ADMIN_PASSWORD: ${{ secrets.ARK_ADMIN_PASSWORD }}
     run: |
       docker compose up -d
   ```

---

## Step 6: SSL Certificates

### Option A: Cloudflare (Easiest)

Cloudflare provides free SSL automatically when proxied (orange cloud enabled).

### Option B: Let's Encrypt (Self-hosted)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d ark.tylereno.me

# Auto-renewal
sudo systemctl enable certbot.timer
```

---

## Step 7: Security Audit

### Run Security Checks

```bash
# Check for exposed secrets
cd /opt/ark
grep -r "password\|secret\|token" docker-compose.yml | grep -v "{{" | grep -v "#"

# Check Git status
git status
git ls-files | wc -l

# Verify secrets file is ignored
git check-ignore vessel_secrets.env
# Should output: vessel_secrets.env

# Test secret loading
source vessel_secrets.env
echo $ARK_ADMIN_PASSWORD  # Should show your password
```

### Security Checklist

- [ ] Changed all default passwords
- [ ] `vessel_secrets.env` created and populated
- [ ] `vessel_secrets.env` is in `.gitignore`
- [ ] No secrets in `docker-compose.yml`
- [ ] Cloudflare proxy enabled (orange cloud)
- [ ] Firewall configured (UFW)
- [ ] Fail2Ban installed and running
- [ ] SSH keys used instead of passwords
- [ ] GitHub secrets added (if using Actions)
- [ ] SSL certificates active
- [ ] Regular backups configured

---

## Step 8: Backup Your Secrets

### Secure Storage Options

1. **Password Manager** (Recommended)
   - Save `vessel_secrets.env` in Bitwarden/1Password
   - Encrypted, synchronized, accessible

2. **Encrypted USB Drive**
   - Copy to encrypted drive
   - Store in secure location

3. **Paper Backup** (Last Resort)
   - Print critical credentials
   - Store in safe/lockbox

### Never Store Secrets In:
- ❌ Git/GitHub (even private repos)
- ❌ Unencrypted cloud storage (Dropbox, Google Drive)
- ❌ Email
- ❌ Slack/Discord messages
- ❌ Plain text files on your desktop

---

## Troubleshooting

### "Environment variable not set"

```bash
# Load secrets before docker compose
source /opt/ark/vessel_secrets.env
docker compose up -d
```

### "Cloudflare tunnel not connecting"

```bash
# Check logs
sudo journalctl -u cloudflared -f

# Verify tunnel exists
cloudflared tunnel list

# Test connectivity
cloudflared tunnel run ark-node
```

### "Can't access services remotely"

1. Check Cloudflare proxy is ON (orange cloud)
2. Verify DNS records are correct
3. Check firewall rules: `sudo ufw status`
4. Test local access first: `curl http://192.168.26.8:3000`

---

## Resources

- **Cloudflare Tunnel Docs:** https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **GitHub Secrets:** https://docs.github.com/en/actions/security-guides/encrypted-secrets
- **UFW Guide:** https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
- **Fail2Ban:** https://www.fail2ban.org/

---

**Remember:** Security is a process, not a one-time setup. Review and update regularly.

**Next:** [Remote Access Guide](REMOTE_ACCESS.md) | [Backup & Restore](BACKUP_RESTORE.md)
