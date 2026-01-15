# GitHub Actions Workflows

**Automated deployment workflows for ARK**

---

## Available Workflows

### 1. `deploy-ssh.yml` (Recommended) ✅

**Purpose:** Deploy ARK to server via SSH

**Triggers:**
- Push to `main` branch
- Manual workflow dispatch

**What it does:**
1. Checks out repository
2. Creates `.env` from GitHub Secrets
3. Syncs code to server via SSH
4. Restarts Docker services
5. Purges Cloudflare cache

**Best for:** Docker-based deployments, direct server access

---

### 2. `deploy.yml` (Alternative)

**Purpose:** Deploy ARK to server via SFTP/FTP

**Triggers:**
- Push to `main` branch
- Manual workflow dispatch

**What it does:**
1. Checks out repository
2. Creates `.env` from GitHub Secrets
3. Syncs code to server via SFTP
4. Executes post-deploy script via SSH
5. Restarts Docker services
6. Purges Cloudflare cache

**Best for:** Traditional hosting, Namecheap shared hosting

---

## Setup

See: `docs/guides/GITHUB_ACTIONS_SETUP.md` for complete setup instructions.

Quick start: `GITHUB_ACTIONS_QUICKSTART.md`

---

## Required GitHub Secrets

### SSH Configuration:
- `SSH_PRIVATE_KEY` - SSH private key for server access
- `SSH_HOST` - Server IP or domain
- `SSH_USERNAME` - SSH username
- `SSH_PORT` - SSH port (optional, default: 22)

### ARK Configuration:
- `ARK_NODE_IP` - Server IP address
- `ARK_DOMAIN` - Your domain name
- `ARK_ADMIN_USER` - Admin username
- `ARK_ADMIN_PASSWORD` - Admin password
- `FILEBROWSER_ADMIN_TOKEN` - FileBrowser token
- `CODE_SERVER_PASSWORD` - Code-Server password
- `CODE_SERVER_SUDO_PASSWORD` - Code-Server sudo password

### Optional:
- `TAILSCALE_AUTHKEY` - Tailscale auth key
- `TZ` - Timezone (default: America/Los_Angeles)
- `CLOUDFLARE_ZONE_ID` - Cloudflare zone ID
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `FTP_SERVER` - FTP server (for deploy.yml only)
- `FTP_USERNAME` - FTP username (for deploy.yml only)
- `FTP_PASSWORD` - FTP password (for deploy.yml only)

---

## Usage

### Automatic Deployment

Just push to `main`:
```bash
git push origin main
```

Workflow runs automatically.

### Manual Deployment

1. Go to GitHub → Actions tab
2. Select workflow
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

---

## Monitoring

### View Workflow Runs

1. Go to GitHub → Actions tab
2. Click on workflow name
3. Click on specific run
4. View logs for each step

### Check Server

```bash
# SSH to server
ssh user@server

# Check deployment log
tail -f /opt/ark/.deploy.log

# Check services
cd /opt/ark
docker compose ps
```

---

## Troubleshooting

See: `docs/guides/GITHUB_ACTIONS_SETUP.md` → Troubleshooting section

Common issues:
- SSH permission denied → Check SSH key in Secrets
- Docker not found → Install Docker Compose on server
- Services not restarting → Check workflow logs
- Cloudflare purge failed → Verify API token

---

## Security

- ✅ SSH keys used (not passwords)
- ✅ Secrets stored in GitHub Secrets (encrypted)
- ✅ `.env` file auto-generated (not committed)
- ✅ Sensitive files excluded from sync

---

## Customization

### Modify Deployment Script

Edit the `script:` section in workflow file to customize deployment steps.

### Add Notifications

Add notification steps:
```yaml
- name: Notify on Success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'ARK deployment successful!'
```

### Add Rollback

See: `docs/guides/GITHUB_ACTIONS_SETUP.md` → Advanced Configuration

---

**For detailed setup, see:** `docs/guides/GITHUB_ACTIONS_SETUP.md`
