# 🤖 ARK CrewAI Agent Setup

## Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment (Optional)
Create a `.env` file if running remotely:
```bash
ARK_SSH_HOST=100.124.104.38
ARK_SSH_USER=nomadty
```

### 3. Run the Agent
```bash
python3 ark_agent.py
```

## What It Does

The CrewAI agent:
1. **Executes Ralph Loop** - Triggers full deployment cycle
2. **Analyzes Output** - Checks for errors and warnings
3. **Verifies Services** - Confirms all services are healthy
4. **Generates Report** - Creates JSON status report
5. **Escalates Issues** - Alerts on critical failures

## Output Format

The agent returns a JSON status report:
```json
{
  "status": "GREEN" | "AMBER" | "RED",
  "deployment_id": "abc1234",
  "active_services": "16/16",
  "critical_alerts": [],
  "backup_verified": true,
  "timestamp": "2026-01-16T01:00:00Z"
}
```

## Integration

### Schedule Daily Audits
```python
# Add to your cron or scheduler
import schedule
import time
from ark_agent import main

schedule.every().day.at("04:00").do(main)

while True:
    schedule.run_pending()
    time.sleep(60)
```

### Use in Monitoring
```python
from ark_agent import ark_crew, audit_task

result = ark_crew.kickoff()
status = json.loads(result)
if status["status"] == "RED":
    send_alert("Critical issues detected!")
```

---

**Your autonomous DevOps Chief is ready to serve!** 🚀
