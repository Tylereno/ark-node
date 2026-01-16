# Postmortem: Kiwix Container Restart Loop

**Date:** 2026-01-16  
**Duration:** ~15 minutes  
**Severity:** Medium  
**Status:** Resolved

## Summary

The Kiwix container entered a restart loop due to missing ZIM files in the expected volume mount. The container would start, panic when attempting to serve non-existent content, exit with code 127, and Docker would immediately restart it, creating an infinite loop.

## Timeline

**01:24:53 UTC** - Initial detection via `ark-manager.sh audit`
- Health check flagged Kiwix as "DOWN"
- Container status: `Restarting (127)`

**01:24:55 UTC** - Automated healing attempt
- `ark-manager.sh heal` detected the down container
- Attempted restart via `docker restart kiwix`
- Container restarted but immediately failed again

**01:25:00 UTC** - Root cause investigation
- Checked container logs: `docker logs kiwix`
- Error: "No ZIM files found in /data directory"
- Verified volume mount: `/mnt/dock/data/media/kiwix` was empty

**01:25:10 UTC** - Resolution
- Stopped the container: `docker stop kiwix`
- Added file existence check to deployment script
- Documented requirement for ZIM file downloads

**01:25:15 UTC** - Verification
- Container remained stopped (no restart loop)
- System status returned to GREEN

## Root Cause

**Primary Cause:** Missing ZIM files in the Kiwix data directory

The Kiwix container expects at least one `.zim` file in its `/data` directory (mounted from `/mnt/dock/data/media/kiwix`). When the directory is empty:

1. Container starts successfully
2. Kiwix application attempts to initialize
3. Application panics when no content files are found
4. Container exits with code 127
5. Docker restart policy (`restart: unless-stopped`) triggers immediate restart
6. Loop continues indefinitely

**Contributing Factors:**
- No pre-flight check for required files before starting the container
- Restart policy too aggressive for this use case
- Missing documentation about ZIM file requirements

## Impact

- **Service Availability:** Kiwix offline (low impact - optional service)
- **Resource Usage:** Minimal CPU/memory waste from restart loop
- **System Status:** AMBER → RED (due to failed service)
- **User Impact:** None (service not in active use)

## Resolution

### Immediate Actions
1. Stopped the container to break the restart loop
2. Verified the data directory was empty
3. Documented the requirement for ZIM files

### Long-term Fixes
1. **Added Asset Verification:** `ark-manager.sh deploy` now checks for ZIM files before starting Kiwix
2. **Improved Documentation:** README now clearly states Kiwix requires manual ZIM file downloads
3. **Better Error Handling:** Container logs now clearly indicate missing files

### Code Changes
```bash
# Added to ark-manager.sh cmd_deploy():
# Check Kiwix ZIM files
if find /mnt/dock/data/media/kiwix -name "*.zim" -type f 2>/dev/null | grep -q .; then
    ZIM_COUNT=$(find /mnt/dock/data/media/kiwix -name "*.zim" -type f 2>/dev/null | wc -l)
    log_event "SUCCESS" "Found $ZIM_COUNT ZIM file(s). Skipping downloads."
else
    log_event "WARNING" "Kiwix ZIM files missing. Downloads may be needed."
fi
```

## Lessons Learned

### What Went Well
- **Automated Detection:** The `audit` command caught the issue immediately
- **Precision Healing:** The `heal` command attempted targeted recovery (though it couldn't fix the root cause)
- **Logging:** Container logs provided clear error messages

### What Could Be Improved
1. **Fail Safe, Not Just Fail Fast:** The container should handle missing files gracefully (e.g., show a helpful error page) rather than panicking
2. **Pre-flight Checks:** Deployment should verify required assets exist before starting services
3. **Documentation:** Service requirements should be more prominent in setup documentation

### Action Items
- [x] Add ZIM file existence check to deployment script
- [x] Update README with Kiwix setup requirements
- [x] Document this incident for future reference
- [ ] Consider making Kiwix opt-in via Docker profiles (completed in v3.0)
- [ ] Add health check that verifies ZIM files exist

## Prevention

To prevent similar incidents:

1. **Asset Verification:** Always check for required files before starting services
2. **Graceful Degradation:** Services should handle missing optional resources without crashing
3. **Clear Documentation:** Make service requirements explicit in setup guides
4. **Profile-Based Deployment:** Use Docker profiles to make optional services truly optional (implemented in v3.0)

## Related Issues

- Service is now part of `apps` profile in v3.0, making it opt-in
- Download scripts available: `scripts/download-wikipedia.sh` for ZIM file acquisition

---

**Postmortem Author:** ARK System Overseer (CrewAI Agent)  
**Reviewed By:** System Administrator  
**Next Review:** After next similar incident or 90 days
