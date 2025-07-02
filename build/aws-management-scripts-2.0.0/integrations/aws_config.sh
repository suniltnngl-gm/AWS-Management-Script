#!/bin/bash

# @file aws_config.sh
# @brief AWS Config integration for compliance
# @api aws configservice

set -euo pipefail

get_compliance_summary() {
    aws configservice get-compliance-summary-by-config-rule \
        --query 'ComplianceSummary.{Compliant:ComplianceByConfigRule.COMPLIANT,NonCompliant:ComplianceByConfigRule.NON_COMPLIANT}' \
        --output table 2>/dev/null || echo "AWS Config not enabled"
}

check_rule_compliance() {
    local rule_name="$1"
    aws configservice get-compliance-details-by-config-rule \
        --config-rule-name "$rule_name" \
        --query 'EvaluationResults[?ComplianceType==`NON_COMPLIANT`].EvaluationResultIdentifier.EvaluationResultQualifier.ResourceId' \
        --output text 2>/dev/null || echo "Rule not found: $rule_name"
}

list_config_rules() {
    aws configservice describe-config-rules \
        --query 'ConfigRules[].ConfigRuleName' \
        --output text 2>/dev/null || echo "No Config rules found"
}

case "${1:-summary}" in
    "summary") get_compliance_summary ;;
    "rules") list_config_rules ;;
    "check") check_rule_compliance "$2" ;;
    *) echo "Usage: $0 [summary|rules|check <rule_name>]" ;;
esac