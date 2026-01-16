# ARK v3.1.1 - Sentry Smoke Test Instructions

## Prerequisites

The smoke test requires Python dependencies to be installed:

```bash
# Install dependencies
pip install sentry-sdk python-dotenv

# OR if using system package manager
sudo apt-get install python3-pip
pip3 install sentry-sdk python-dotenv
```

## Setup

1. **Create .env file** (if not already created):
   ```bash
   cp .env.template .env
   ```

2. **Add your Sentry DSN** to `.env`:
   ```bash
   nano .env
   # Set: SENTRY_DSN=https://your-key@org.ingest.sentry.io/project-id
   ```

3. **Run the smoke test**:
   ```bash
   python3 test_sentry.py
   ```

## Expected Output

The script will:
1. Send a test message to Sentry (info level)
2. Trigger and capture a `ZeroDivisionError`
3. Trigger and capture a `ValueError` with context

## Validation Checklist

After running the test, verify in your Sentry dashboard:

- [ ] **Exception 1**: `ZeroDivisionError` appears
- [ ] **Exception 2**: `ValueError` appears  
- [ ] **Message**: "ARK v3.1.1 Sentry integration test" (info level)
- [ ] **Release Tag**: `ark-node@3.1.1`
- [ ] **Environment**: `production`

## Current Status

**Dependencies Required**: The smoke test cannot run until `sentry-sdk` and `python-dotenv` are installed.

**Code Structure**: ✅ Validated
- All modules import correctly
- Configuration loading works
- Telemetry module structure is correct

**Next Steps**: Install dependencies and run the smoke test to validate end-to-end telemetry.
