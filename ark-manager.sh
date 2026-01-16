#!/bin/bash
# Convenience wrapper - ARK Manager is now in scripts/
# This wrapper ensures backward compatibility

exec /opt/ark/scripts/ark-manager.sh "$@"
