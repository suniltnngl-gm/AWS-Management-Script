#!/bin/bash

# @file billing.sh
# @brief AWS Billing Information Script
# @description Retrieves cost and usage data from AWS Cost Explorer
# @version 2.0
# @requires aws-cli with Cost Explorer permissions

set -euo pipefail

# @function check_aws_cli
# @brief Validates AWS CLI installation
# @return 1 if AWS CLI not found
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI not installed" >&2
        exit 1
    fi
}

# @function get_billing_info
# @brief Retrieves AWS billing information for the last 30 days
# @description Fetches total cost and service-wise breakdown using Cost Explorer API
get_billing_info() {
    # @var end_date Current date in YYYY-MM-DD format
    # @var start_date Date 30 days ago in YYYY-MM-DD format
    local end_date=$(date +%Y-%m-%d)
    local start_date=$(date -d "30 days ago" +%Y-%m-%d)
    
    echo "AWS Billing Information (Last 30 days)"
    echo "======================================"
    
    # @operation Get total cost using Cost Explorer
    # @api aws ce get-cost-and-usage
    # @metric BlendedCost
    local total_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics "BlendedCost" \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")
    
    printf "Total Cost: $%.2f USD\n\n" "$total_cost"
    
    # @operation Get costs by service
    # @groupby SERVICE dimension
    # @sort Descending by cost amount
    echo "Costs by Service:"
    aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics "BlendedCost" \
        --group-by Type=DIMENSION,Key=SERVICE \
        --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' \
        --output text 2>/dev/null | \
        sort -k2 -nr | \
        awk '{printf "  %-30s: $%.2f\n", $1, $2}' || echo "  Unable to retrieve service costs"
}

# @main Main execution
check_aws_cli
get_billing_info
