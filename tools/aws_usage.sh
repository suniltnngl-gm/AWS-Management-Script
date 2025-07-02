#!/bin/bash

# @file aws_usage.sh
# @brief AWS Usage Information Script (Legacy)
# @description Basic AWS resource counting - use aws_manager.sh for detailed info
# @version 1.5 (Legacy)
# @deprecated Use aws_manager.sh for enhanced functionality
# @requires aws-cli

set -euo pipefail

# @validation AWS CLI check
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI not installed" >&2
    exit 1
fi

echo "AWS Usage Summary"
echo "================="

# @operation Count EC2 instances
# @api aws ec2 describe-instances
# @query length(Reservations[*].Instances[*])
ec2_count=$(aws ec2 describe-instances --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
echo "EC2 Instances: $ec2_count"

# @operation Count S3 buckets
# @api aws s3api list-buckets
# @query length(Buckets)
s3_count=$(aws s3api list-buckets --query 'length(Buckets)' --output text 2>/dev/null || echo "0")
echo "S3 Buckets: $s3_count"

# @operation Count Lambda functions
# @api aws lambda list-functions
# @query length(Functions)
lambda_count=$(aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo "0")
echo "Lambda Functions: $lambda_count"

# @operation Count SNS topics
# @api aws sns list-topics
# @query length(Topics)
sns_count=$(aws sns list-topics --query 'length(Topics)' --output text 2>/dev/null || echo "0")
echo "SNS Topics: $sns_count"

# @operation Count IAM users
# @api aws iam list-users
# @query length(Users)
iam_count=$(aws iam list-users --query 'length(Users)' --output text 2>/dev/null || echo "0")
echo "IAM Users: $iam_count"

echo
echo "Note: For detailed information, use ./aws_manager.sh"
