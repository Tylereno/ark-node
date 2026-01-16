# ⚠️ CRITICAL: Tailscale State Backup

**Your Tailscale identity is stored in:** `/var/lib/tailscale`

## Why This Matters

This directory contains your **permanent Tailscale identity**. If you lose it:
- Your Tailscale IP will change
- GitHub Actions will break (wrong IP in secrets)
- You'll need to re-authenticate and update everything

## Backup Command

```bash
# Backup the entire Tailscale state
sudo tar -czf ~/tailscale-state-backup-$(date +%Y%m%d).tar.gz /var/lib/tailscale

# Or copy to a safe location
sudo cp -r /var/lib/tailscale /opt/ark/backups/tailscale-state
```

## Restore Command

```bash
# If you ever need to restore
sudo tar -xzf ~/tailscale-state-backup-YYYYMMDD.tar.gz -C /
sudo systemctl restart docker
docker compose restart tailscale
```

## Never Delete

**DO NOT DELETE:** `/var/lib/tailscale`

This is your server's "soul" in the Tailscale network. Without it, you'll get a new IP and identity.

---

**Current Stable IP:** `100.124.104.38`  
**Device Name:** `nomad-node`  
**Last Updated:** 2026-01-15
