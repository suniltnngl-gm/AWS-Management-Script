












#!/bin/bash
# @file cloudfront_audit.sh
# @brief CloudFront Security Audit Script
# @description Performs comprehensive security checks on CloudFront distributions
# @version 2.2
# @requires aws-cli with CloudFront permissions
# @security_checks WAF integration, logging, SSL protocols, HTTP-only origins
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

usage() {
    echo "Usage: $0 [--dry-run|--test] [--help|-h]"
    echo "  Performs security audit on all CloudFront distributions."
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

audit_distribution() {
    local cdn_id="$1"
    local issues=()
    log_info "Auditing Distribution: $cdn_id"
    log_info "$(printf '=%.0s' {1..40})"

    if $DRY_RUN; then
        log_info "[DRY RUN] Would audit distribution $cdn_id (WAF, logging, SSL, HTTP-only checks)"
        return 0
    fi

    local waf_id=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.WebACLId' --output text 2>/dev/null)
    [[ "$waf_id" == "None" || -z "$waf_id" ]] && issues+=("No WAF integration")

    local logging=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.Logging.Enabled' --output text 2>/dev/null)
    [[ "$logging" != "True" ]] && issues+=("Logging disabled")

    local ssl_check=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.Origins.Items[].CustomOriginConfig.OriginSslProtocols.Items[]' \
        --output text 2>/dev/null | grep -E "SSLv[23]" || true)
    [[ -n "$ssl_check" ]] && issues+=("Deprecated SSL version")

    local http_check=$(aws cloudfront get-distribution --id "$cdn_id" \
        --query 'Distribution.DistributionConfig.Origins.Items[].CustomOriginConfig.OriginProtocolPolicy' \
        --output text 2>/dev/null | grep "http-only" || true)
    [[ -n "$http_check" ]] && issues+=("HTTP-only origin")

    if [[ ${#issues[@]} -eq 0 ]]; then
        log_info "\u2713 No security issues found"
    else
        log_error "\u26a0 Security issues found:"
        printf "  \u2022 %s\n" "${issues[@]}"
    fi
    echo
}

main() {
    log_info "CloudFront Security Audit"
    log_info "========================="

    if $DRY_RUN; then
        log_info "[DRY RUN] Would list all CloudFront distributions and audit each."
        return 0
    fi

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
