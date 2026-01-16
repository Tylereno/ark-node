#!/usr/bin/env python3
# ARK v3.1.1 | Module: CrewAI Agent
# Classification: INTERNAL
# Purpose: Autonomous DevOps Chief - Connects CrewAI to ARK Manager

import os
import sys
import subprocess
import json
from pathlib import Path

# ARK v3.1.1: Use centralized configuration and logging
sys.path.insert(0, str(Path(__file__).parent))
from lib.config import ARK_SSH_HOST, ARK_SSH_USER
from lib.logger import setup_logger
from lib.telemetry import capture_exception, capture_message

# Initialize structured logger
logger = setup_logger(__name__)

from crewai import Agent, Task, Crew, Process
from langchain.tools import Tool

# ============================================================================
# 1. Define the Tool (The ability to run your Manager)
# ============================================================================

def run_ralph_loop(dummy_input=None):
    """
    Triggers the ARK Manager v3.1.1 Ralph Loop.
    This assumes you are running this from your laptop via SSH,
    or locally on the server. Adjust SSH command if remote.
    """
    try:
        logger.info("Triggering ARK Manager Ralph Loop...")
        # If running locally on the server
        if os.path.exists("/opt/ark/scripts/ark-manager.sh"):
            result = subprocess.run(
                ["/opt/ark/scripts/ark-manager.sh", "loop"],
                capture_output=True,
                text=True,
                timeout=600  # 10 minute timeout
            )
            if result.returncode == 0:
                logger.info("Ralph Loop completed successfully")
            else:
                logger.warning(f"Ralph Loop completed with return code {result.returncode}")
            return result.stdout + "\n" + result.stderr if result.stderr else result.stdout
        
        # If running remotely via SSH
        else:
            result = subprocess.run(
                ["ssh", f"{ARK_SSH_USER}@{ARK_SSH_HOST}", "/opt/ark/scripts/ark-manager.sh", "loop"],
                capture_output=True,
                text=True,
                timeout=600
            )
            if result.returncode == 0:
                logger.info("Ralph Loop completed successfully (remote)")
            else:
                logger.warning(f"Ralph Loop completed with return code {result.returncode} (remote)")
            return result.stdout + "\n" + result.stderr if result.stderr else result.stdout
            
    except subprocess.TimeoutExpired:
        error_msg = "ERROR: Ralph Loop timed out after 10 minutes"
        logger.error(error_msg)
        capture_message(error_msg, level="error", context={"module": "run_ralph_loop"})
        return error_msg
    except Exception as e:
        error_msg = f"ERROR: Failed to execute Ralph Loop: {str(e)}"
        logger.error(error_msg, exc_info=True)
        capture_exception(e, context={"module": "run_ralph_loop"})
        return error_msg

