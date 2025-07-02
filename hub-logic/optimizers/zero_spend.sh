#!/bin/bash

# @file spend-logic/optimizers/zero_spend.sh
# @brief Zero-spend optimizer - Free tier maximization
# @description Ensures AWS usage stays within free tier limits

set -euo pipefail

# @function check_free_tier_usage
# @brief Monitor free tier resource consumption
check_free_tier_usage() {
    echo "🆓 FREE TIER USAGE CHECK"
    echo "======================="
    
    # EC2 usage (750 hours/month)
    local ec2_hours=$(aws ec2 describe-instances \
        --query 'Reservations[*].Instances[?InstanceType==`t2.micro` && State.Name==`running`].LaunchTime' \
        --output text | wc -l)
    echo "EC2 t2.micro running: $ec2_hours/1 (750h monthly limit)"
    
    # S3 storage check
    local s3_size=$(aws s3 ls --recursive s3:// 2>/dev/null | \
        awk '{sum+=$3} END {printf "%.2f", sum/1024/1024/1024}' || echo "0")
    echo "S3 storage: ${s3_size}GB/5GB free tier limit"
    
    # Lambda invocations (approximate)
    echo "Lambda: Monitor via CloudWatch (1M requests/month free)"
}

# @function enforce_zero_spend
# @brief Prevent cost-incurring resources
enforce_zero_spend() {
    echo "🚫 ZERO-SPEND ENFORCEMENT"
    echo "========================"
    
    # Check for cost-incurring resources
    local violations=()
    
    # NAT Gateway check
    local nat_gateways=$(aws ec2 describe-nat-gateways \
        --query 'NatGateways[?State==`available`].NatGatewayId' \
        --output text | wc -w)
    [[ $nat_gateways -gt 0 ]] && violations+=("NAT Gateway ($nat_gateways active)")
    
    # ELB check
    local elbs=$(aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[].LoadBalancerArn' \
        --output text | wc -w)
    [[ $elbs -gt 0 ]] && violations+=("Load Balancer ($elbs active)")
    
    # Large EC2 instances
    local large_instances=$(aws ec2 describe-instances \
        --query 'Reservations[*].Instances[?InstanceType!=`t2.micro` && State.Name==`running`].InstanceType' \
        --output text | wc -w)
    [[ $large_instances -gt 0 ]] && violations+=("Non-free tier EC2 ($large_instances instances)")
    
    if [[ ${#violations[@]} -gt 0 ]]; then
        echo "❌ COST VIOLATIONS DETECTED:"
        printf "   • %s\n" "${violations[@]}"
        echo "💡 Action: Terminate or downsize these resources"
        return 1
    else
        echo "✅ No cost violations detected"
        return 0
    fi
}

# @function optimize_for_free_tier
# @brief Optimize architecture for free tier
optimize_for_free_tier() {
    echo "🎯 FREE TIER OPTIMIZATION"
    echo "========================"
    
    cat << EOF
SERVERLESS-FIRST ARCHITECTURE:
• API Gateway + Lambda (no servers)
• DynamoDB (25GB free)
• S3 static hosting (5GB free)
• CloudFront (50GB transfer)
• SES (62k emails/month)

COMPUTE STRATEGY:
• Single t2.micro EC2 (if needed)
• Lambda for all processing
• Avoid always-on services

STORAGE STRATEGY:
• S3 Standard (5GB free)
• DynamoDB (25GB + 25 WCU/RCU)
• Avoid EBS beyond 30GB free

NETWORKING:
• Single AZ deployment
• No NAT Gateway (use NAT Instance)
• Public subnets only
EOF
}

case "${1:-check}" in
    "check") check_free_tier_usage ;;
    "enforce") enforce_zero_spend ;;
    "optimize") optimize_for_free_tier ;;
    *) echo "Usage: $0 [check|enforce|optimize]" ;;
esac