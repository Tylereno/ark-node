# ARK Node LTS (Long Term Support) Policy

**Version:** 3.1.0  
**Effective Date:** 2026-01-16  
**Status:** Active

---

## LTS Declaration

ARK Node v3.1.0 is declared a **Long Term Support (LTS) release**. This version represents a stable, feature-complete platform suitable for production deployments in constrained edge environments.

## What LTS Means

### Feature Freeze

**No new features will be added to v3.1.0.**

The codebase is frozen to ensure:
- **Deterministic Behavior**: The system behaves identically across deployments
- **Stability**: No unexpected changes from feature additions
- **Predictability**: Operators can rely on consistent behavior

### Maintenance Scope

LTS maintenance includes **only**:

1. **Security Patches**
   - Critical vulnerabilities in dependencies
   - Container image security updates
   - Zero-day exploits affecting core services

2. **Constraint-Driven Fixes**
   - Breaking changes in upstream dependencies (Docker, base images)
   - Changes required for compatibility with new OS versions
   - Fixes for issues that prevent deployment in target environments

3. **Documentation Corrections**
   - Clarifications to existing documentation
   - Fixes for incorrect information
   - Updates to reflect actual behavior

### What LTS Does NOT Include

- New services or features
- Performance optimizations (unless security-related)
- UI/UX improvements
- New configuration options
- Experimental features
- "Nice to have" enhancements

## Version Pinning

All Docker images in v3.1.0 are pinned to specific versions:

| Service | Version | Notes |
|---------|---------|-------|
| Traefik | v3.1 | Pinned |
| Portainer | 2.20.4 | Pinned |
| Homepage | v1.0.0 | Pinned |
| Autoheal | latest | Uses 'latest' as stable tag |
| Ollama | 0.1.30 | Pinned |
| Jellyfin | 10.11.4 | Pinned |
| Audiobookshelf | v2.10.0 | Pinned |
| FileBrowser | v2.49.0 | Pinned |
| Syncthing | v1.27.7 | Pinned |
| Vaultwarden | v1.32.0 | Pinned |
| Kiwix | 3.8.0 | Pinned |
| Tailscale | v1.68.0 | Pinned |
| Gitea | 1.23.4 | Pinned |
| Code-Server | 4.24.0 | Pinned |
| Home Assistant | stable | Uses 'stable' tag |

**Do not update these versions** unless:
- A security vulnerability is discovered
- The upstream image is removed from Docker Hub
- A critical compatibility issue is identified

## Support Commitment

### Duration

LTS support is provided for **a minimum of 12 months** from the release date (until 2027-01-16).

### Support Channels

- **Security Issues**: GitHub Security Advisories
- **Critical Bugs**: GitHub Issues (tagged `lts-critical`)
- **Documentation**: GitHub Discussions

### Response Times

- **Critical Security**: 48 hours
- **Critical Bugs**: 7 days
- **Documentation**: 30 days

## Upgrade Path

When upgrading from v3.1.0 LTS:

1. Review the changelog for the target version
2. Test in a non-production environment
3. Backup all configuration and data
4. Follow the migration guide (if provided)

## Breaking Changes Policy

If a breaking change is required (e.g., upstream dependency removal):

1. A migration guide will be provided
2. At least 90 days notice will be given
3. The change will be documented in CHANGELOG.md
4. A new minor version will be released (e.g., 3.1.1)

## Philosophy

**"Software should be robust enough to run in the dark."**

ARK Node LTS embodies this principle by:
- Freezing features to ensure stability
- Pinning versions for reproducibility
- Focusing on reliability over novelty
- Prioritizing constraint-driven fixes over enhancements

## Questions?

For questions about LTS policy or to report issues:

- **GitHub Issues**: Tag with `lts` label
- **Security**: Use GitHub Security Advisories
- **General**: GitHub Discussions

---

**This LTS release represents a commitment to stability and reliability for operators deploying infrastructure in constrained edge environments.**
