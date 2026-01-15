# 🔒 ARK SECURITY CHECKLIST

**Pre-Public Launch Security Verification**

---

## ⚠️ CRITICAL: Complete Before Making Repository Public

This checklist ensures no sensitive data leaks when you push to GitHub or share your repository.

---

## 1. Secret Vault Setup

### Status: [ ] Complete

**Actions:**
- [ ] Copy `vessel_secrets.example` to `vessel_secrets.env`
- [ ] Fill in all your actual credentials in `vessel_secrets.env`
- [ ] Change ALL default passwords (arknode123 → strong passwords)
- [ ] Generate new tokens for FILEBROWSER_ADMIN_TOKEN
- [ ] Add Tailscale auth key (if using)
- [ ] Add Cloudflare tokens (if using)

**Verify:**
```bash
ls -la /opt/ark/vessel_secrets.env
# Should exist

cat /opt/ark/vessel_secrets.env | grep "CHANGE_ME"
# Should show NO results (all changed)
```

---

## 2. Git Protection

### Status: [ ] Complete

**Actions:**
- [ ] Verify `.gitignore` includes `vessel_secrets.env`
- [ ] Verify `.gitignore` includes `.env` and `.env.*`
- [ ] Ensure no credential files are tracked

**Verify:**
```bash
cd /opt/ark

# Check ignore status
git check-ignore vessel_secrets.env
# Should output: vessel_secrets.env

# Check what's tracked
git ls-files | grep -E "secret|\.env$|credential"
# Should show NOTHING (all ignored)

# Verify no secrets in staged files
git diff --cached | grep -i "arknode123"
# Should show NOTHING
```

---

## 3. Documentation Cleanup

### Status: [ ] Complete

**Actions:**
- [ ] Update README to use placeholders instead of `192.168.26.8`
- [ ] Remove hardcoded passwords from documentation
- [ ] Add warning about changing default credentials

**Verify:**
```bash
# Check tracked docs for default password
git ls-files -- '*.md' | xargs grep "arknode123" || echo "✓ Clean"

# Check for hardcoded IPs in tracked files
git ls-files | xargs grep "192.168.26.8" | wc -l
# Note: Some references OK in docs as examples
```

---

## 4. Docker Compose Security

### Status: [ ] Complete

**Actions:**
- [ ] Review `docker-compose.yml` for hardcoded secrets
- [ ] Ensure sensitive values use environment variables: `${VAR_NAME}`
- [ ] Add comments indicating where to set variables

**Check:**
```bash
# Look for hardcoded passwords
grep -n "password.*:" docker-compose.yml | grep -v "#" | grep -v "PASSWORD="
# Should show minimal results
```

---

## 5. Cloudflare Setup (Optional)

### Status: [ ] Complete or [ ] Skipped

**If Using Cloudflare:**
- [ ] Domain added to Cloudflare account
- [ ] Nameservers updated at registrar
- [ ] DNS records created with proxy enabled (🟠)
- [ ] `cloudflare_tunnel.yml` configured with your tunnel ID
- [ ] Tunnel credentials stored in `vessel_secrets.env`
- [ ] Tunnel tested and working

**Verify:**
```bash
# If using Cloudflare Tunnel
sudo systemctl status cloudflared
# Should show active (running)

# Test external access
curl -I https://ark.yourdomain.com
# Should return 200 OK
```

---

## 6. Firewall Configuration

### Status: [ ] Complete

**Actions:**
- [ ] UFW enabled
- [ ] SSH access allowed (port 22)
- [ ] Cloudflare IP ranges allowed (if using tunnel)
- [ ] Or specific service ports allowed (if not using tunnel)
- [ ] Fail2Ban installed and running

**Verify:**
```bash
# Check firewall status
sudo ufw status
# Should show: Status: active

# Check fail2ban
sudo systemctl status fail2ban
# Should show: active (running)
```

---

## 7. Service Security

### Status: [ ] Complete

**Actions:**
- [ ] All services have strong, unique passwords
- [ ] No services use default credentials
- [ ] Portainer admin password set (12+ chars)
- [ ] Home Assistant onboarding completed
- [ ] Vaultwarden admin account created
- [ ] Gitea admin account configured

**Test Access:**
```bash
# Try logging in with default password (should FAIL)
curl -u admin:arknode123 http://192.168.26.8:8081
# Should return 401 Unauthorized
```

---

## 8. Backup Your Secrets

### Status: [ ] Complete

