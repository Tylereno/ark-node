# ARK v3.1.2 - Datadog Infrastructure Monitoring Setup

## Overview

Datadog provides real-time infrastructure monitoring for ARK, giving you visibility into CPU, memory, disk, and Docker container health from anywhere.

## Prerequisites

- Datadog account (via GitHub Student Pack)
- API key from Datadog dashboard

## Setup Steps

### Step 1: Get Your API Key

1. Log in to [Datadog](https://app.datadoghq.com/)
2. Navigate to: **Organization Settings → API Keys**
3. Copy your API key (long purple string)

### Step 2: Configure Environment

Add your API key to your `.env` file:

```bash
# Edit .env file
nano /opt/ark/.env

# Add this line:
DD_API_KEY=your_long_purple_string_here
```

### Step 3: Deploy the Agent

```bash
cd /opt/ark

# Deploy Datadog agent (part of core profile)
docker compose --profile core up -d datadog-agent

# Or deploy all core services including Datadog
docker compose --profile core up -d
```

### Step 4: Verify Deployment

```bash
# Check agent is running
docker ps | grep datadog-agent

# Check agent logs
docker logs datadog-agent
```

### Step 5: Verify in Dashboard

1. Go to: https://app.datadoghq.com/
2. Navigate to: **Infrastructure → Infrastructure List**
3. Look for **`nomad-node`** with green status
4. Click on it to see live metrics

## What You'll See

- **CPU Usage** - Real-time CPU graphs
- **Memory Usage** - RAM consumption over time
- **Disk I/O** - Storage read/write metrics
- **Docker Containers** - Health status of all ARK services
- **Network Traffic** - Bandwidth usage

## Configuration Details

The Datadog agent is configured with:

- **Image**: `gcr.io/datadoghq/agent:7` (pinned for LTS)
- **Profile**: `core` (deployed with essential services)
- **Host Access**: Mounts `/proc`, `/sys/fs/cgroup`, and Docker socket
- **Container Filtering**: Monitors ARK containers, excludes itself

## Troubleshooting

**Agent not appearing in dashboard:**
- Verify API key is correct in `.env`
- Check agent logs: `docker logs datadog-agent`
- Ensure agent container is running: `docker ps | grep datadog`

**No metrics showing:**
- Wait 2-3 minutes for initial data collection
- Verify network connectivity (agent needs internet)
- Check Datadog site matches your account region

## Graceful Degradation

If the Datadog API key is not configured, the agent will fail to start. This is expected behavior - the system continues operating normally without monitoring.

## Next Steps

- **Embed Dashboard**: Add Datadog graphs to your website
- **Set Alerts**: Configure alerts for CPU spikes or disk full
- **Custom Metrics**: Add custom metrics for solar battery voltage (if applicable)
