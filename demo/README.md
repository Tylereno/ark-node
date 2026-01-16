# ARK Demo Scripts

Demonstration tools for showcasing ARK's autonomous recovery capabilities.

## simulate_failure.sh

**Purpose**: Demonstrates ARK's self-healing architecture by simulating a critical service failure and monitoring automatic recovery.

**Usage**:
```bash
sudo /opt/ark/demo/simulate_failure.sh
```

**What It Does**:
1. Identifies a target service (default: `homepage`)
2. Verifies the service is running
3. Simulates a critical process failure (kill -9 or docker stop)
4. Monitors Docker's restart policy for automatic recovery
5. Reports recovery time and validates architecture

**Expected Output**:
- Service failure injection
- Recovery detection within 5-30 seconds
- Success message with recovery metrics
- Log entry in Captain's Log

**Demo Scenario**:
Perfect for demonstrating to potential partners (Oxide, Lilac Solutions, etc.) that ARK's self-healing claims are not marketing fluff—they are kernel-level restart policies that work without human intervention.

## Requirements

- Docker installed and running
- ARK services deployed with `restart: unless-stopped` policies
- Target service must be configured in `docker-compose.yml`

## Notes

- This script is safe to run on production systems (it only stops/restarts containers)
- Recovery time depends on Docker's restart policy configuration
- If recovery fails, manual intervention instructions are provided
