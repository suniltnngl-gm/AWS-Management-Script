#!/bin/bash

# @file cloudfront_audit.sh
# @brief CloudFront Security Audit Script
# @description Performs comprehensive security checks on CloudFront distributions
# @version 2.0
# @requires aws-cli with CloudFront permissions
# @security_checks WAF integration, logging, SSL protocols, HTTP-only origins

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

# @function audit_distribution
# @brief Performs security audit on a single CloudFront distribution
# @param $1 CloudFront distribution ID
# @checks WAF, logging, SSL protocols, HTTP-only origins
audit_distribution() {
    local cdn_id="$1"
    local issues=()
    
    echo "Auditing Distribution: $cdn_id"
    echo "$(printf '=%.0s' {1..40})"
    
    # @check WAF integration status
    # @api aws cloudfront get-distribution
    # @query Distribution.DistributionConfig.WebACLId
    local waf_id=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.WebACLId' --output text 2>/dev/null)
    [[ "$waf_id" == "None" || -z "$waf_id" ]] && issues+=("No WAF integration")
    
    # @check Logging configuration
    # @query Distribution.DistributionConfig.Logging.Enabled
    local logging=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.Logging.Enabled' --output text 2>/dev/null)
    [[ "$logging" != "True" ]] && issues+=("Logging disabled")
    
    # @check SSL protocol versions
    # @security Detects deprecated SSLv2/SSLv3 protocols
    # @query Distribution.DistributionConfig.Origins.Items[].CustomOriginConfig.OriginSslProtocols.Items[]
    local ssl_check=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.Origins.Items[].CustomOriginConfig.OriginSslProtocols.Items[]' \
        --output text 2>/dev/null | grep -E "SSLv[23]" || true)
    [[ -n "$ssl_check" ]] && issues+=("Deprecated SSL version")
    
    # @check HTTP-only origin policy
    # @security Detects insecure HTTP-only origins
    # @query Distribution.DistributionConfig.Origins.Items[].CustomOriginConfig.OriginProtocolPolicy
    local http_check=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.Origins.Items[].CustomOriginConfig.OriginProtocolPolicy' \
        --output text 2>/dev/null | grep "http-only" || true)
    [[ -n "$http_check" ]] && issues+=("HTTP-only origin")
    
    # @output Security audit results
    # @format Visual indicators with issue list
    if [[ ${#issues[@]} -eq 0 ]]; then
        echo "✓ No security issues found"
    else
        echo "⚠ Security issues found:"
        printf "  • %s\n" "${issues[@]}"
    fi
    echo
}

# @function main
# @brief Main execution function
# @description Lists all CloudFront distributions and audits each one
main() {
    check_aws_cli
    
    echo "CloudFront Security Audit"
    echo "========================="
    echo
    
    # @operation List all CloudFront distributions
    # @api aws cloudfront list-distributions
    # @query DistributionList.Items[].Id
    local distributions=$(aws cloudfront list-distributions \
        --query 'DistributionList.Items[].Id' --output text 2>/dev/null || echo "")
    
    if [[ -z "$distributions" ]]; then
        echo "No CloudFront distributions found"
        exit 0
    fi
    
    # @loop Audit each distribution
    for cdn in $distributions; do
        audit_distribution "$cdn"
    done
}

main "$@"
