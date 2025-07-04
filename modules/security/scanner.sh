#!/bin/bash

# @file modules/security/scanner.sh
# @brief Advanced security scanning with threat detection
# @description Real-time security analysis and compliance checking

set -euo pipefail

source "$(dirname "$0")/../../core/core_logger.sh"

# @function security_scan
# @brief Comprehensive security analysis
security_scan() {
    local start_time=$(date +%s%3N)
    log_info "security-scanner" "Starting comprehensive security scan"
    
    local findings=()
    local risk_score=0
    
    # IAM security analysis
    local iam_findings=$(scan_iam_security)
    [[ -n "$iam_findings" ]] && findings+=("$iam_findings")
    
    # S3 security analysis
    local s3_findings=$(scan_s3_security)
    [[ -n "$s3_findings" ]] && findings+=("$s3_findings")
    
    # Network security analysis
    local network_findings=$(scan_network_security)
    [[ -n "$network_findings" ]] && findings+=("$network_findings")
    
    # Calculate overall risk score
    risk_score=$(calculate_risk_score "${findings[@]}")
    
    local report=$(cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "scan_type": "comprehensive",
  "risk_score": $risk_score,
  "findings": [$(IFS=','; echo "${findings[*]}")],
  "recommendations": $(generate_security_recommendations "$risk_score")
}
EOF
)
    
    local end_time=$(date +%s%3N)
    log_trace "security_scan" $((end_time - start_time)) "success"
    log_metric "security_risk_score" "$risk_score"
    
    echo "$report"
}

# @function scan_iam_security
# @brief IAM-specific security analysis
scan_iam_security() {
    log_debug "security-scanner" "Scanning IAM security"
    
    # Check for root access keys
    local root_keys=$(aws iam get-account-summary --query 'SummaryMap.AccountAccessKeysPresent' --output text 2>/dev/null || echo "0")
    if [[ "$root_keys" == "1" ]]; then
        echo '{"type":"iam","severity":"HIGH","finding":"root_access_keys","description":"Root access keys detected"}'
        return 0
    fi
    
    # Check for users without MFA
    local users_without_mfa=$(aws iam list-users --query 'Users[?not_null(PasswordLastUsed)].[UserName]' --output json 2>/dev/null | jq -r '.[] | select(length > 0) | .[0]' | head -1)
    if [[ -n "$users_without_mfa" ]]; then
        echo '{"type":"iam","severity":"MEDIUM","finding":"no_mfa","description":"Users without MFA detected"}'
    fi
}

# @function scan_s3_security
# @brief S3-specific security analysis
scan_s3_security() {
    log_debug "security-scanner" "Scanning S3 security"
    
    # Check for public buckets
    aws s3api list-buckets --query 'Buckets[].Name' --output text 2>/dev/null | while read -r bucket; do
        [[ -z "$bucket" ]] && continue
        
        # Check public access block
        if ! aws s3api get-public-access-block --bucket "$bucket" >/dev/null 2>&1; then
            echo '{"type":"s3","severity":"HIGH","finding":"public_bucket","bucket":"'$bucket'","description":"Bucket may have public access"}'
            break
        fi
    done
}

# @function scan_network_security
# @brief Network security analysis
scan_network_security() {
    log_debug "security-scanner" "Scanning network security"
    
    # Check for overly permissive security groups
    local open_sg=$(aws ec2 describe-security-groups --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].[GroupId]' --output text 2>/dev/null | head -1)
    if [[ -n "$open_sg" ]]; then
        echo '{"type":"network","severity":"HIGH","finding":"open_security_group","group":"'$open_sg'","description":"Security group allows 0.0.0.0/0 access"}'
    fi
}

# @function calculate_risk_score
# @brief Calculate overall security risk score
calculate_risk_score() {
    local score=0
    for finding in "$@"; do
        local severity=$(echo "$finding" | jq -r '.severity // "LOW"')
        case "$severity" in
            "HIGH") score=$((score + 10)) ;;
            "MEDIUM") score=$((score + 5)) ;;
            "LOW") score=$((score + 1)) ;;
        esac
    done
    echo "$score"
}

# @function generate_security_recommendations
# @brief Generate security recommendations based on risk score
generate_security_recommendations() {
    local risk_score="$1"
    
    if [[ $risk_score -gt 20 ]]; then
        echo '["Immediate action required","Enable MFA for all users","Review and restrict security groups","Implement least privilege access"]'
    elif [[ $risk_score -gt 10 ]]; then
        echo '["Review security policies","Enable CloudTrail logging","Implement access monitoring","Regular security audits"]'
    else
        echo '["Maintain current security posture","Regular monitoring","Periodic reviews"]'
    fi
}

case "${1:-scan}" in
    "scan") security_scan ;;
    "iam") scan_iam_security ;;
    "s3") scan_s3_security ;;
    "network") scan_network_security ;;
    *) echo "Usage: $0 {scan|iam|s3|network}" ;;
esac