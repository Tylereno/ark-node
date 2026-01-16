# ARK v3.1.1 | Module: Configuration Manager
# Classification: INTERNAL
# Purpose: Centralized configuration loading from environment variables

import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env file if it exists (graceful degradation if missing)
ARK_DIR = Path(__file__).parent.parent
ENV_FILE = ARK_DIR / ".env"
load_dotenv(ENV_FILE)

# ARK Core Configuration
ARK_VERSION = os.getenv("ARK_VERSION", "3.1.1")
ARK_NODE_IP = os.getenv("ARK_NODE_IP", "192.168.26.8")
ARK_DOMAIN = os.getenv("ARK_DOMAIN", "localhost")
ARK_ADMIN_USER = os.getenv("ARK_ADMIN_USER", "admin")
ARK_ADMIN_PASSWORD = os.getenv("ARK_ADMIN_PASSWORD", "CHANGE_ME_NOW")

# Sentry Telemetry Configuration
SENTRY_DSN = os.getenv("SENTRY_DSN", "")
SENTRY_ENVIRONMENT = os.getenv("SENTRY_ENVIRONMENT", "production")
SENTRY_RELEASE = os.getenv("SENTRY_RELEASE", f"ark-node@{ARK_VERSION}")

# Logging Configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
LOG_FORMAT = os.getenv("LOG_FORMAT", "structured")
LOG_FILE = os.getenv("LOG_FILE", str(ARK_DIR / "logs" / "ark.log"))
LOG_ROTATION_SIZE = os.getenv("LOG_ROTATION_SIZE", "10MB")
LOG_ROTATION_BACKUPS = int(os.getenv("LOG_ROTATION_BACKUPS", "5"))

# Ollama AI Configuration
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
MODEL_CHAT = os.getenv("MODEL_CHAT", "granite4:3b")
MODEL_CODER = os.getenv("MODEL_CODER", "qwen2.5-coder:3b")
MODEL_VISION = os.getenv("MODEL_VISION", "qwen3-vl:2b")
MODEL_EMBEDDING = os.getenv("MODEL_EMBEDDING", "nomic-embed-text")

# Voice Watcher Configuration
INPUT_DIR = Path(os.getenv("INPUT_DIR", str(ARK_DIR / "data" / "input")))
OUTPUT_DIR = Path(os.getenv("OUTPUT_DIR", str(ARK_DIR / "data" / "output")))
PROCESSED_DIR = Path(os.getenv("PROCESSED_DIR", str(ARK_DIR / "data" / "input" / "processed")))

# SSH Configuration
ARK_SSH_HOST = os.getenv("ARK_SSH_HOST", "100.124.104.38")
ARK_SSH_USER = os.getenv("ARK_SSH_USER", "nomadty")

# Optional Services
TAILSCALE_AUTHKEY = os.getenv("TAILSCALE_AUTHKEY", "")
CLOUDFLARE_TUNNEL_TOKEN = os.getenv("CLOUDFLARE_TUNNEL_TOKEN", "")
CLOUDFLARE_API_TOKEN = os.getenv("CLOUDFLARE_API_TOKEN", "")
CLOUDFLARE_ZONE_ID = os.getenv("CLOUDFLARE_ZONE_ID", "")

# SMTP Configuration
SMTP_HOST = os.getenv("SMTP_HOST", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER = os.getenv("SMTP_USER", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM = os.getenv("SMTP_FROM", "ark@your-domain.com")

# Timezone
TZ = os.getenv("TZ", "America/Los_Angeles")
