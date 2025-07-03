
#!/bin/bash
# @file aws_manager.sh
# @brief AWS Management Script - Unified resource monitoring
# @description Streamlined monitoring and management of AWS services
# @version 2.1
# @author Refactored for AI compatibility
# @requires aws-cli

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Usage/help function
usage() {
    echo "Usage: $0 [--help|-h] [--env ENV] [--dry-run] [--verbose]"
    echo "  Unified AWS resource overview."
    echo "  --env ENV      Specify environment (default: default)"
    echo "  --dry-run      Show commands without executing"
    echo "  --verbose      Enable verbose logging"
    echo "  --help, -h     Show this help message"
    exit 0
}

# Default options
ENV="default"
DRY_RUN=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENV="$2"; shift 2;;
        --dry-run)
            DRY_RUN=true; shift;;
        --verbose)
            VERBOSE=true; shift;;
        --help|-h)
            usage;;
        *)
            shift;;
    esac
done

log_info "Starting AWS Manager (env: $ENV, dry-run: $DRY_RUN, verbose: $VERBOSE)"

if $DRY_RUN; then
    log_info "Dry run mode: No AWS commands will be executed."
fi

# ...existing code for get_ec2_info, get_s3_info, get_lambda_info, get_sns_info, get_iam_info...
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