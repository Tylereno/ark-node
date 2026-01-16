# GitHub Actions Troubleshooting Guide

**Fix common deployment issues**

---

## Error: "Unexpected input(s) 'exclude'"

**Problem:** The `exclude` parameter is not supported by `appleboy/scp-action` or `appleboy/ssh-action`.

**Solution:** ✅ **FIXED** - The workflow now uses Git pull instead of file transfer, which automatically respects `.gitignore`.

**If you still see this error:**
1. Make sure you've pulled the latest version: `git pull origin main`
2. The workflow file should NOT have any `exclude:` parameters
3. Verify: `grep -r "exclude:" .github/workflows/` should return nothing

---

## Error: "ssh: handshake failed" or "Permission denied"

### Issue 1: SSH Key Not in GitHub Secrets

**Check:**
1. Go to: Repository → Settings → Secrets and variables → Actions
2. Verify `SSH_PRIVATE_KEY` exists
3. Verify it contains the FULL private key (including `-----BEGIN` and `-----END` lines)

**Fix:**
```bash
# On your local machine
cat ~/.ssh/github_actions_ark

# Copy the ENTIRE output (including BEGIN/END lines)
# Paste into GitHub Secrets → SSH_PRIVATE_KEY
```

### Issue 2: Public Key Not on Server

**Check:**
```bash
# On server
cat ~/.ssh/authorized_keys | grep github-actions-ark
```

**Fix:**
```bash
# On local machine
cat ~/.ssh/github_actions_ark.pub | ssh user@server 'cat >> ~/.ssh/authorized_keys'

# Or manually on server
nano ~/.ssh/authorized_keys
# Paste the public key (one line)
```

### Issue 3: SSH Key Has Passphrase

**Problem:** GitHub Actions can't enter passphrase automatically.

**Check:**
```bash
# Try to extract public key (will prompt for passphrase if set)
ssh-keygen -y -f ~/.ssh/github_actions_ark
```

**Fix:**
```bash
# Regenerate key WITHOUT passphrase
ssh-keygen -t ed25519 -C "github-actions-ark" -f ~/.ssh/github_actions_ark
# When prompted for passphrase, press Enter (empty)
```

### Issue 4: Firewall Blocking Port 22

**Check:**
```bash
# On server
sudo ufw status
```

**Fix:**
```bash
# Allow SSH
sudo ufw allow 22/tcp
sudo ufw reload
```

### Issue 5: Wrong SSH Host/Username/Port

**Check GitHub Secrets:**
- `SSH_HOST` - Should be IP or domain (e.g., `192.168.26.8` or `ark.tylereno.me`)
- `SSH_USERNAME` - Should match your server username
- `SSH_PORT` - Should be 22 (or your custom SSH port)

**Test locally:**
```bash
ssh -i ~/.ssh/github_actions_ark -p 22 user@your-server-ip
```

---

## Error: "dial tcp [IP]:22: i/o timeout"

**Problem:** GitHub Actions can't reach your server.

### Issue 1: Server Behind Firewall/NAT

**Solutions:**
1. **Use Cloudflare Tunnel** (recommended)
   - Set up Cloudflare Tunnel on server
   - Point GitHub Actions to tunnel endpoint

2. **Open Port 22** (if public IP)
   - Configure firewall to allow GitHub IPs
   - GitHub Actions IPs change frequently (not recommended)

3. **Use Tailscale** (best for private networks)
   - Set up Tailscale on server
   - Use Tailscale IP in `SSH_HOST`

### Issue 2: Cloudflare Blocking

**If using Cloudflare proxy:**
- Cloudflare proxy (orange cloud) only works for HTTP/HTTPS
- SSH (port 22) must go directly to your server IP
- Use `SSH_HOST` = your actual server IP, not Cloudflare domain

---

## Error: "docker compose: command not found"

**Problem:** Docker Compose not installed on server.

**Fix:**
```bash
# On server
sudo apt update
sudo apt install docker-compose-plugin

# Verify
docker compose version
```

