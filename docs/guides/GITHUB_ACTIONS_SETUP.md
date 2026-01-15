# GitHub Actions Deployment Setup

**Automated deployment for ARK using GitHub Actions**

---

## Overview

This guide sets up automated deployment from GitHub to your ARK server. When you push to the `main` branch, GitHub Actions will:

1. ✅ Sync code to your server
2. ✅ Inject secrets from GitHub Secrets
3. ✅ Restart Docker services
4. ✅ Purge Cloudflare cache

---

## Prerequisites

- GitHub repository (public or private)
- Server with SSH access
- Docker and Docker Compose installed on server
- Cloudflare account (optional, for cache purging)

---

## Step 1: Choose Deployment Method

### Option A: SSH Deployment (Recommended) ✅

**Best for:** Docker-based deployments, direct server access

**File:** `.github/workflows/deploy-ssh.yml`

**Pros:**
- More secure (SSH keys)
- Better for Docker operations
- Direct server access
- Faster deployment

**Cons:**
- Requires SSH key setup

### Option B: SFTP/FTP Deployment

**Best for:** Traditional web hosting, Namecheap shared hosting

**File:** `.github/workflows/deploy.yml`

**Pros:**
- Works with FTP/SFTP
- Compatible with shared hosting

**Cons:**
- Less secure (password-based)
- Not ideal for Docker

**Recommendation:** Use SSH deployment (Option A) for ARK.

---

## Step 2: Generate SSH Key Pair

### On Your Local Machine:

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "github-actions-ark" -f ~/.ssh/github_actions_ark

# This creates:
# ~/.ssh/github_actions_ark (private key - add to GitHub Secrets)
# ~/.ssh/github_actions_ark.pub (public key - add to server)
```

### Add Public Key to Server:

```bash
# Copy public key to server
ssh-copy-id -i ~/.ssh/github_actions_ark.pub user@your-server-ip

# Or manually:
cat ~/.ssh/github_actions_ark.pub | ssh user@your-server-ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Test SSH Connection:

```bash
ssh -i ~/.ssh/github_actions_ark user@your-server-ip
# Should connect without password
```

---

## Step 3: Configure GitHub Secrets

Go to your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

### Required Secrets:

#### SSH Configuration:
```
SSH_PRIVATE_KEY        # Contents of ~/.ssh/github_actions_ark (private key)
SSH_HOST              # Your server IP or domain (e.g., 192.168.26.8 or ark.tylereno.me)
SSH_USERNAME          # SSH username (e.g., nomadty)
SSH_PORT              # SSH port (usually 22, optional)
```

#### Network Configuration:
```
ARK_NODE_IP           # Your server IP (e.g., 192.168.26.8)
ARK_DOMAIN            # Your domain (e.g., tylereno.me)
```

#### Credentials:
```
ARK_ADMIN_USER        # Admin username (e.g., admin)
ARK_ADMIN_PASSWORD    # Admin password (strong password!)
FILEBROWSER_ADMIN_TOKEN    # FileBrowser token
CODE_SERVER_PASSWORD       # Code-Server password
CODE_SERVER_SUDO_PASSWORD  # Code-Server sudo password
```

#### Optional:
```
TAILSCALE_AUTHKEY     # Tailscale auth key (if using)
TZ                    # Timezone (default: America/Los_Angeles)
```

#### Cloudflare (for cache purging):
```
CLOUDFLARE_ZONE_ID    # Your Cloudflare zone ID
CLOUDFLARE_API_TOKEN  # Cloudflare API token
```

#### FTP (only if using FTP deployment):
```
FTP_SERVER            # FTP server address
FTP_USERNAME          # FTP username
FTP_PASSWORD          # FTP password
```

---

## Step 4: Get Cloudflare Credentials (Optional)

### Get Zone ID:

1. Go to Cloudflare Dashboard
2. Select your domain
3. Scroll down to "API" section
4. Copy "Zone ID"

### Create API Token:

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Use "Edit zone DNS" template
4. Select your zone
5. Copy the token

---

## Step 5: Test Deployment

### Manual Trigger:

1. Go to GitHub repository
2. Click "Actions" tab
3. Select "Deploy ARK via SSH" workflow
4. Click "Run workflow"
5. Select branch: `main`
6. Click "Run workflow"

### Automatic Trigger:

```bash
# Make a small change
echo "# Test deployment" >> README.md

# Commit and push
git add README.md
git commit -m "Test: Trigger deployment"
git push origin main
```

### Monitor Deployment:

1. Go to "Actions" tab
2. Click on the running workflow
3. Watch real-time logs
4. Check for errors

---

## Step 6: Verify Deployment

### Check Server:

```bash
# SSH into server
ssh user@your-server-ip

# Check services
cd /opt/ark
docker compose ps

# Check deployment log
tail -20 .deploy.log

# Verify .env file created
cat .env
```

### Check Services:

```bash
# Test Homepage
curl http://192.168.26.8:3000

# Test other services
curl http://192.168.26.8:3001  # Open WebUI
curl http://192.168.26.8:8096  # Jellyfin
```

---

## Troubleshooting

### "Permission denied (publickey)"

**Problem:** SSH key not configured correctly

