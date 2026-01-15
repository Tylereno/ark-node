# 🚀 GitHub Actions Deployment - Quick Start

**Get automated deployment running in 15 minutes**

---

## TL;DR

1. Generate SSH key
2. Add to GitHub Secrets
3. Push to GitHub
4. Watch it deploy automatically

---

## Step 1: Generate SSH Key (2 minutes)

```bash
# Generate key pair
ssh-keygen -t ed25519 -C "github-actions-ark" -f ~/.ssh/github_actions_ark

# Add public key to server
ssh-copy-id -i ~/.ssh/github_actions_ark.pub user@your-server-ip

# Test connection
ssh -i ~/.ssh/github_actions_ark user@your-server-ip
```

---

## Step 2: Add GitHub Secrets (5 minutes)

Go to: **Repository → Settings → Secrets and variables → Actions**

Add these secrets:

### Required:
```
SSH_PRIVATE_KEY        # Contents of ~/.ssh/github_actions_ark
SSH_HOST              # Your server IP (e.g., 192.168.26.8)
SSH_USERNAME          # SSH user (e.g., nomadty)
ARK_NODE_IP           # Server IP
ARK_DOMAIN            # Your domain (e.g., tylereno.me)
ARK_ADMIN_USER        # admin
ARK_ADMIN_PASSWORD    # Your strong password
FILEBROWSER_ADMIN_TOKEN    # Your token
CODE_SERVER_PASSWORD       # Your password
CODE_SERVER_SUDO_PASSWORD  # Your password
```

### Optional:
```
CLOUDFLARE_ZONE_ID    # For cache purging
CLOUDFLARE_API_TOKEN  # For cache purging
TAILSCALE_AUTHKEY     # If using Tailscale
```

---

## Step 3: Enable Workflow (1 minute)

The workflow files are already in `.github/workflows/`:
- `deploy-ssh.yml` (recommended - uses SSH)
- `deploy.yml` (alternative - uses FTP)

**Default:** `deploy-ssh.yml` will run automatically on push to `main`.

---

## Step 4: Test Deployment (2 minutes)

```bash
# Make a small change
echo "# Automated deployment test" >> README.md

# Commit and push
git add README.md
git commit -m "Test: Automated deployment"
git push origin main
```

**Watch it deploy:**
1. Go to GitHub → Actions tab
2. See workflow running
3. Check logs in real-time
4. Verify services restarted on server

---

## Step 5: Verify (2 minutes)

```bash
# SSH to server
ssh user@your-server-ip

# Check services
cd /opt/ark
docker compose ps

# Check deployment log
tail -20 .deploy.log

# Verify .env created
cat .env
```

---

## Troubleshooting

### "Permission denied"
→ Check SSH key is in GitHub Secrets correctly

### "docker compose: command not found"
→ Install Docker Compose on server: `sudo apt install docker-compose-plugin`

### "Services not restarting"
→ Check workflow logs, verify .env file created

---

## What Happens on Deploy?

1. ✅ Code synced to `/opt/ark/` on server
2. ✅ `.env` file created from GitHub Secrets
3. ✅ Docker images pulled (latest versions)
4. ✅ Services restarted with new code
5. ✅ Cloudflare cache purged (if configured)
6. ✅ Deployment logged

---

## Next Steps

- Read full guide: `docs/guides/GITHUB_ACTIONS_SETUP.md`
- Set up notifications (Slack, Discord, email)
- Configure rollback on failure
- Add deployment badges to README

---

**That's it! Your deployments are now automated.** 🎉
