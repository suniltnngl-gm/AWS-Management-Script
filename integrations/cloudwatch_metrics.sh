#!/bin/bash

# @file cloudwatch_metrics.sh
# @brief CloudWatch metrics integration
# @api aws cloudwatch get-metric-statistics
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

usage() {
    echo "Usage: $0 <instance_id> [--dry-run|--test] [--help|-h]"
    echo "  <instance_id>  EC2 instance ID to fetch CPU metrics"
    echo "  --dry-run, --test  Show what would be done, do not call AWS"
    echo "  --help, -h     Show this help message"
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

get_ec2_cpu() {
    local instance_id="$1"
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws cloudwatch get-metric-statistics for $instance_id"
        return 0
    fi
    aws cloudwatch get-metric-statistics \
        --namespace AWS/EC2 \
        --metric-name CPUUtilization \
        --dimensions Name=InstanceId,Value="$instance_id" \
        --start-time "$(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%S)" \
        --end-time "$(date -u +%Y-%m-%dT%H:%M:%S)" \
        --period 3600 \
        --statistics Average \
        --query 'Datapoints[0].Average' \
        --output text 2>/dev/null || echo "0"
}

get_billing_alert() {
    local threshold="${1:-100}"
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws ce get-cost-and-usage for billing alert threshold $threshold"
        return 0
    fi
    local current_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$(date -d '1 day ago' +%Y-%m-%d)",End="$(date +%Y-%m-%d)" \
        --granularity DAILY \
        --metrics BlendedCost \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")
    (( $(echo "$current_cost > $threshold" | bc -l) )) && echo "ALERT: Cost $current_cost exceeds $threshold"
}

if [[ $# -eq 0 ]]; then
    usage
fi

[[ $# -gt 0 ]] && get_ec2_cpu "$1"