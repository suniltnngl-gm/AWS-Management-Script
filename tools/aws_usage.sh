echo "AWS Usage Summary"
echo "================="
ec2_count=$(aws ec2 describe-instances --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
echo "EC2 Instances: $ec2_count"
s3_count=$(aws s3api list-buckets --query 'length(Buckets)' --output text 2>/dev/null || echo "0")
echo "S3 Buckets: $s3_count"
lambda_count=$(aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo "0")
echo "Lambda Functions: $lambda_count"
sns_count=$(aws sns list-topics --query 'length(Topics)' --output text 2>/dev/null || echo "0")
echo "SNS Topics: $sns_count"
iam_count=$(aws iam list-users --query 'length(Users)' --output text 2>/dev/null || echo "0")
echo "IAM Users: $iam_count"
echo
echo "Note: For detailed information, use ./aws_manager.sh"

#!/bin/bash
# @file aws_usage.sh
# @brief AWS Usage Information Script (Legacy)
# @description Basic AWS resource counting - use aws_manager.sh for detailed info
# @version 1.6 (Legacy)
# @deprecated Use aws_manager.sh for enhanced functionality
# @requires aws-cli
# @ai_optimization This script is legacy and not recommended for AI workflows. Use aws_manager.sh for automation, AI, and dry-run/test support.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

usage() {
    echo "Usage: $0 [--help|-h]"
    echo "  Basic AWS resource counting (legacy). Use aws_manager.sh for details."
    echo "  --help, -h     Show this help message"
    exit 0
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

check_aws_cli || exit 1

log_info "AWS Usage Summary"
log_info "================="

ec2_count=$(aws ec2 describe-instances --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
log_info "EC2 Instances: $ec2_count"

s3_count=$(aws s3api list-buckets --query 'length(Buckets)' --output text 2>/dev/null || echo "0")
log_info "S3 Buckets: $s3_count"

lambda_count=$(aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo "0")
log_info "Lambda Functions: $lambda_count"

sns_count=$(aws sns list-topics --query 'length(Topics)' --output text 2>/dev/null || echo "0")
log_info "SNS Topics: $sns_count"

iam_count=$(aws iam list-users --query 'length(Users)' --output text 2>/dev/null || echo "0")
log_info "IAM Users: $iam_count"

echo
log_info "Note: For detailed information, use ./aws_manager.sh"
