

#!/bin/bash
# @file cost_anomaly.sh
# @brief Cost Anomaly Detection integration
# @api aws ce get-anomalies
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../tools/utils.sh"


usage() {
    echo "Usage: $0 [monitor|list [days]|--dry-run|--test|--help|-h]"
    echo "  monitor      Monitor and alert on cost anomalies"
    echo "  list [days]  List cost anomalies for the past N days (default: 7)"
    echo "  --dry-run, --test  Show what would be done, do not call AWS/Slack"
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


get_cost_anomalies() {
    local days="${1:-7}"
    local start_date=$(date -d "$days days ago" +%Y-%m-%d)
    local end_date=$(date +%Y-%m-%d)
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws ce get-anomalies for $days days"
        return 0
    fi
    aws ce get-anomalies \
        --date-interval Start="$start_date",End="$end_date" \
        --query 'Anomalies[?Impact.MaxImpact>`10`].[AnomalyId,Impact.MaxImpact,RootCauses[0].Service]' \
        --output table 2>/dev/null || echo "No significant anomalies found"
}

monitor_and_alert() {
    if $DRY_RUN; then
        echo "[DRY RUN] Would monitor and alert on cost anomalies, and send Slack alert if needed."
        return 0
    fi
    local anomalies=$(get_cost_anomalies)
    if [[ "$anomalies" != "No significant anomalies found" ]]; then
        echo "$anomalies"
        # Send Slack alert if webhook configured
        if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
            ./slack_notify.sh "Cost anomalies detected in AWS account" "danger"
        fi
    fi
}

case "${1:-monitor}" in
    "monitor") monitor_and_alert ;;
    "list") get_cost_anomalies "${2:-7}" ;;
    *) echo "Usage: $0 [monitor|list [days]]" ;;
esac