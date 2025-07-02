#!/bin/bash

# @file cloudwatch_metrics.sh
# @brief CloudWatch metrics integration
# @api aws cloudwatch get-metric-statistics

set -euo pipefail

get_ec2_cpu() {
    local instance_id="$1"
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
    local current_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$(date -d '1 day ago' +%Y-%m-%d)",End="$(date +%Y-%m-%d)" \
        --granularity DAILY \
        --metrics BlendedCost \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")
    
    (( $(echo "$current_cost > $threshold" | bc -l) )) && echo "ALERT: Cost $current_cost exceeds $threshold"
}

# Usage: ./cloudwatch_metrics.sh i-1234567890abcdef0
[[ $# -gt 0 ]] && get_ec2_cpu "$1"