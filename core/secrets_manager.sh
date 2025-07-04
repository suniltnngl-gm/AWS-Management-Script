#!/bin/bash

# @file core/secrets_manager.sh
# @brief GitHub Secrets integration for cost-effective key management
# @description Use GitHub Secrets instead of AWS KMS to avoid costs

set -euo pipefail

source "$(dirname "$0")/core_logger.sh"

# @function get_github_secret
# @brief Retrieve secret from GitHub environment
get_github_secret() {
    local secret_name="$1"
    local default_value="${2:-}"
    
    # GitHub Actions environment variables
    case "$secret_name" in
        "AWS_ACCESS_KEY_ID") echo "${AWS_ACCESS_KEY_ID:-$default_value}" ;;
        "AWS_SECRET_ACCESS_KEY") echo "${AWS_SECRET_ACCESS_KEY:-$default_value}" ;;
        "AWS_DEFAULT_REGION") echo "${AWS_DEFAULT_REGION:-us-east-1}" ;;
        "SLACK_WEBHOOK") echo "${SLACK_WEBHOOK_URL:-$default_value}" ;;
        "EMAIL_ALERTS") echo "${EMAIL_ALERTS_TO:-$default_value}" ;;
        *) 
            log_warn "secrets" "Unknown secret: $secret_name"
            echo "$default_value"
            ;;
    esac
}

# @function validate_secrets
# @brief Validate required secrets are available
validate_secrets() {
    local required_secrets=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")
    local missing_secrets=()
    
    for secret in "${required_secrets[@]}"; do
        if [[ -z "$(get_github_secret "$secret")" ]]; then
            missing_secrets+=("$secret")
        fi
    done
    
    if [[ ${#missing_secrets[@]} -gt 0 ]]; then
        log_error "secrets" "Missing required secrets: ${missing_secrets[*]}"
        return 1
    fi
    
    log_info "secrets" "All required secrets validated"
    return 0
}

# @function setup_aws_credentials
# @brief Configure AWS CLI with GitHub secrets
setup_aws_credentials() {
    local access_key=$(get_github_secret "AWS_ACCESS_KEY_ID")
    local secret_key=$(get_github_secret "AWS_SECRET_ACCESS_KEY")
    local region=$(get_github_secret "AWS_DEFAULT_REGION")
    
    if [[ -n "$access_key" && -n "$secret_key" ]]; then
        export AWS_ACCESS_KEY_ID="$access_key"
        export AWS_SECRET_ACCESS_KEY="$secret_key"
        export AWS_DEFAULT_REGION="$region"
        
        log_info "secrets" "AWS credentials configured from GitHub secrets"
        return 0
    else
        log_error "secrets" "AWS credentials not available in GitHub secrets"
        return 1
    fi
}

case "${1:-help}" in
    "get") get_github_secret "$2" "${3:-}" ;;
    "validate") validate_secrets ;;
    "setup-aws") setup_aws_credentials ;;
    *) echo "Usage: $0 {get|validate|setup-aws} [args...]" ;;
esac