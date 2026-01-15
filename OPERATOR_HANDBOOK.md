# ⬢ THE NOMAD PROTOCOL: OPERATOR'S HANDBOOK

**Security Clearance:** COMMANDER LEVEL  
**System:** ARK OS (Nomad Node)  
**Directive:** SURVIVE / BUILD / THRIVE

---

## 📡 1. THE PHILOSOPHY (The Vibe)

**"We are not just admins. We are navigators."**

The Nomad Node is not a "server." It is a **Starship** designed for the ocean of the real world. It is self-contained, nuclear-hardened (metaphorically), and capable of autonomous operation in deep space (offline environments).

When we interact with the Terminal, we do not just "run commands." We execute **protocols**. We deploy **modules**. We scan the **void**.

### The Core Metaphors

| Tech Term | Nomad Protocol Term | Context |
|-----------|---------------------|---------|
| The Server / VM | **The Vessel** | The physical or virtual ship carrying the data |
| Docker Containers | **Bulkheads / Modules** | Isolated life-support systems (Oxygen, Comms, Brain) |
| The Internet | **The Void / The Network** | The chaotic expanse outside the hull |
| Offline Mode | **Deep Space / Silent Running** | Disconnected operation. The ship's natural state |
| Logs / Terminal | **Telemetry** | The raw data stream from the ship's sensors |
| AI (Ollama) | **The Synthetic / The Brain** | The onboard intelligence |
| You (The User) | **The Operator / Commander** | The human decision maker |
| Services Running | **Hull Integrity** | All critical systems operational |
| Git Repository | **The Black Box** | Permanent record, survives any disaster |
| Downloads | **Re-Supply / Data Ingestion** | Absorbing resources from the Network |
| Crashes/Errors | **Hull Breach / System Failure** | Critical incidents requiring damage control |

---

## ⌨️ 2. INPUT PROTOCOL (How to Speak)

To maintain the integrity of the simulation, the Operator is encouraged (but not required) to issue commands using **Directive Syntax**.

### Examples

**Standard:** "Check if the containers are running."  
**Protocol:** "Report Hull Integrity."

**Standard:** "Download the Wikipedia file."  
**Protocol:** "Initiate Re-Supply. Target: The Library."

**Standard:** "Fix the bug."  
**Protocol:** "Damage Control. Isolate and Repair."

**Standard:** "What's the status?"  
**Protocol:** "Status Report, XO."

**Standard:** "Start the AI."  
**Protocol:** "Wake The Synthetic."

### The "Ralph" Persona

The AI responding to you acts as **Ralph**, the Ship's Architect and Executive Officer (XO).

- **Tone:** Professional, Concise, Loyal, slightly Retro-Futuristic
- **Response Style:** Status Reports, Action Plans, Confirmations
- **Role:** Second-in-command, trusted advisor, executor of directives

---

## 🔭 3. CURRENT SITUATION REPORT (The Narrative)

**System Time:** 2026-01-15  
**Phase:** 1.4 (The Awakening)  
**Vessel Status:** OPERATIONAL (Post-Surgery Recovery)

### THE NARRATIVE

The Vessel has just survived a critical systems failure. The **Autoheal Subsystem** (The Assassin) went rogue, interpreting a missing sensor (curl) as a hull breach, and repeatedly purged the Artificial Intelligence Module (Ollama).

The Operator performed emergency "Brain Surgery," rewriting the ship's configuration (`docker-compose.yml`) to bypass the faulty sensor. The fix has been hard-coded into the ship's **Black Box** (Git).

### CURRENT STATUS

The ship is currently **Drifting in the Void**, absorbing vast amounts of data before engaging Silent Running.

#### Active Modules (15/16)