**Solution:**
```bash
# Verify public key on server
ssh user@server "cat ~/.ssh/authorized_keys"

# Verify private key in GitHub Secrets
# Should start with: -----BEGIN OPENSSH PRIVATE KEY-----
```

### "docker compose: command not found"

**Problem:** Docker Compose not installed or not in PATH

**Solution:**
```bash
# On server, check Docker Compose
docker compose version

# If not found, install:
sudo apt install docker-compose-plugin
```

### "Services not restarting"

**Problem:** Docker Compose not finding .env file

**Solution:**
```bash
# Check .env file exists
ls -la /opt/ark/.env

# Check file permissions
chmod 644 /opt/ark/.env

# Verify secrets are set in GitHub
```

### "Cloudflare cache purge failed"

**Problem:** Invalid Cloudflare credentials

**Solution:**
1. Verify `CLOUDFLARE_ZONE_ID` is correct
2. Verify `CLOUDFLARE_API_TOKEN` has correct permissions
3. Test token manually:
   ```bash
   curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
   ```

### "Deployment succeeds but services don't update"

**Problem:** Files synced but Docker not restarted

**Solution:**
- Check workflow logs for "Execute Deployment Commands" step
- Verify SSH connection works
- Check Docker Compose logs: `docker compose logs`

---

## Advanced Configuration

### Custom Deployment Script

Create `/opt/ark/.github/scripts/deploy.sh` on server:

```bash
#!/bin/bash
set -e

cd /opt/ark

# Load environment
source .env

# Pull images
docker compose pull

# Restart services
docker compose up -d --force-recreate

# Health check
sleep 10
docker compose ps

# Run custom post-deploy tasks
# Example: Update database, clear cache, etc.
```

Then update workflow to use:
```yaml
script: |
  bash /opt/ark/.github/scripts/deploy.sh
```

### Selective Service Restart

To restart only specific services:

```yaml
script: |
  cd /opt/ark
  source .env
  docker compose restart traefik homepage
  # Only restart these services
```

### Rollback on Failure

Add rollback step:

```yaml
- name: Rollback on Failure
  if: failure()
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.SSH_HOST }}
    username: ${{ secrets.SSH_USERNAME }}
    key: ${{ secrets.SSH_PRIVATE_KEY }}
    script: |
      cd /opt/ark
      git checkout HEAD~1
      docker compose up -d --force-recreate
```

---

## Security Best Practices

### 1. Use SSH Keys (Not Passwords)

✅ **Good:**
```yaml
key: ${{ secrets.SSH_PRIVATE_KEY }}
```

❌ **Bad:**
```yaml
password: ${{ secrets.SSH_PASSWORD }}
```

### 2. Limit SSH Key Permissions

On server, restrict SSH key:
```bash
# In ~/.ssh/authorized_keys, add:
command="cd /opt/ark && $SSH_ORIGINAL_COMMAND",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 ...
```

### 3. Use Least Privilege Secrets

Only add secrets you actually need. Don't add unused API keys.

### 4. Rotate Secrets Regularly

- Change passwords quarterly
- Rotate SSH keys annually
- Update API tokens when compromised

### 5. Monitor Deployment Logs

```bash
# On server, check deployment log
tail -f /opt/ark/.deploy.log

# Check for suspicious activity
grep -i "error\|failed\|unauthorized" /opt/ark/.deploy.log
```

---

## Workflow Files

### deploy-ssh.yml (Recommended)

- Uses SSH for secure deployment
- Direct Docker Compose control
- Better error handling
- Recommended for ARK

### deploy.yml (FTP Alternative)

- Uses SFTP/FTP
- For traditional hosting
- Less secure
- Use only if SSH unavailable

---

## Quick Reference

### GitHub Secrets Checklist:

- [ ] SSH_PRIVATE_KEY
- [ ] SSH_HOST
- [ ] SSH_USERNAME
- [ ] ARK_NODE_IP
- [ ] ARK_DOMAIN
- [ ] ARK_ADMIN_USER
- [ ] ARK_ADMIN_PASSWORD
- [ ] FILEBROWSER_ADMIN_TOKEN
- [ ] CODE_SERVER_PASSWORD
- [ ] CODE_SERVER_SUDO_PASSWORD
- [ ] CLOUDFLARE_ZONE_ID (optional)
- [ ] CLOUDFLARE_API_TOKEN (optional)
- [ ] TAILSCALE_AUTHKEY (optional)

### Test Commands:

```bash
# Test SSH connection
ssh -i ~/.ssh/github_actions_ark user@server

# Test Docker on server
ssh user@server "cd /opt/ark && docker compose ps"

# Test deployment manually
cd /opt/ark
source .env
docker compose pull
docker compose up -d --force-recreate
```

---

## Next Steps

1. ✅ Set up SSH keys
2. ✅ Add GitHub Secrets
3. ✅ Test deployment
4. ✅ Monitor first few deployments
5. ✅ Set up notifications (optional)

---

## Support

- **Workflow Issues:** Check GitHub Actions logs
- **SSH Issues:** Verify key permissions
- **Docker Issues:** Check server logs
- **Cloudflare Issues:** Verify API token

---

**Ready to automate your deployments!** 🚀