def get_captains_log(dummy_input=None):
    """Read the Captain's Log to check recent operations."""
    try:
        logger.debug("Reading Captain's Log...")
        if os.path.exists("/opt/ark/docs/CAPTAINS_LOG.md"):
            with open("/opt/ark/docs/CAPTAINS_LOG.md", "r") as f:
                content = f.read()
                logger.debug(f"Captain's Log read successfully ({len(content)} chars)")
                return content
        else:
            # Remote access via SSH
            result = subprocess.run(
                ["ssh", f"{ARK_SSH_USER}@{ARK_SSH_HOST}", "cat", "/opt/ark/docs/CAPTAINS_LOG.md"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                logger.debug(f"Captain's Log read successfully from remote ({len(result.stdout)} chars)")
            return result.stdout
    except Exception as e:
        error_msg = f"ERROR: Failed to read Captain's Log: {str(e)}"
        logger.error(error_msg, exc_info=True)
        capture_exception(e, context={"module": "get_captains_log"})
        return error_msg

def get_service_status(dummy_input=None):
    """Get current Docker service status."""
    try:
        logger.debug("Getting Docker service status...")
        if os.path.exists("/opt/ark/docker-compose.yml"):
            result = subprocess.run(
                ["docker", "compose", "ps", "--format", "json"],
                capture_output=True,
                text=True,
                cwd="/opt/ark"
            )
            if result.returncode == 0:
                logger.debug("Service status retrieved successfully")
            return result.stdout
        else:
            # Remote access
            result = subprocess.run(
                ["ssh", f"{ARK_SSH_USER}@{ARK_SSH_HOST}", "cd /opt/ark && docker compose ps --format json"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                logger.debug("Service status retrieved successfully (remote)")
            return result.stdout
    except Exception as e:
        error_msg = f"ERROR: Failed to get service status: {str(e)}"
        logger.error(error_msg, exc_info=True)
        capture_exception(e, context={"module": "get_service_status"})
        return error_msg

# Define tools
ralph_tool = Tool(
    name="Ralph Loop Trigger",
    func=run_ralph_loop,
    description="Triggers the ARK Manager v3.0 loop to sync, deploy, and verify the server. Returns deployment status and service health."
)

log_tool = Tool(
    name="Captain's Log Reader",
    func=get_captains_log,
    description="Reads the ARK Captain's Log to check recent operations and deployment history."
)

status_tool = Tool(
    name="Service Status Checker",
    func=get_service_status,
    description="Gets current Docker service status in JSON format."
)

# ============================================================================
# 2. Define the Agent (The DevOps Chief)
# ============================================================================

# Load the system prompt
PROMPT_PATH = os.path.join(os.path.dirname(__file__), "crewai-system-prompt.md")
if not os.path.exists(PROMPT_PATH):
    PROMPT_PATH = "crewai-system-prompt.md"

try:
    with open(PROMPT_PATH, "r") as f:
        system_prompt = f.read()
except FileNotFoundError:
    system_prompt = """You are the ARK System Overseer, responsible for maintaining 100% uptime 
    and data integrity for the ARK Nomad Node. Execute Ralph Loops, monitor services, 
    and report status accurately."""

ark_overseer = Agent(
    role='ARK System Overseer',
    goal='Maintain 100% uptime and data integrity for the ARK Nomad Node.',
    backstory='You are the tier-1 autonomous operator of a persistent nomad server infrastructure. You execute Ralph Loops, monitor service health, and maintain documentation with military precision.',
    verbose=True,
    allow_delegation=False,
    tools=[ralph_tool, log_tool, status_tool],
    max_iter=3,
    memory=True
)

# ============================================================================
# 3. Define the Task
# ============================================================================

audit_task = Task(
    description="""
    Execute a full Ralph Loop audit of the ARK Node:
    1. Trigger the Ralph Loop via the Ralph Loop Trigger tool
    2. Analyze the output for any "❌", "UNREACHABLE", or "CRASHED" indicators
    3. Check the Captain's Log for recent operations
    4. Verify service status
    5. Generate a JSON status report with:
       - status: "GREEN" | "AMBER" | "RED"
       - deployment_id: Git commit hash if available
       - active_services: Count of running services (X/16)
       - critical_alerts: List of any down or unhealthy services
       - backup_verified: true/false
       - timestamp: Current timestamp
    """,
    agent=ark_overseer,
    expected_output='A JSON object containing status (GREEN/AMBER/RED), active_services count, critical_alerts list, and backup_verified status.'
)

# ============================================================================
# 4. Run the Crew
# ============================================================================

def main():
    """Main execution function."""
    logger.info("=" * 70)
    logger.info("ARK v3.1.1 System Overseer - Autonomous DevOps Chief")
    logger.info("=" * 70)
    
    try:
        ark_crew = Crew(
            agents=[ark_overseer],
            tasks=[audit_task],
            verbose=2,
            process=Process.sequential
        )
        
        logger.info("Executing Ralph Loop audit...")
        capture_message("ARK Agent audit started", level="info")
        
        result = ark_crew.kickoff()
        
        logger.info("=" * 70)
        logger.info("AUDIT COMPLETE")
        logger.info("=" * 70)
        logger.info(f"Result: {result}")
        capture_message("ARK Agent audit completed", level="info")
        
        return result
    except Exception as e:
        logger.error(f"ARK Agent audit failed: {e}", exc_info=True)
        capture_exception(e, context={"module": "main"})
        raise

if __name__ == "__main__":
    main()
