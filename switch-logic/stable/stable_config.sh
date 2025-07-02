#!/bin/bash

# @file switch-logic/stable/stable_config.sh
# @brief Stable mode configuration and validation
# @description Production-ready settings and conservative operations

set -euo pipefail

# @function apply_stable_settings
# @brief Apply conservative stable settings
apply_stable_settings() {
    echo "🟢 APPLYING STABLE SETTINGS"
    echo "=========================="
    
    # Conservative AWS CLI settings
    export AWS_CLI_READ_TIMEOUT=30
    export AWS_CLI_MAX_ATTEMPTS=3
    export AWS_RETRY_MODE=standard
    
    # Stable feature flags
    export ENABLE_EXPERIMENTAL_FEATURES=false
    export ENABLE_DEBUG_LOGGING=false
    export ENABLE_BETA_INTEGRATIONS=false
    
    # Safe operation limits
    export MAX_CONCURRENT_OPERATIONS=2
    export OPERATION_TIMEOUT=60
    export SAFETY_CHECKS_ENABLED=true
    
    echo "✅ Conservative timeouts set"
    echo "✅ Safety checks enabled"
    echo "✅ Experimental features disabled"
}

# @function validate_stable_environment
# @brief Validate environment for stable operations
validate_stable_environment() {
    echo "🔍 STABLE ENVIRONMENT VALIDATION"
    echo "==============================="
    
    local validation_errors=()
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        validation_errors+=("AWS credentials not configured")
    fi
    
    # Check required commands
    local required_commands=("aws" "jq" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            validation_errors+=("Required command missing: $cmd")
        fi
    done
    
    # Check disk space
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1000000 ]]; then  # Less than 1GB
        validation_errors+=("Low disk space: ${available_space}KB available")
    fi
    
    # Report validation results
    if [[ ${#validation_errors[@]} -eq 0 ]]; then
        echo "✅ Environment validation passed"
        return 0
    else
        echo "❌ Environment validation failed:"
        printf "   • %s\n" "${validation_errors[@]}"
        return 1
    fi
}

# @function stable_feature_list
# @brief List features available in stable mode
stable_feature_list() {
    echo "🟢 STABLE MODE FEATURES"
    echo "======================"
    
    cat << EOF
CORE FEATURES (Always Available):
✅ AWS Resource Overview
✅ MFA Authentication
✅ Billing Analysis
✅ Basic CloudFront Audit
✅ Configuration Management
✅ State Management

INTEGRATIONS (Stable Only):
✅ Slack Notifications (Basic)
✅ Cost Monitoring
✅ Hub Logic (Cost Optimization)
✅ Router Logic (Basic Routing)

DISABLED IN STABLE MODE:
❌ Experimental Integrations
❌ Beta Features
❌ Advanced Routing
❌ Debug Mode
❌ Untested Configurations
EOF
}

# @function safe_execution_wrapper
# @brief Wrapper for safe command execution
# @param $1 command to execute
safe_execution_wrapper() {
    local command="$1"
    local max_retries=3
    local retry_count=0
    
    echo "🛡️  Safe execution: $command"
    
    while [[ $retry_count -lt $max_retries ]]; do
        if timeout 30 bash -c "$command" 2>/dev/null; then
            echo "✅ Command executed successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            echo "⚠️  Attempt $retry_count failed, retrying..."
            sleep 2
        fi
    done
    
    echo "❌ Command failed after $max_retries attempts"
    return 1
}

# @function stable_health_check
# @brief Health check for stable mode operations
stable_health_check() {
    echo "🏥 STABLE MODE HEALTH CHECK"
    echo "=========================="
    
    local health_score=0
    local max_score=100
    
    # AWS connectivity (25 points)
    if aws sts get-caller-identity >/dev/null 2>&1; then
        health_score=$((health_score + 25))
        echo "✅ AWS connectivity: +25 points"
    else
        echo "❌ AWS connectivity failed"
    fi
    
    # Core scripts availability (25 points)
    local core_scripts=("aws_manager.sh" "billing.sh" "aws_mfa.sh")
    local available_scripts=0
    for script in "${core_scripts[@]}"; do
        if [[ -x "../$script" ]]; then
            available_scripts=$((available_scripts + 1))
        fi
    done
    
    if [[ $available_scripts -eq ${#core_scripts[@]} ]]; then
        health_score=$((health_score + 25))
        echo "✅ Core scripts available: +25 points"
    else
        echo "⚠️  Some core scripts missing: $available_scripts/${#core_scripts[@]}"
    fi
    
    # Configuration validity (25 points)
    if [[ -f "../config/settings.conf" ]]; then
        health_score=$((health_score + 25))
        echo "✅ Configuration valid: +25 points"
    fi
    
    # State management (25 points)
    if [[ -d "$HOME/.aws_management_state" ]]; then
        health_score=$((health_score + 25))
        echo "✅ State management active: +25 points"
    fi
    
    echo "Stable Mode Health Score: $health_score/$max_score"
    
    if [[ $health_score -ge 75 ]]; then
        echo "🟢 Status: HEALTHY"
        return 0
    else
        echo "🟡 Status: DEGRADED"
        return 1
    fi
}

case "${1:-apply}" in
    "apply") apply_stable_settings ;;
    "validate") validate_stable_environment ;;
    "features") stable_feature_list ;;
    "exec") safe_execution_wrapper "${2:-echo 'test'}" ;;
    "health") stable_health_check ;;
    *) echo "Usage: $0 [apply|validate|features|exec <command>|health]" ;;
esac