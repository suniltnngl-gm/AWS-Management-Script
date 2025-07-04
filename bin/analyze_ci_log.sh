#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enhanced logging
source "$SCRIPT_DIR/../lib/log_utils.sh" 2>/dev/null || true

# analyze_ci_log.sh: Analyzes structured JSON logs from the CI process.
# Requires `jq` to be installed.

LOG_FILE="${CI_LOG_FILE:-ci.log}"

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. This script requires jq for log analysis."
    echo "Please install jq to continue."
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found at '$LOG_FILE'"
    exit 1
fi

echo "--- Analyzing Log File: $LOG_FILE ---"

# Filter out only valid JSON lines for analysis
JSON_LOGS=$(grep '^{' "$LOG_FILE")

ERROR_COUNT=$(echo "$JSON_LOGS" | jq -s 'map(select(.level=="ERROR")) | length')
WARN_COUNT=$(echo "$JSON_LOGS" | jq -s 'map(select(.level=="WARN")) | length')

echo
echo "--- Summary ---"
echo "Errors:   $ERROR_COUNT"
echo "Warnings: $WARN_COUNT"
echo "---------------"
echo

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "Displaying error details:"
    echo "$JSON_LOGS" | jq 'select(.level=="ERROR")'
    echo
    echo "Analysis finished with errors."
fi

echo "Analysis complete."
