#!/bin/bash

# @file cost_anomaly.sh
# @brief Cost Anomaly Detection integration
# @api aws ce get-anomalies

set -euo pipefail

get_cost_anomalies() {
    local days="${1:-7}"
    local start_date=$(date -d "$days days ago" +%Y-%m-%d)
    local end_date=$(date +%Y-%m-%d)
    
    aws ce get-anomalies \
        --date-interval Start="$start_date",End="$end_date" \
        --query 'Anomalies[?Impact.MaxImpact>`10`].[AnomalyId,Impact.MaxImpact,RootCauses[0].Service]' \
        --output table 2>/dev/null || echo "No significant anomalies found"
}

monitor_and_alert() {
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