# ARK Manager - Master Control System

## 🎯 Overview

The ARK Manager (`ark-manager.sh`) is your single entry point for all ARK Node operations. It provides an "Industrial Grade" autonomous infrastructure management experience—click a button, and everything self-verifies, updates logs, and reports back.

## 🚀 Quick Start

### Interactive Mode (Recommended)
```bash
cd /opt/ark
./ark-manager.sh
```

This launches an interactive menu where you can:
1. Run Full Ralph Loop
2. Check Status
3. Deploy Only
4. Verify Services
5. Create Backup
6. View Captain's Log

### Command Line Mode
```bash
# Full Ralph Loop (deploy & verify everything)
./ark-manager.sh loop

# Status check
./ark-manager.sh status

# Verify services only
./ark-manager.sh verify

# Create backup
./ark-manager.sh backup

# View logs
./ark-manager.sh log
```

## 🔄 The "Ralph Loop"

The Full Ralph Loop performs these steps automatically:

1. **Prerequisites Check** - Verifies Docker, Docker Compose, and mounts
2. **Git Sync** - Pulls latest code from GitHub
3. **Large Files Check** - Skips downloads if ZIM/models already exist
4. **Deploy Services** - Pulls images and starts all containers
5. **Verify Services** - Checks each service endpoint
6. **Create Backup** - Backs up all configurations

**Result**: Complete deployment with verification and logging.

## 📊 What Gets Logged

All operations are logged to `CAPTAINS_LOG.md` with:
- Timestamps (UTC)
- Operation type (SUCCESS/WARNING/ERROR/CRITICAL)
- Detailed messages
- Service status
- Verification results

## 🔍 Service Verification

The manager automatically verifies these services:
- Homepage (port 3000)
- Traefik (port 8080)
- Portainer (port 9000)
- Ollama (port 11434)
- Open WebUI (port 3001)
- Jellyfin (port 8096)
- Kiwix (port 8083)
- FileBrowser (port 8081)
- Vaultwarden (port 8082)
- Gitea (port 3002)
- Code-Server (port 8443)

## 🤖 CrewAI Integration

The ARK Manager works seamlessly with CrewAI agents. Use the system prompt in `crewai-system-prompt.md` to create an autonomous DevOps agent that:

1. **Sanitizes Documentation** - Removes deprecated files
2. **Audits Versions** - Tracks Docker image changes
3. **Verifies Services** - Browser-based health checks
4. **Generates Reports** - Updates Captain's Log

### CrewAI Setup

```python
from crewai import Agent, Task, Crew

# Load the system prompt
with open('/opt/ark/crewai-system-prompt.md', 'r') as f:
    system_prompt = f.read()

# Create the ARK Overseer agent
ark_overseer = Agent(
    role='ARK System Overseer',
    goal='Maintain and monitor ARK Node infrastructure',
    backstory=system_prompt,
    verbose=True
)

# Create Ralph Loop task
ralph_loop = Task(
    description='Perform full Ralph Loop: sanitize docs, audit versions, verify services, generate report',
    agent=ark_overseer
)

# Run the crew
crew = Crew(agents=[ark_overseer], tasks=[ralph_loop])
result = crew.kickoff()
```

## 📝 Automated Changelog

The changelog is automatically updated after each deployment with:
- Git commit information
- Docker image versions
- Service status
- Timestamp

View it: `cat /opt/ark/CHANGELOG.md`

## 🔗 GitHub Actions Integration

The GitHub Actions workflow automatically:
1. Deploys services
2. Updates Captain's Log
3. Creates backups
4. Updates changelog

All logged with deployment commit hash and service status.

## 📋 Captain's Log Format

```
### 2026-01-16 12:00:00 UTC - SUCCESS - Full Ralph Loop

✓ Prerequisites check passed
✓ Code synced to abc1234
✓ Found 1 ZIM file(s). Skipping ZIM downloads.
✓ Services deployment initiated
✓ Deployment complete. 16/16 services running.
✓ Homepage is responding
✓ Kiwix is responding
✓ Configuration backup created
```

## 🎛️ Advanced Usage

### Custom Verification
Add custom service checks by editing the `verify_services()` function in `ark-manager.sh`.

### Scheduled Ralph Loops
Add to crontab for daily automated loops:
```bash
# Daily at 3 AM
0 3 * * * /opt/ark/ark-manager.sh loop >> /opt/ark/logs/ralph-loop.log 2>&1
```

### Integration with Monitoring
The manager can be called from monitoring systems:
```bash
# Health check endpoint
if ./ark-manager.sh verify; then
    echo "All services healthy"
else
    echo "Some services failed"
fi
```

## 🛡️ Error Handling

The manager:
- Continues on non-critical errors
- Logs all failures to Captain's Log
- Provides actionable error messages
- Never exits silently on critical failures

## 📈 Status Reporting

The status command shows:
- All service status (running/stopped)
- Storage usage
- Recent log entries
- Quick health overview

## 🎉 Benefits

✅ **Single Entry Point** - One command does everything  
✅ **Fully Automated** - No manual steps required  
✅ **Comprehensive Logging** - Everything is tracked  
✅ **Service Verification** - Know immediately if something fails  
✅ **CrewAI Ready** - Works with autonomous agents  
✅ **GitHub Integrated** - Automatic on every deployment  

---

**Your ARK is now truly autonomous!** 🚀
