# 🎮 ARK Command Cheat Sheet

## Your Command Center - Three Keys to Rule Them All

You are no longer a "Server Mechanic" constantly fixing leaks. You are now the **Commander of the ARK**.

---

## 🚀 The Essential Commands

### 1. The "Ralph Loop" (Full Automation)
```bash
# From your local machine (via SSH)
ssh nomadty@100.124.104.38 "sudo /opt/ark/scripts/ark-manager.sh loop"

# Or if you're already on the server
cd /opt/ark
./scripts/ark-manager.sh loop
```

**What it does:**
- Syncs code from GitHub
- Verifies large files (ZIM/models)
- Deploys all 16 services
- Verifies service health (Smart Checks)
- Creates configuration backup
- Updates documentation

**When to use:** Daily maintenance, after code changes, or when you want a full system refresh.

---

### 2. The Status Check (Flight Recorder)
```bash
# Read the Captain's Log
ssh nomadty@100.124.104.38 "cat /opt/ark/docs/CAPTAINS_LOG.md"

# Or view the last 50 lines
ssh nomadty@100.124.104.38 "tail -50 /opt/ark/docs/CAPTAINS_LOG.md"

# Quick service status
ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml ps"
```

**What it does:**
- Shows all recent operations
- Displays service health status
- Provides deployment history
- Shows timestamps and results

**When to use:** Check system status, verify deployments, audit operations.

---

### 3. The Emergency Buttons

#### Restart a Service
```bash
ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml restart [service-name]"
```

#### Restart Traefik (Traffic Controller)
```bash
ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml restart traefik"
```

#### View Service Logs
```bash
ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml logs [service-name] --tail 50"
```

#### Full System Restart
```bash
ssh nomadty@100.124.104.38 "cd /opt/ark && docker compose restart"
```

**When to use:** When a service is misbehaving, after configuration changes, or for troubleshooting.

---

## 📊 Quick Status Commands

### Service Health
```bash
# All services status
ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml ps"

# Specific service
ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml ps [service-name]"
```

### Storage Status
```bash
ssh nomadty@100.124.104.38 "df -h /mnt/dock"
```

### Recent Deployments
```bash
ssh nomadty@100.124.104.38 "tail -20 /opt/ark/docs/CAPTAINS_LOG.md"
```

---

## 🤖 CrewAI Agent Commands

### Run Autonomous Audit
```bash
# From your local machine (with CrewAI installed)
python3 ark_agent.py

# Or if on the server
cd /opt/ark
python3 ark_agent.py
```

**What it does:**
- Executes Ralph Loop
- Analyzes output for issues
- Generates JSON status report
- Escalates critical issues

---

## 🎯 Common Scenarios

### "I just pushed code to GitHub"
→ **Do nothing!** GitHub Actions will automatically deploy via Ralph Loop.

### "I want to check if everything is working"
→ Run: `ssh nomadty@100.124.104.38 "cat /opt/ark/docs/CAPTAINS_LOG.md"`

### "A service seems broken"
→ Run: `ssh nomadty@100.124.104.38 "docker compose -f /opt/ark/docker-compose.yml restart [service]`

### "I want to manually trigger a deployment"
→ Run: `ssh nomadty@100.124.104.38 "sudo /opt/ark/scripts/ark-manager.sh loop"`

### "I need to see what changed"
→ Run: `ssh nomadty@100.124.104.38 "cat /opt/ark/docs/CHANGELOG.md"`

---

## 🔐 SSH Connection

**Tailscale IP:** `100.124.104.38`  
**User:** `nomadty`  
**Key:** Your SSH private key

**Quick Connect:**
```bash
ssh nomadty@100.124.104.38
```

---

## 📋 Service Names Reference

- `homepage` - Main dashboard
- `traefik` - Reverse proxy
- `portainer` - Container management
- `ollama` - AI LLM
- `open-webui` - AI chat interface
- `jellyfin` - Media server
- `kiwix` - Offline Wikipedia
- `filebrowser` - File manager
- `vaultwarden` - Password manager
- `gitea` - Git hosting
- `code-server` - VS Code IDE
- `syncthing` - File sync
- `audiobookshelf` - Audiobooks
- `homeassistant` - IoT automation
- `tailscale` - Network tunnel
- `autoheal` - Container watchdog

---

## 🎉 Remember

**You are the Commander, not the Mechanic.**

- ✅ Use `ark-manager.sh loop` for everything
- ✅ Check `CAPTAINS_LOG.md` for status
- ✅ Let automation handle the rest
- ✅ Only intervene when truly needed

---

**Your ARK runs itself. You just monitor the logs.** 📊
