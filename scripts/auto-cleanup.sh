#!/bin/bash
################################################################################
# AUTO-CLEANUP.SH - Automatic Root Folder Cleanup
# Part of: Project Nomad (ARK Node)
# Purpose: Run cleanup after deployments to prevent clutter
################################################################################

ARK_DIR="/opt/ark"
ARCHIVE_DIR="$ARK_DIR/docs/archive"

# Ensure archive exists
mkdir -p "$ARCHIVE_DIR"

# Move any stray markdown files (except essential ones) to archive
ESSENTIAL_FILES=("README.md" "MASTER_LIST.txt" "crewai-system-prompt.md")

find "$ARK_DIR" -maxdepth 1 -name "*.md" -type f | while read -r file; do
    filename=$(basename "$file")
    is_essential=false
    
    for essential in "${ESSENTIAL_FILES[@]}"; do
        if [ "$filename" = "$essential" ]; then
            is_essential=true
            break
        fi
    done
    
    if [ "$is_essential" = false ]; then
        mv "$file" "$ARCHIVE_DIR/" 2>/dev/null && echo "Archived: $filename"
    fi
done

# Move any stray scripts to /scripts
if [ -f "$ARK_DIR"/*.sh ] 2>/dev/null; then
    for script in "$ARK_DIR"/*.sh; do
        if [ -f "$script" ] && [ "$(basename "$script")" != "ark-manager.sh" ]; then
            mv "$script" "$ARK_DIR/scripts/" 2>/dev/null && echo "Moved script: $(basename "$script")"
        fi
    done
fi

echo "Auto-cleanup complete"
