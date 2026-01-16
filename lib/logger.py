# ARK v3.1.1 | Module: Structured Logging
# Classification: INTERNAL
# Purpose: Standardized structured logging for all ARK modules

import logging
import sys
from pathlib import Path
from logging.handlers import RotatingFileHandler
from lib.config import LOG_LEVEL, LOG_FILE, LOG_ROTATION_SIZE, LOG_ROTATION_BACKUPS, ARK_DIR

# Parse rotation size (e.g., "10MB" -> 10 * 1024 * 1024)
def parse_size(size_str: str) -> int:
    """Parse size string like '10MB' to bytes."""
    size_str = size_str.upper().strip()
    if size_str.endswith("MB"):
        return int(size_str[:-2]) * 1024 * 1024
    elif size_str.endswith("KB"):
        return int(size_str[:-2]) * 1024
    elif size_str.endswith("GB"):
        return int(size_str[:-2]) * 1024 * 1024 * 1024
    else:
        return int(size_str)  # Assume bytes

# Configure structured log format
STRUCTURED_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
SIMPLE_FORMAT = "%(asctime)s - %(levelname)s - %(message)s"

def setup_logger(name: str, log_file: str = None, level: str = None) -> logging.Logger:
    """
    Set up a standardized logger for ARK modules.
    
    Args:
        name: Logger name (typically __name__)
        log_file: Optional log file path (defaults to LOG_FILE config)
        level: Log level (defaults to LOG_LEVEL config)
    
    Returns:
        Configured logger instance
    """
    logger = logging.getLogger(name)
    
    # Set log level
    log_level = getattr(logging, (level or LOG_LEVEL).upper(), logging.INFO)
    logger.setLevel(log_level)
    
    # Avoid duplicate handlers
    if logger.handlers:
        return logger
    
    # Create formatter
    formatter = logging.Formatter(STRUCTURED_FORMAT, datefmt="%Y-%m-%d %H:%M:%S")
    
    # Console handler (STDOUT for Docker/Systemd)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # File handler (rotating)
    if log_file:
        log_path = Path(log_file)
    else:
        log_path = Path(LOG_FILE)
    
    # Ensure log directory exists
    log_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Create rotating file handler
    max_bytes = parse_size(LOG_ROTATION_SIZE)
    file_handler = RotatingFileHandler(
        log_path,
        maxBytes=max_bytes,
        backupCount=LOG_ROTATION_BACKUPS
    )
    file_handler.setLevel(log_level)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    
    return logger
