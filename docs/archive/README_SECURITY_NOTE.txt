═══════════════════════════════════════════════════════════════
IMPORTANT SECURITY NOTE - READ THIS FIRST
═══════════════════════════════════════════════════════════════

The default password "arknode123" appears in docker-compose.yml as a
FALLBACK VALUE ONLY. This is safe and intentional for a public repo.

The syntax:
  ${CODE_SERVER_PASSWORD:-arknode123}

Means:
  1. Try to use CODE_SERVER_PASSWORD environment variable (your password)
  2. If not set, fall back to arknode123 (for testing/development)

BEFORE YOU DEPLOY:

1. Copy vessel_secrets.example to vessel_secrets.env
2. Change ALL passwords to strong, unique values
3. Load secrets: source vessel_secrets.env
4. Then deploy: docker compose up -d

READ THIS FOR COMPLETE SETUP:
  - MANUAL_SETUP_STEPS.md (step-by-step guide)
  - SECURITY_CHECKLIST.md (verification list)
  - docs/guides/SECURITY_SETUP.md (detailed guide)

═══════════════════════════════════════════════════════════════
