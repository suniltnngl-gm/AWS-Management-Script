#!/bin/bash

# @file aws_manager.sh
# @brief AWS Management Script - Unified resource monitoring
# @description Streamlined monitoring and management of AWS services
# @version 2.0
# @author Refactored for AI compatibility
# @requires aws-cli

set -euo pipefail

# @function check_aws_cli
# @brief Validates AWS CLI installation
# @return 1 if AWS CLI not found, 0 otherwise
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI not installed" >&2
        exit 1
    fi
}

# @function format_output
# @brief Formats service output consistently
# @param $1 Service title
# @param $2 Resource count
format_output() {
    local title="$1"
    local count="$2"
    printf "%-20s: %s\n" "$title" "$count"
}

# @function get_ec2_info
# @brief Retrieves EC2 instance information
# @description Fetches instance ID, state, and name tags
get_ec2_info() {
    local instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output text 2>/dev/null || echo "")
    local count=$(echo "$instances" | grep -c . || echo "0")
    
    format_output "EC2 Instances" "$count"
    if [[ $count -gt 0 ]]; then
        echo "$instances" | while read -r id state name; do
            printf "  %-19s %-10s %s\n" "$id" "$state" "${name:-N/A}"
        done
    fi
}

# @function get_s3_info
# @brief Retrieves S3 bucket information
# @description Lists all S3 buckets in the account
get_s3_info() {
    local buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text 2>/dev/null || echo "")
    local count=$(echo "$buckets" | wc -w)
    
    format_output "S3 Buckets" "$count"
    [[ $count -gt 0 ]] && echo "$buckets" | tr '\t' '\n' | sed 's/^/  /'
}

# @function get_lambda_info
# @brief Retrieves Lambda function information
# @description Lists all Lambda functions in the account
get_lambda_info() {
    local functions=$(aws lambda list-functions --query 'Functions[*].FunctionName' --output text 2>/dev/null || echo "")
    local count=$(echo "$functions" | wc -w)
    
    format_output "Lambda Functions" "$count"
    [[ $count -gt 0 ]] && echo "$functions" | tr '\t' '\n' | sed 's/^/  /'
}

# @function get_sns_info
# @brief Retrieves SNS topic information
# @description Lists all SNS topics in the account
get_sns_info() {
    local topics=$(aws sns list-topics --query 'Topics[].TopicArn' --output text 2>/dev/null || echo "")
    local count=$(echo "$topics" | wc -w)
    
    format_output "SNS Topics" "$count"
    [[ $count -gt 0 ]] && echo "$topics" | tr '\t' '\n' | sed 's/.*://; s/^/  /'
}

# @function get_iam_info
# @brief Retrieves IAM user information
# @description Lists all IAM users in the account
get_iam_info() {
    local users=$(aws iam list-users --query 'Users[*].UserName' --output text 2>/dev/null || echo "")
    local count=$(echo "$users" | wc -w)
    
    format_output "IAM Users" "$count"
    [[ $count -gt 0 ]] && echo "$users" | tr '\t' '\n' | sed 's/^/  /'
}

# @function get_billing_info
# @brief Retrieves AWS billing information
# @description Fetches cost data for the last 30 days using Cost Explorer
get_billing_info() {
    local end_date=$(date +%Y-%m-%d)
    local start_date=$(date -d "30 days ago" +%Y-%m-%d)
    
    echo "Billing Information (Last 30 days):"
    aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics "BlendedCost" \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null | \
        awk '{printf "  Total Cost: $%.2f USD\n", $1}' || echo "  Unable to retrieve billing info"
}

# @function main
# @brief Main execution function
# @description Orchestrates all AWS resource checks
main() {
    check_aws_cli
    
    echo "AWS Resource Summary"
    echo "===================="
    
    get_ec2_info
    echo
    get_s3_info
    echo
    get_lambda_info
    echo
    get_sns_info
    echo
    get_iam_info
    echo
    get_billing_info
}

main "$@"