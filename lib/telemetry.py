# ARK v3.1.1 | Module: Telemetry (Sentry Integration)
# Classification: INTERNAL
# Purpose: Enterprise-grade error tracking and telemetry

import os
import logging
from lib.config import SENTRY_DSN, SENTRY_ENVIRONMENT, SENTRY_RELEASE

# Set up basic logger for telemetry module (before Sentry init)
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Initialize Sentry if DSN is configured
sentry_initialized = False

if SENTRY_DSN:
    try:
        import sentry_sdk
        from sentry_sdk.integrations.logging import LoggingIntegration
        
        # Configure Sentry with logging integration
        logging_integration = LoggingIntegration(
            level=logging.INFO,        # Capture info and above
            event_level=logging.ERROR  # Send errors and above as events
        )
        
        sentry_sdk.init(
            dsn=SENTRY_DSN,
            environment=SENTRY_ENVIRONMENT,
            release=SENTRY_RELEASE,
            integrations=[logging_integration],
            # Performance monitoring
            traces_sample_rate=0.1,  # 10% of transactions
            # Session replay (optional, can be enabled later)
            # enable_tracing=True,
        )
        sentry_initialized = True
        logging.info("Sentry telemetry initialized successfully")
    except ImportError:
        logging.warning("sentry-sdk not installed. Telemetry disabled. Install with: pip install sentry-sdk")
        sentry_initialized = False
    except Exception as e:
        logging.warning(f"Failed to initialize Sentry: {e}. Continuing with local logging only.")
        sentry_initialized = False
else:
    logging.info("Sentry DSN not configured. Telemetry disabled. System will continue with local logging only.")

def capture_exception(error: Exception, context: dict = None):
    """Capture an exception to Sentry if initialized."""
    if sentry_initialized:
        try:
            import sentry_sdk
            with sentry_sdk.push_scope() as scope:
                if context:
                    for key, value in context.items():
                        scope.set_context(key, value)
                sentry_sdk.capture_exception(error)
        except Exception as e:
            logging.error(f"Failed to capture exception to Sentry: {e}")

def capture_message(message: str, level: str = "info", context: dict = None):
    """Capture a message to Sentry if initialized."""
    if sentry_initialized:
        try:
            import sentry_sdk
            with sentry_sdk.push_scope() as scope:
                if context:
                    for key, value in context.items():
                        scope.set_context(key, value)
                sentry_sdk.capture_message(message, level=level)
        except Exception as e:
            logging.error(f"Failed to capture message to Sentry: {e}")

def set_user_context(user_id: str = None, username: str = None, email: str = None):
    """Set user context for Sentry events."""
    if sentry_initialized:
        try:
            import sentry_sdk
            sentry_sdk.set_user({
                "id": user_id,
                "username": username,
                "email": email
            })
        except Exception as e:
            logging.error(f"Failed to set Sentry user context: {e}")