---

## Error: "git: command not found"

**Problem:** Git not installed on server.

**Fix:**
```bash
# On server
sudo apt update
sudo apt install git

# Verify
git --version
```

---

## Error: "Permission denied" for Docker

**Problem:** User not in docker group.

**Fix:**
```bash
# On server
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker ps
```

---

## Error: Services Not Restarting

### Check Logs:
```bash
# On server
cd /opt/ark
docker compose logs
docker compose ps
```

### Common Issues:

**1. .env file missing:**
```bash
# Check if .env exists
ls -la /opt/ark/.env

# If missing, GitHub Secrets may not be set correctly
```

**2. Docker Compose syntax error:**
```bash
# Validate docker-compose.yml
docker compose config
```

**3. Port conflicts:**
```bash
# Check what's using ports
sudo netstat -tlnp | grep -E "3000|3001|8096"
```

---

## Test Your Setup

### Run Local Test Script:

```bash
# On your local machine
cd /opt/ark
./scripts/test-ssh-connection.sh
```

This will:
- ✅ Verify SSH key exists
- ✅ Check for passphrase
- ✅ Test SSH connection
- ✅ Verify Docker access
- ✅ Check ARK directory
- ✅ Verify authorized_keys

---

## Debug Workflow

### Enable Debug Mode:

The workflow already has `debug: true` enabled. Check GitHub Actions logs for detailed output.

### Manual SSH Test:

```bash
# Test exact command GitHub Actions uses
ssh -i ~/.ssh/github_actions_ark \
    -o StrictHostKeyChecking=no \
    user@server \
    "cd /opt/ark && pwd && ls -la"
```

---

## Common GitHub Secrets Issues

### Secret Not Set:
- Error: `${{ secrets.SSH_HOST }}` is empty
- Fix: Add secret in GitHub → Settings → Secrets

### Secret Has Wrong Value:
- Error: Connection fails with correct-looking values
- Fix: Check for trailing spaces, newlines, or special characters

### Secret Format Wrong:
- Error: SSH key doesn't work
- Fix: Ensure private key includes:
  - `-----BEGIN OPENSSH PRIVATE KEY-----`
  - Full key content
  - `-----END OPENSSH PRIVATE KEY-----`
  - No extra spaces or line breaks

---

## Quick Checklist

Before deploying, verify:

- [ ] SSH key generated: `ls ~/.ssh/github_actions_ark`
- [ ] SSH key has NO passphrase
- [ ] Public key on server: `cat ~/.ssh/authorized_keys | grep github`
- [ ] Private key in GitHub Secrets: `SSH_PRIVATE_KEY`
- [ ] Server details in GitHub Secrets: `SSH_HOST`, `SSH_USERNAME`, `SSH_PORT`
- [ ] Firewall allows SSH: `sudo ufw status | grep 22`
- [ ] Docker installed: `docker compose version`
- [ ] Git installed: `git --version`
- [ ] ARK directory exists: `ls -la /opt/ark`
- [ ] Test connection: `./scripts/test-ssh-connection.sh`

---

## Still Stuck?

1. **Check GitHub Actions Logs:**
   - Go to Actions tab
   - Click on failed workflow
   - Expand each step
   - Look for error messages

2. **Test Locally:**
   ```bash
   ./scripts/test-ssh-connection.sh
   ```

3. **Verify Secrets:**
   - Double-check all GitHub Secrets are set
   - Verify no typos in secret names
   - Check secret values are correct

4. **Check Server:**
   ```bash
   # SSH to server manually
   ssh user@server
   
   # Test commands
   cd /opt/ark
   git pull origin main
   docker compose ps
   ```

---

## Success Indicators

When deployment works, you'll see:

```
✅ SSH connection successful
✅ Code synced from GitHub
✅ .env file created
✅ Docker images pulled
✅ Services restarted
✅ All services running
✅ Cloudflare cache purged
```

---

**For more help, see:** `docs/guides/GITHUB_ACTIONS_SETUP.md`
