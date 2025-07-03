

#!/bin/bash
# @file slack_notify.sh
# @brief Slack integration for AWS alerts
# @requires SLACK_WEBHOOK_URL environment variable
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary Slack API calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../tools/utils.sh"


usage() {
    echo "Usage: $0 [message] [color] [--dry-run|--test] [--help|-h]"
    echo "  message      Message to send to Slack"
    echo "  color        Message color (default: warning)"
    echo "  --dry-run, --test  Show what would be sent, do not call Slack API"
    echo "  --help, -h   Show this help message"
    exit 0
}

DRY_RUN=false
ARGS=()
for arg in "$@"; do
    case $arg in
        --dry-run|--test)
            DRY_RUN=true;;
        --help|-h)
            usage;;
        *)
            ARGS+=("$arg");;
    esac
done
set -- "${ARGS[@]}"

WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
[[ -z "$WEBHOOK_URL" ]] && { echo "Error: SLACK_WEBHOOK_URL not set" >&2; exit 1; }

send_alert() {
    local message="$1"
    local color="${2:-warning}"
    if $DRY_RUN; then
        echo "[DRY RUN] Would send Slack message: '$message' with color '$color'"
        return 0
    fi
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"attachments\":[{\"color\":\"$color\",\"text\":\"$message\"}]}" \
        "$WEBHOOK_URL" &>/dev/null
}

# Usage: ./slack_notify.sh "High AWS costs detected: $500"
[[ $# -gt 0 ]] && send_alert "$*"