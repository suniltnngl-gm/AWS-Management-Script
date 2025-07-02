#!/bin/bash

# @file spend-logic/policies/budget_enforcer.sh
# @brief Budget enforcement and automatic cost controls
# @description Automated actions to prevent budget overruns

set -euo pipefail

# @function create_budget_alert
# @brief Create AWS Budget with alerts
# @param $1 budget_amount
create_budget_alert() {
    local budget_amount=${1:-5}
    local budget_name="aws-management-budget"
    
    echo "🚨 CREATING BUDGET ALERT: \$$budget_amount"
    echo "========================================"
    
    # Create budget configuration
    cat > /tmp/budget.json << EOF
{
    "BudgetName": "$budget_name",
    "BudgetLimit": {
        "Amount": "$budget_amount",
        "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostFilters": {}
}
EOF
    
    # Create notification configuration
    cat > /tmp/notification.json << EOF
{
    "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 80,
        "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
        {
            "SubscriptionType": "EMAIL",
            "Address": "${AWS_BUDGET_EMAIL:-admin@example.com}"
        }
    ]
}
EOF
    
    # Create budget (if AWS CLI has permissions)
    if aws budgets create-budget \
        --account-id "$(aws sts get-caller-identity --query Account --output text)" \
        --budget file:///tmp/budget.json \
        --notifications-with-subscribers file:///tmp/notification.json 2>/dev/null; then
        echo "✅ Budget alert created successfully"
    else
        echo "⚠️  Budget creation requires billing permissions"
        echo "💡 Manual setup: AWS Console > Billing > Budgets"
    fi
    
    rm -f /tmp/budget.json /tmp/notification.json
}

# @function emergency_shutdown
# @brief Emergency cost control - shutdown non-essential resources
emergency_shutdown() {
    echo "🚨 EMERGENCY COST CONTROL ACTIVATED"
    echo "==================================="
    
    local shutdown_actions=()
    
    # Stop non-production EC2 instances
    local dev_instances=$(aws ec2 describe-instances \
        --filters "Name=tag:Environment,Values=dev,test,staging" "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text)
    
    if [[ -n "$dev_instances" ]]; then
        echo "Stopping development instances: $dev_instances"
        aws ec2 stop-instances --instance-ids $dev_instances
        shutdown_actions+=("Stopped dev/test EC2 instances")
    fi
    
    # Disable non-essential scheduled tasks
    local rules=$(aws events list-rules --query 'Rules[?State==`ENABLED`].Name' --output text)
    for rule in $rules; do
        if [[ "$rule" =~ (backup|report|cleanup) ]]; then
            aws events disable-rule --name "$rule"
            shutdown_actions+=("Disabled rule: $rule")
        fi
    done
    
    # Report actions taken
    if [[ ${#shutdown_actions[@]} -gt 0 ]]; then
        echo "✅ Emergency actions completed:"
        printf "   • %s\n" "${shutdown_actions[@]}"
    else
        echo "ℹ️  No emergency actions needed"
    fi
}

# @function cost_guard
# @brief Continuous cost monitoring and alerts
cost_guard() {
    local threshold=${1:-5}
    
    echo "🛡️  COST GUARD MONITORING"
    echo "========================"
    
    # Get current month spend
    local start_date=$(date +%Y-%m-01)
    local end_date=$(date +%Y-%m-%d)
    
    local current_spend=$(aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")
    
    echo "Current month spend: \$$current_spend"
    echo "Threshold: \$$threshold"
    
    # Check if threshold exceeded
    if (( $(echo "$current_spend > $threshold" | bc -l 2>/dev/null || echo "0") )); then
        echo "🚨 THRESHOLD EXCEEDED!"
        
        # Send alert if Slack webhook configured
        if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
            ../integrations/slack_notify.sh "🚨 AWS spend alert: \$$current_spend exceeds \$$threshold threshold" "danger"
        fi
        
        # Trigger emergency shutdown if spend is 2x threshold
        if (( $(echo "$current_spend > $threshold * 2" | bc -l 2>/dev/null || echo "0") )); then
            echo "💥 CRITICAL: Spend is 2x threshold - triggering emergency shutdown"
            emergency_shutdown
        fi
        
        return 1
    else
        echo "✅ Spend within threshold"
        return 0
    fi
}

case "${1:-guard}" in
    "alert") create_budget_alert "${2:-5}" ;;
    "shutdown") emergency_shutdown ;;
    "guard") cost_guard "${2:-5}" ;;
    *) echo "Usage: $0 [alert <amount>|shutdown|guard <threshold>]" ;;
esac