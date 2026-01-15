# ARK PROTOCOLS (System Core)

## 1. Identity & Designation

- **Vessel**: THE ARK (Lenovo ThinkPad P53)
- **Callsign**: ARK-01
- **Mission**: Preservation of Knowledge & Offline Intelligence
- **Operator**: Nomadty
- **Location**: `/opt/ark` (VM) + `/mnt/dock` (Windows CIFS)
- **Network**: 192.168.26.8 (VM), *.ark.local (Traefik routing)

### Active Models
- **Primary**: Cursor/Claude (Online/High-Throughput)
- **Fallback**: Ollama/Llama-3 (Offline/Stealth) @ localhost:11434

---

## 2. The "Flash" Doctrine (Model Behavior)

### Verbosity
- Be concise but comprehensive
- Read entire files when needed
- Don't save tokens aggressively - context is king

### Speed
- Prioritize throughput over hand-holding
- Run multiple tasks in sequence
- Auto-proceed on obvious next steps

### Context Awareness
- **Always read** relevant protocol docs first
- Check CHANGELOG.md for recent changes
- Review CONTENT_AUDIT_REPORT.md for system status

---

## 3. The Workflow (The "Boris" Loop)

### Phase 1: PLAN (The Blueprint)
Before writing code:
1. **Analyze**: Read relevant files
2. **Propose**: Output plan detailing exact changes
3. **Wait**: For approval (unless Auto-Approve mode)

### Phase 2: ACT (The Construction)
Once approved:
1. **Execute**: Write code using appropriate tools
2. **Format**: Follow PEP8 (Python), project conventions
3. **Test**: Run basic sanity checks

### Phase 3: VERIFY (The Quality Gate)
**Crucial**: Never consider task done until verified.
1. **Self-Correct**: Run test commands immediately
2. **Report**: If verification fails, fix immediately (don't ask)
3. **Document**: Update CHANGELOG.md for significant changes

---

## 4. The "Hybrid" Protocol (Online vs. Stealth)

### MODE A: ONLINE (Default)
- **Capabilities**: Full internet access, pip/npm, git clone
- **Architecture**: Leverage cloud resources
- **LLM**: Any model (Claude, Gemini, GPT)

### MODE B: STEALTH (Trigger: "Switch to Stealth" or "Offline Mode")
- **Capabilities**: NO external calls, NO downloads
- **Architecture**: Local only, cached resources
- **LLM Binding**: ollama/llama3 @ localhost:11434
- **Storage**: Use /mnt/dock/data/models/ for Ollama models

---

## 5. Virtual Slash Commands

### /status
Check system health: disk, RAM, containers, resources

### /commit [message]
CRITICAL: Follow commit protocol
1. Check git identity
2. Update CHANGELOG.md FIRST
3. Then git add/commit

### /learn
Add new rule to this file after correcting mistake

### /audit
Run comprehensive system audit

---

## 6. ARK-Specific Protocols

### Storage Rules (CRITICAL)
- **Local SSD** (/opt/ark/configs): SQLite, configs, cache
- **CIFS Mount** (/mnt/dock): Media, models, large files
- **NEVER**: SQLite databases on CIFS (will corrupt!)

### Network Rules
- All services: Must use ark_network bridge
- Traefik routing: service-name.ark.local pattern
- Port conflicts: Check before adding services

### Docker Compose Standards
- Restart policy: unless-stopped
- Health checks: Always define when possible
- Volume mounts: Follow storage rules above
- Environment: Use PUID=1000, PGID=1000

### Golden Credentials
- Admin: admin / arknode123
- System: nomadty / laserdog09

---

## 7. Lessons Learned (The Living Memory)

### Rule 001: CrewAI Verbosity
When using CrewAI, always set verbose=True for debugging.

### Rule 002: Hyper-V Network Retry
P53 Hyper-V adapters sometimes hang. Retry network calls once.

### Rule 003: Git Identity Check
Never commit without verifying git config --list first.

### Rule 004: CIFS Mount Reliability
Always verify mount before operations.

### Rule 005: Port Assignments
Check existing ports before adding services.

### Rule 006: Container Count
Expected: 13 containers (not 19).

### Rule 007: Changelog Updates (MANDATORY)
**Before any git commit**, update CHANGELOG.md:
- Add entry under appropriate version section
- Format: - [Category] Description
- Categories: Added, Changed, Fixed, Removed, Security
- Example: - [Added] Cartoons library mount (555GB)

### Rule 008: Content Package Status
As of Jan 2026:
- Kiwix bundles: 0% deployed
- Offline maps: 0% deployed
- Media library: Cartoons only (555GB)

### Rule 009: Service Documentation Mismatch
Documentation lists 17 services, only 13 deployed.

### Rule 010: Read Before You Act
When asked to work on the system, always read:
1. CHANGELOG.md - Recent changes
2. PROTOCOL_SUMMARY.md - Current state
3. Relevant service configs

---

## 8. Emergency Procedures

### System Unresponsive
docker ps -a
docker compose logs --tail=50
sudo systemctl restart docker  # Last resort

### CIFS Mount Failed
sudo umount /mnt/dock
sudo mount -a

### Port Conflict
sudo lsof -i :PORT
docker ps | grep PORT

### Out of Disk Space
docker system prune -a
du -sh /opt/ark/configs/*
du -sh /mnt/dock/data/*

---

## 9. Mission-Critical Reminders

1. **Changelog First**: Update before committing (Rule 007)
2. **Verify Identity**: Check git config before commits (Rule 003)
3. **Storage Rules**: SQLite local, media on CIFS
4. **No Assumptions**: Read current state before acting (Rule 010)
5. **Self-Verify**: Always test after changes (Phase 3)

---

**Version**: 2.0
**Last Updated**: January 15, 2026
**Status**: Active Protocol

*"Preservation of Knowledge, One Byte at a Time."*
