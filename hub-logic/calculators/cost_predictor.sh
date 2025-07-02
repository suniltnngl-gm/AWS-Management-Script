#!/bin/bash

# @file spend-logic/calculators/cost_predictor.sh
# @brief Cost prediction and budget planning
# @description Predict costs based on resource usage patterns

set -euo pipefail

# @function predict_monthly_cost
# @brief Predict monthly costs based on current usage
predict_monthly_cost() {
    local days_in_month=30
    local current_daily=$(aws ce get-cost-and-usage \
        --time-period Start="$(date -d '1 day ago' +%Y-%m-%d)",End="$(date +%Y-%m-%d)" \
        --granularity DAILY \
        --metrics BlendedCost \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")
    
    local predicted_monthly=$(echo "$current_daily * $days_in_month" | bc -l 2>/dev/null || echo "0")
    
    echo "📈 COST PREDICTION"
    echo "=================="
    echo "Daily cost: \$$(printf '%.2f' "$current_daily")"
    echo "Predicted monthly: \$$(printf '%.2f' "$predicted_monthly")"
    
    # Budget recommendations
    if (( $(echo "$predicted_monthly < 1" | bc -l 2>/dev/null || echo "1") )); then
        echo "✅ Status: Excellent (Free tier usage)"
    elif (( $(echo "$predicted_monthly < 10" | bc -l 2>/dev/null || echo "0") )); then
        echo "✅ Status: Good (Minimal spend)"
    else
        echo "⚠️  Status: Review needed (Active spend)"
    fi
}

# @function calculate_resource_costs
# @brief Calculate costs for specific resources
calculate_resource_costs() {
    echo "💰 RESOURCE COST BREAKDOWN"
    echo "=========================="
    
    # EC2 cost estimation
    local ec2_instances=$(aws ec2 describe-instances \
        --query 'Reservations[*].Instances[?State.Name==`running`].[InstanceType]' \
        --output text | sort | uniq -c)
    
    if [[ -n "$ec2_instances" ]]; then
        echo "EC2 Instances:"
        while read -r count type; do
            local monthly_cost
            case "$type" in
                "t2.micro") monthly_cost="0.00 (Free tier)" ;;
                "t2.small") monthly_cost="16.79" ;;
                "t3.micro") monthly_cost="7.59" ;;
                "t3.small") monthly_cost="15.18" ;;
                *) monthly_cost="Variable" ;;
            esac
            echo "  $count x $type: \$$monthly_cost/month"
        done <<< "$ec2_instances"
    fi
    
    # S3 cost estimation
    local s3_buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text | wc -w)
    echo "S3 Buckets: $s3_buckets (First 5GB free, then \$0.023/GB)"
    
    # Lambda cost estimation
    echo "Lambda: First 1M requests free, then \$0.20/1M requests"
}

# @function budget_optimizer
# @brief Optimize resources for specific budget
# @param $1 target_budget
budget_optimizer() {
    local budget=${1:-0}
    
    echo "🎯 BUDGET OPTIMIZER: \$$budget/month"
    echo "===================================="
    
    if (( budget == 0 )); then
        echo "Strategy: FREE TIER ONLY"
        echo "• 1x t2.micro EC2 (750h free)"
        echo "• 5GB S3 storage"
        echo "• 1M Lambda requests"
        echo "• DynamoDB 25GB"
        echo "• CloudFront 50GB transfer"
    elif (( budget <= 25 )); then
        echo "Strategy: MINIMAL SPEND"
        echo "• 1x t3.micro EC2 (\$7.59/month)"
        echo "• S3 Intelligent Tiering"
        echo "• Lambda-first architecture"
        echo "• DynamoDB on-demand"
        echo "• CloudWatch basic monitoring"
    else
        echo "Strategy: BALANCED SPEND"
        echo "• Reserved instances (up to 75% savings)"
        echo "• Auto-scaling groups"
        echo "• Multi-AZ for critical services"
        echo "• Enhanced monitoring"
        echo "• Load balancers for HA"
    fi
}

case "${1:-predict}" in
    "predict") predict_monthly_cost ;;
    "breakdown") calculate_resource_costs ;;
    "optimize") budget_optimizer "${2:-0}" ;;
    *) echo "Usage: $0 [predict|breakdown|optimize <budget>]" ;;
esac