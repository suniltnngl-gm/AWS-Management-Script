#!/bin/bash

# @file spend-logic/spend_hub.sh
# @brief Spend Logic Hub - Cost optimization engine
# @description Maximum, minimum, balanced resource utilization with zero-spend focus

set -euo pipefail

source "$(dirname "$0")/../core/config_loader.sh"

# @function get_free_tier_limits
# @brief AWS Free Tier resource limits
get_free_tier_limits() {
    cat << EOF
{
  "ec2": {"hours": 750, "type": "t2.micro"},
  "s3": {"storage_gb": 5, "requests": 20000},
  "lambda": {"requests": 1000000, "compute_seconds": 400000},
  "rds": {"hours": 750, "type": "db.t2.micro"},
  "cloudfront": {"data_transfer_gb": 50},
  "sns": {"requests": 1000000},
  "sqs": {"requests": 1000000}
}
EOF
}

# @function calculate_spend_mode
# @brief Determine optimal spend strategy
# @param $1 budget (0=zero-spend, 1-50=minimal, 50+=balanced)
calculate_spend_mode() {
    local budget=${1:-0}
    
    if (( budget == 0 )); then
        echo "zero-spend"
    elif (( budget <= 50 )); then
        echo "minimal"
    else
        echo "balanced"
    fi
}

# @function optimize_resources
# @brief Resource optimization recommendations
# @param $1 spend_mode (zero-spend|minimal|balanced)
optimize_resources() {
    local mode="$1"
    
    case "$mode" in
        "zero-spend")
            cat << EOF
🎯 ZERO-SPEND OPTIMIZATION
========================
✅ EC2: Use t2.micro (750h free)
✅ S3: Stay under 5GB storage
✅ Lambda: Use for compute (1M requests free)
✅ RDS: t2.micro (750h free) or DynamoDB
✅ CloudFront: 50GB transfer free
❌ Avoid: NAT Gateway, ELB, EBS beyond 30GB
💡 Strategy: Serverless-first, single AZ, free tier only
EOF
            ;;
        "minimal")
            cat << EOF
💰 MINIMAL-SPEND OPTIMIZATION
============================
✅ EC2: t3.micro/small, spot instances
✅ S3: Intelligent tiering, lifecycle policies
✅ Lambda: Primary compute, pay-per-use
✅ RDS: t3.micro or Aurora Serverless v2
✅ CloudWatch: Basic monitoring only
⚠️  Budget alerts at 80% threshold
💡 Strategy: Hybrid serverless, cost monitoring
EOF
            ;;
        "balanced")
            cat << EOF
⚖️  BALANCED OPTIMIZATION
=======================
✅ EC2: Reserved instances, auto-scaling
✅ S3: Multi-tier storage optimization
✅ Lambda: Event-driven architecture
✅ RDS: Multi-AZ for production
✅ CloudWatch: Detailed monitoring
✅ ELB: Application load balancer
💡 Strategy: Performance + cost balance
EOF
            ;;
    esac
}

# @function check_current_spend
# @brief Analyze current resource costs
check_current_spend() {
    local end_date=$(date +%Y-%m-%d)
    local start_date=$(date -d "7 days ago" +%Y-%m-%d)
    
    echo "📊 CURRENT SPEND ANALYSIS (Last 7 days)"
    echo "========================================"
    
    # Get current costs
    local current_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity DAILY \
        --metrics BlendedCost \
        --query 'ResultsByTime[].Total.BlendedCost.Amount' \
        --output text 2>/dev/null | \
        awk '{sum+=$1} END {printf "%.2f", sum}' || echo "0.00")
    
    echo "💸 Weekly spend: \$$current_cost"
    
    # Spend classification
    if (( $(echo "$current_cost == 0" | bc -l 2>/dev/null || echo "1") )); then
        echo "🎉 Status: ZERO-SPEND (Perfect!)"
    elif (( $(echo "$current_cost < 5" | bc -l 2>/dev/null || echo "0") )); then
        echo "✅ Status: MINIMAL-SPEND (Good)"
    else
        echo "⚠️  Status: ACTIVE-SPEND (Review needed)"
    fi
}

# @function generate_recommendations
# @brief Generate cost optimization recommendations
generate_recommendations() {
    local budget=${1:-0}
    local mode=$(calculate_spend_mode "$budget")
    
    echo "🧠 SPEND LOGIC HUB RECOMMENDATIONS"
    echo "=================================="
    echo "Budget: \$$budget | Mode: $mode"
    echo
    
    check_current_spend
    echo
    optimize_resources "$mode"
    echo
    
    # Free tier usage check
    echo "🆓 FREE TIER MONITORING"
    echo "======================"
    get_free_tier_limits | jq -r 'to_entries[] | "✅ \(.key | ascii_upcase): \(.value | tostring)"' 2>/dev/null || \
    echo "Install jq for detailed free tier limits"
}

# Main execution
case "${1:-recommend}" in
    "recommend") generate_recommendations "${2:-0}" ;;
    "check") check_current_spend ;;
    "optimize") optimize_resources "${2:-zero-spend}" ;;
    "limits") get_free_tier_limits ;;
    *) echo "Usage: $0 [recommend <budget>|check|optimize <mode>|limits]" ;;
esac