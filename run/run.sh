#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enhanced logging
source "$SCRIPT_DIR/../lib/log_utils.sh" 2>/dev/null || true
set -euo pipefail

# This script is an example of how you might run a deployed script.
# In a real-world scenario, this logic might be part of a CI/CD pipeline job,
# an EC2 user-data script, or a Systems Manager Run Command document.

# --- Configuration ---
SCRIPT_TO_RUN="$1"
SCRIPT_ARGS=("${@:2}")

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"

# --- Validation ---
if [ -z "$SCRIPT_TO_RUN" ]; then
    echo "Usage: $0 <script_path_relative_to_scripts_dir> [args...]"
    echo "Example: $0 ec2/manage-instances.sh --action stop --instance-id i-12345"
    exit 1
fi

TARGET_SCRIPT="$SCRIPTS_DIR/$SCRIPT_TO_RUN"

if [ ! -f "$TARGET_SCRIPT" ]; then
    echo "Error: Script not found at $TARGET_SCRIPT"
    exit 1
fi

# --- Execution ---
echo "--- Running Script: $TARGET_SCRIPT ---"

# Execute the target script with its arguments
"$TARGET_SCRIPT" "${SCRIPT_ARGS[@]}"

echo "--- Script execution finished. ---"