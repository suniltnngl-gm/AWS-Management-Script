












#!/bin/bash
# @file billing.sh
# @brief AWS Billing Information Script
# @description Retrieves cost and usage data from AWS Cost Explorer
# @version 2.2
# @requires aws-cli with Cost Explorer permissions
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Usage/help function
usage() {
    echo "Usage: $0 [--dry-run|--test] [--help|-h]"
    echo "  Retrieves AWS billing information for the last 30 days."
    echo "  --dry-run, --test  Show what would be done, do not call AWS"
    echo "  --help, -h     Show this help message"
    exit 0
}

DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --dry-run|--test)
            DRY_RUN=true;;
        --help|-h)
            usage;;
    esac
done

check_aws_cli || exit 1

get_billing_info() {
    local end_date=$(date +%Y-%m-%d)
    local start_date=$(date -d "30 days ago" +%Y-%m-%d)

    log_info "AWS Billing Information (Last 30 days)"
    log_info "======================================"

    if $DRY_RUN; then
        log_info "[DRY RUN] Would call: aws ce get-cost-and-usage ... for total cost and service breakdown."
        return 0
    fi

    local total_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics "BlendedCost" \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")

    printf "Total Cost: $%.2f USD\n\n" "$total_cost"

    log_info "Costs by Service:"
    aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics "BlendedCost" \
        --group-by Type=DIMENSION,Key=SERVICE \
        --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' \
        --output text 2>/dev/null | \
        sort -k2 -nr | \
        awk '{printf "  %-30s: $%.2f\n", $1, $2}' || log_error "Unable to retrieve service costs"
}

get_billing_info