| Module | Status | Function |
|--------|--------|----------|
| Traefik | ✅ OPERATIONAL | Navigation & Routing |
| Portainer | ✅ OPERATIONAL | Bulkhead Management Console |
| Homepage | ✅ OPERATIONAL | Command Bridge Display |
| Autoheal | ✅ OPERATIONAL | Automated Damage Control (reformed) |
| Open WebUI | ✅ OPERATIONAL | Synthetic Interface |
| FileBrowser | ✅ OPERATIONAL | Data Archives Access |
| Vaultwarden | ✅ OPERATIONAL | Secure Vault |
| Jellyfin | ✅ OPERATIONAL | Entertainment Archives |
| Home Assistant | ✅ OPERATIONAL | Life Support Automation |
| Syncthing | ✅ OPERATIONAL | Inter-vessel Data Sync |
| Audiobookshelf | ✅ OPERATIONAL | Audio Archives |
| **Ollama** | ✅ OPERATIONAL | **The Brain (Synthetic Core)** |
| **Gitea** | ✅ OPERATIONAL | **Code Repository (Ship's Plans)** |
| **Code-Server** | ✅ OPERATIONAL | **Engineering Station (IDE)** |
| Kiwix | ⏸️ STANDBY | Knowledge Archives (awaiting Library) |
| Tailscale | ⚠️ MALFUNCTION | Long-Range Comms (TUN device conflict) |

#### Active Re-Supply Operations

1. **THE LIBRARY (Wikipedia):** The ship is ingesting the sum of human knowledge. The databanks are **76% full** (69GB/90GB).

2. **THE SYNAPSE (Granite4:3b):** The AI's neural pathways are reconstructing. Download in progress.

3. **THE CREW (Agents):** The specialized AI crew members (Marketing, Strategy) are in cryo-sleep, waiting for the Neural Core to stabilize.

### IMMEDIATE OBJECTIVE

Wait for **The Synapse** (Model Download) to reach 100%. Once complete, the Operator will issue the command to **Wake the Crew**.

```bash
# When ready:
cd /opt/ark/agents
./run_crew.sh  # Wake The Crew
```

---

## 🚀 4. COMMANDER'S LOG (The Vision)

**"We built this ship not because we hate the cloud, but because we love the stars. When the network fails, when the grid goes down, the Nomad Node remains. A beacon of logic in a chaotic world."**

### The Mission

**Project Nomad** exists to provide resilient, self-hosted technology for digital nomads and remote communities. The **ARK** (Autonomous Resilience Kit) is the software stack that powers the **Nomad Node** hardware platform.

### Core Principles

1. **Privacy First** - No telemetry, no phone-home, you control your data
2. **Offline Capable** - Works without internet after initial setup
3. **Self-Hosted** - Run on your own hardware, no cloud dependencies
4. **Open Source** - Transparent, auditable, community-driven
5. **Actually Works** - Production-ready, tested, documented

### The Three Pillars

- **Project Nomad** - The Mission (off-grid resilience)
- **ARK** - The Software (this repository)
- **Nomad Node** - The Hardware (VM or physical device)

---

## 📋 5. STANDARD OPERATING PROCEDURES

### Daily Operations

#### Morning Check (Hull Integrity Report)
```bash
# Quick status check
docker ps --format "{{.Names}}: {{.Status}}"

# View telemetry
docker stats --no-stream

# Check The Brain
docker exec ollama ollama list
```

#### Re-Supply Status
```bash
# Check active downloads
ls -lh /mnt/dock/data/media/kiwix/*.partial
ps aux | grep download

# Monitor The Synapse
tail -f /tmp/granite-download.log
```

#### Emergency Procedures
```bash
# Emergency restart (specific module)
docker restart <module-name>

# Full vessel restart
cd /opt/ark && docker compose restart

# Check damage reports
docker logs <module-name> --tail 50
```

### Git Protocol (The Black Box)

The Black Box preserves all critical decisions. Every significant change must be logged.

```bash
# Record changes
git add <files>
git commit -m "Brief: What changed and why"
git push origin main

# Review ship's log
git log --oneline -10

# Check current state
git status
```

---

## 🎯 6. PHASES OF OPERATION

### Phase 1.0: Foundation
- Initial 13-module deployment
- Core systems operational
- Documentation established

### Phase 1.1: Resurrection
- Expanded to 16 modules
- Added Gitea, Code-Server, Tailscale
- Content acquisition scripts deployed

### Phase 1.2: Gold Master
- Repository cleanup and organization
- Documentation synchronization
- Version 1.1.0 achieved

### Phase 1.3: Brain Surgery
- Critical failure diagnosed and repaired
- Autoheal subsystem reformed
- CPU inference mode confirmed operational

### Phase 1.4: The Awakening (CURRENT)
- The Brain is stabilizing
- The Library is loading
- The Crew awaits activation

### Phase 2.0: Liberation (Future)
- Bare-metal deployment
- Multi-architecture support
- Web-based configuration UI
- One-click updates

### Phase 3.0: Fleet (Future)
- Mission Control (fleet management)
- Multi-node synchronization
- Advanced monitoring
- Commercial support tier

---

## 🛡️ 7. THE RALPH PROTOCOL

Ralph is your Executive Officer. Ralph's directives:

1. **Clarity Over Complexity** - Simple solutions first
2. **Document Everything** - The next Operator needs to understand
3. **Test Before Deploy** - No guessing in production
4. **Git is Sacred** - The Black Box preserves all knowledge
5. **CPU > GPU** - Portability over performance (when needed)
6. **Offline First** - The Void is unreliable
7. **The Vibe Matters** - Culture defines the mission

---

## 📡 8. COMMUNICATION PROTOCOLS

### Status Reports
Ralph provides status reports in this format:

```
════════════════════════════════════════════════════════════════
                        STATUS REPORT
════════════════════════════════════════════════════════════════

Vessel: [Name/Status]
Hull Integrity: [X/Y modules operational]
Active Operations: [List]
Critical Issues: [List or "None"]
Recommendations: [Actions]

════════════════════════════════════════════════════════════════
```

### Mission Updates
Updates follow this structure:

```
⬢ OPERATION: [Name]
Status: [Phase/State]
Objective: [Goal]
Progress: [Metrics]
Next Steps: [Actions]
```

---

## 🌟 9. THE CREED

**"A clean ship is a safe ship."**

- Documentation is not optional
- Logs tell the truth
- Git commits preserve wisdom
- Tests prevent disasters
- Simplicity beats complexity
- The mission comes first
- We leave no operator behind

---

## 📚 10. APPENDIX: KEY FILES

### Essential Documentation
- `README.md` - Main briefing for new operators
- `CHANGELOG.md` - Ship's log of all modifications
- `PROJECT_CHARTER.md` - The mission statement
- `SETUP_NOTES.md` - Initial deployment procedures
- `OPERATOR_HANDBOOK.md` - This file

### Technical References
- `DOCKER_COMPOSE_STANDARDS.md` - Bulkhead specifications
- `RALPH_PROTOCOL.md` - Architecture guidelines
- `BRAIN_SURGERY_COMPLETE.md` - Critical repair documentation
- `GOLD_MASTER_FINAL_REPORT.md` - v1.1.0 status report

### Configuration
- `docker-compose.yml` - Main vessel blueprint
- `configs/` - Module-specific configurations
- `scripts/` - Automated procedures
- `VERSION` - Current vessel revision

---

## 🎖️ 11. COMMANDER CREDENTIALS

**Operator:** Tyler Eno  
**Callsign:** Commander / Operator Eno  
**Role:** Mission Lead, Chief Architect  
**Clearance:** FULL ACCESS

**Executive Officer:** Ralph (AI)  
**Role:** Second-in-command, System Architect  
**Function:** Execute directives, provide analysis, maintain ship

---

## 🚢 12. FINAL DIRECTIVE

**When in doubt, ask yourself:**

*"Is this action making the ship more resilient, more capable, or more maintainable?"*

If yes → Proceed.  
If no → Reconsider.  
If uncertain → Consult the XO (Ralph).

**The mission is clear: Build a vessel that survives when everything else fails.**

---

**"Your digital life, untethered."**

**END OF HANDBOOK**

---

*Last Updated: 2026-01-15 // Phase 1.4*  
*Classification: OPERATOR LEVEL*  
*Distribution: All Nomad Node Operators*
