# 🚀 Port Forwarding Action Plan

**Your server is ready! Just need router configuration.**

---

## ✅ Server Status: ALL GOOD

- ✅ SSH service running
- ✅ Firewall allows port 22
- ✅ SSH listening on port 22
- ✅ Public IP: **98.51.0.20**
- ✅ Private IP: **192.168.26.8**

---

## 📋 Action Items

### Step 1: Configure Router Port Forwarding (5 minutes)

**Your Router Details:**
- **External Port:** 22
- **Internal Port:** 22
- **Internal IP:** 192.168.26.8
- **Protocol:** TCP

**How to Access Router:**
1. Open browser
2. Try: `http://192.168.1.1` or `http://192.168.0.1` or `http://192.168.26.1`
3. Login (check router label for default username/password)

**Where to Find Port Forwarding:**
- **Netgear:** Advanced → Port Forwarding
- **Linksys:** Connectivity → Router Settings → Port Forwarding
- **TP-Link:** Advanced → NAT Forwarding → Virtual Servers
- **ASUS:** WAN → Virtual Server / Port Forwarding
- **Ubiquiti:** Settings → Routing & Firewall → Port Forwarding

**Add This Rule:**
```
Service Name: SSH-ARK
External Port: 22
Internal Port: 22
Internal IP: 192.168.26.8
Protocol: TCP
Status: Enabled
```

**Save and Apply**

---

### Step 2: Test Port Forwarding (1 minute)

**Option A: Online Tool (Easiest)**
1. Visit: https://canyouseeme.org
2. Enter port: `22`
3. Click "Check Port"
4. Should say: **"Success: I can see your service"**

**Option B: From Your Phone (Off WiFi)**
```bash
# If you have terminal app on phone
nc -zv 98.51.0.20 22
```

---

### Step 3: Update GitHub Secrets (2 minutes)

**Go to:** Your GitHub Repository → Settings → Secrets and variables → Actions

**Update These Secrets:**

```
SSH_HOST: 98.51.0.20
SSH_PORT: 22
```

**⚠️ IMPORTANT:** Use your **PUBLIC IP** (98.51.0.20), NOT your domain (tylereno.me) if Cloudflare proxy is enabled.

---

### Step 4: Test Connection (1 minute)

```bash
# On your local machine
cd /opt/ark
./scripts/test-ssh-connection.sh

# When prompted:
# Server IP: 98.51.0.20
# Username: (your SSH username)
# Port: 22
```

---

### Step 5: Push and Deploy (1 minute)

```bash
# Commit any changes
git add .
git commit -m "Add port forwarding documentation"
git push origin main

# Watch GitHub Actions deploy automatically!
```

---

## 🎯 Quick Reference

**Your Configuration:**
- Public IP: `98.51.0.20`
- Private IP: `192.168.26.8`
- SSH Port: `22`
- GitHub Secret `SSH_HOST`: `98.51.0.20`

**Router Rule:**
```
External: 22 → Internal: 22 → 192.168.26.8 (TCP)
```

---

## 🆘 If Port Forwarding Doesn't Work

**Alternative: Cloudflare Tunnel (No Router Access Needed)**

See: `docs/guides/PORT_FORWARDING_SETUP.md` → Option 2

**Benefits:**
- No router configuration
- More secure
- Works behind any firewall

---

## ✅ Success Checklist

- [ ] Router port forwarding configured
- [ ] Port forwarding tested (canyouseeme.org shows success)
- [ ] GitHub Secrets updated (SSH_HOST = 98.51.0.20)
- [ ] SSH connection tested locally
- [ ] Pushed to GitHub
- [ ] GitHub Actions deployment successful

---

**Once port forwarding is configured, you're ready to deploy!** 🚀
