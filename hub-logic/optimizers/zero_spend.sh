

#!/bin/bash
# @file spend-logic/optimizers/zero_spend.sh
# @brief Zero-spend optimizer - Free tier maximization
# @description Ensures AWS usage stays within free tier limits
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/log_utils.sh"
source "$SCRIPT_DIR/../../../lib/aws_utils.sh"


usage() {
    echo "Usage: $0 [check|enforce|optimize|--dry-run|--test|--help|-h]"
    echo "  check        Check free tier usage"
    echo "  enforce      Enforce zero-spend policy"
    echo "  optimize     Optimize for free tier"
    echo "  --dry-run, --test  Show what would be done, do not call AWS"
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

# @function check_free_tier_usage
# @brief Monitor free tier resource consumption

check_free_tier_usage() {
    echo "🆓 FREE TIER USAGE CHECK"
    echo "======================="
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws ec2 describe-instances, aws s3 ls, etc. for free tier usage check."
        return 0
    fi
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
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws ec2 describe-nat-gateways, elbv2, etc. for zero-spend enforcement."
        return 0
    fi
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
    if $DRY_RUN; then
        echo "[DRY RUN] Would generate free tier optimization strategy."
        return 0
    fi
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


case "${ARGS[0]:-check}" in
    "check") check_free_tier_usage ;;
    "enforce") enforce_zero_spend ;;
    "optimize") optimize_for_free_tier ;;
    *) usage ;;
esac
