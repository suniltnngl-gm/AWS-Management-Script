#!/bin/bash

# @file slack_notify.sh
# @brief Slack integration for AWS alerts
# @requires SLACK_WEBHOOK_URL environment variable

set -euo pipefail

WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
[[ -z "$WEBHOOK_URL" ]] && { echo "Error: SLACK_WEBHOOK_URL not set" >&2; exit 1; }

send_alert() {
    local message="$1"
    local color="${2:-warning}"
    
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"attachments\":[{\"color\":\"$color\",\"text\":\"$message\"}]}" \
        "$WEBHOOK_URL" &>/dev/null
}

# Usage: ./slack_notify.sh "High AWS costs detected: $500"
[[ $# -gt 0 ]] && send_alert "$*"