**Actions:**
- [ ] `vessel_secrets.env` saved in password manager (Bitwarden, 1Password)
- [ ] Backup copy on encrypted USB drive
- [ ] Recovery plan documented

**Locations to Store:**
- ✅ Password manager (encrypted, synced)
- ✅ Encrypted USB drive (offline, secure location)
- ✅ Printed and stored in safe (for disaster recovery)

**Never Store:**
- ❌ Git/GitHub (even private repos)
- ❌ Unencrypted cloud (Dropbox, Google Drive)
- ❌ Email or chat apps

---

## 9. Final Security Scan

### Status: [ ] Complete

**Run Security Audit:**
```bash
cd /opt/ark

# Run comprehensive scan
./scripts/security-scan.sh

# Manual checks
echo "=== Checking for secrets in tracked files ==="
git ls-files | xargs grep -l "arknode123" 2>/dev/null || echo "✓ No default passwords"

echo "=== Checking .gitignore effectiveness ==="
git status --ignored | grep vessel_secrets.env && echo "✓ Secrets ignored" || echo "⚠ Check .gitignore"

echo "=== Checking environment files ==="
ls -la | grep -E "\.env|secrets" 
echo "vessel_secrets.env should exist, .env optional"

echo "=== Checking what will be committed ==="
git status
echo "Review carefully before commit!"
```

---

## 10. GitHub Preparation

### Status: [ ] Complete

**Actions:**
- [ ] GitHub repository created (can be private initially)
- [ ] README.md updated with public-appropriate content
- [ ] LICENSE file added
- [ ] CONTRIBUTING.md created (optional)
- [ ] GitHub Secrets added (for Actions, if using)

**GitHub Secrets to Add:**
- `ARK_ADMIN_PASSWORD`
- `TAILSCALE_AUTHKEY`
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_TUNNEL_TOKEN`

**Final Push Preparation:**
```bash
cd /opt/ark

# Review all changes
git status
git diff

# Check what will be pushed
git log origin/main..HEAD

# Final secret scan
git diff origin/main..HEAD | grep -i "password\|secret\|token" | grep -v "{{" | grep -v "#"
# Should show NOTHING sensitive

# Ready to push
git push origin main
```

---

## 11. Post-Launch Monitoring

### Status: [ ] Complete

**Actions:**
- [ ] Monitor access logs for unusual activity
- [ ] Set up alerts for failed login attempts
- [ ] Regular security updates (`apt update && apt upgrade`)
- [ ] Review Cloudflare analytics
- [ ] Test backup restoration

---

## Emergency Procedures

### If You Accidentally Commit Secrets:

```bash
# DO NOT just delete and re-commit!
# The secret is still in Git history

# Option 1: Remove from history (destructive)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch vessel_secrets.env' \
  --prune-empty --tag-name-filter cat -- --all

# Option 2: Use BFG Repo-Cleaner (easier)
# Download: https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --delete-files vessel_secrets.env
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Then force push (WARNING: rewrites history)
git push origin --force --all

# IMPORTANT: Rotate all exposed secrets immediately!
```

### If Secrets Were Exposed:

1. **Immediately** change all passwords in exposed file
2. Revoke and regenerate all API keys
3. Check access logs for unauthorized access
4. Update `vessel_secrets.env` with new credentials
5. Restart all affected services
6. Monitor for 48 hours

---

## Quick Reference Commands

```bash
# Load secrets
source /opt/ark/vessel_secrets.env

# Start services with secrets
source /opt/ark/vessel_secrets.env && docker compose up -d

# Check for secrets in tracked files
git ls-files | xargs grep -i "arknode123"

# Verify gitignore working
git check-ignore vessel_secrets.env

# Security scan
./scripts/security-scan.sh

# Check firewall
sudo ufw status verbose

# Check fail2ban
sudo fail2ban-client status

# Test Cloudflare tunnel
sudo systemctl status cloudflared

# View access logs
sudo tail -f /var/log/nginx/access.log  # If using nginx
docker compose logs -f traefik  # Traefik logs
```

---

## Sign-Off

**I certify that:**
- [ ] All default passwords have been changed
- [ ] No secrets are committed to Git
- [ ] Firewall is enabled and configured
- [ ] Secrets are backed up securely
- [ ] I understand the emergency procedures
- [ ] Repository is ready for public release

**Date:** ______________  
**Signature:** ______________

---

## Resources

- [Security Setup Guide](docs/guides/SECURITY_SETUP.md)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [OWASP Security Guidelines](https://owasp.org/)

---

**🚨 REMEMBER: Security is not optional. Complete this checklist before going public!**
