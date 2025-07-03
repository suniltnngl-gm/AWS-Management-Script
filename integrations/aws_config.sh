#!/bin/bash

# @file aws_config.sh
# @brief AWS Config integration for compliance
# @api aws configservice
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

usage() {
    echo "Usage: $0 [summary|rules|check <rule_name>|--dry-run|--test|--help|-h]"
    echo "  summary      Show compliance summary"
    echo "  rules        List config rules"
    echo "  check <rule_name>  Check compliance for a rule"
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

get_compliance_summary() {
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws configservice get-compliance-summary-by-config-rule"
        return 0
    fi
    aws configservice get-compliance-summary-by-config-rule \
        --query 'ComplianceSummary.{Compliant:ComplianceByConfigRule.COMPLIANT,NonCompliant:ComplianceByConfigRule.NON_COMPLIANT}' \
        --output table 2>/dev/null || echo "AWS Config not enabled"
}

check_rule_compliance() {
    local rule_name="$1"
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws configservice get-compliance-details-by-config-rule for $rule_name"
        return 0
    fi
    aws configservice get-compliance-details-by-config-rule \
        --config-rule-name "$rule_name" \
        --query 'EvaluationResults[?ComplianceType==`NON_COMPLIANT`].EvaluationResultIdentifier.EvaluationResultQualifier.ResourceId' \
        --output text 2>/dev/null || echo "Rule not found: $rule_name"
}

list_config_rules() {
    if $DRY_RUN; then
        echo "[DRY RUN] Would call: aws configservice describe-config-rules"
        return 0
    fi
    aws configservice describe-config-rules \
        --query 'ConfigRules[].ConfigRuleName' \
        --output text 2>/dev/null || echo "No Config rules found"
}

case "${1:-summary}" in
    "summary") get_compliance_summary ;;
    "rules") list_config_rules ;;
    "check") check_rule_compliance "$2" ;;
    *) usage ;;
esac