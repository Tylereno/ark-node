# ARK Node - Content & Services Audit Report
**Date:** January 15, 2026  
**Reporter:** Tyler Eno  
**Status:** CRITICAL - Major discrepancies found

---

## Executive Summary

**Critical Findings:**
1. **Documentation/Reality Mismatch**: Service documentation lists different containers than actually deployed
2. **Missing Content**: Zero offline content packages deployed (0% of documented features)
3. **Empty Directories**: All content directories are empty
4. **Container Count**: 13 running (not 19 as expected)
5. **Missing Services**: 6 documented services not in docker-compose.yml

---

## 🚨 Container Count Discrepancy

### You Said: "I think it was 19 containers"

**Current Reality:** 13 containers running

**Documented:** 13 services (but different ones!)

**Likely Source of Confusion:**
- Documentation mentions 13 services but DIFFERENT services than deployed
- Marketing materials reference additional features not yet implemented
- v2.0 roadmap mentions additional planned services
- Content packages documentation suggests more infrastructure

---

## 🔍 Service Mismatch Analysis

### Services in docker-compose.yml (ACTUAL)
1. ✅ Traefik - Reverse proxy
2. ✅ Portainer - Container management
3. ✅ Homepage - Dashboard
4. ✅ Autoheal - Container watchdog
5. ✅ Ollama - AI LLM API
6. ✅ Open WebUI - Chat interface
7. ✅ Jellyfin - Media server
8. ✅ Audiobookshelf - Audiobooks
9. ✅ FileBrowser - File manager
10. ✅ Syncthing - File sync
11. ✅ Vaultwarden - Password manager
12. ⚠️ Kiwix - Offline Wiki (NO CONTENT)
13. ✅ Home Assistant - IoT/Automation

### Services in Documentation but NOT Deployed
14. ❌ **AdGuard Home** - Network ad blocking/DNS
15. ❌ **Glances** - System monitoring
16. ❌ **Watchtower** - Container updates
17. ❌ **Voice Watcher** - Voice note transcription

See full report at: /opt/ark/CONTENT_AUDIT_REPORT.md
