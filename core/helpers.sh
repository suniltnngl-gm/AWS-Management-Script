#!/bin/bash

# @file core/helpers.sh
# @brief Core helper functions for automation
# @description Shared utilities for client automation

set -euo pipefail

# Load configuration and state management
source "$(dirname "$0")/config_loader.sh"
source "$(dirname "$0")/state_manager.sh"

# @function prompt_user
# @brief Interactive user prompts with validation
# @param $1 prompt message
# @param $2 default value (optional)
prompt_user() {
    local message="$1"
    local default="${2:-}"
    local input
    
    if [[ -n "$default" ]]; then
        read -p "$message [$default]: " input
        echo "${input:-$default}"
    else
        read -p "$message: " input
        echo "$input"
    fi
}

# @function confirm_action
# @brief Yes/no confirmation prompt
# @param $1 confirmation message
# @return 0 for yes, 1 for no
confirm_action() {
    local message="$1"
    local response
    read -p "$message (y/N): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# @function validate_aws_resource
# @brief Validate AWS resource exists
# @param $1 resource type (ec2|s3|lambda)
# @param $2 resource identifier
validate_aws_resource() {
    local type="$1"
    local id="$2"
    
    case "$type" in
        "ec2") aws ec2 describe-instances --instance-ids "$id" &>/dev/null ;;
        "s3") aws s3api head-bucket --bucket "$id" &>/dev/null ;;
        "lambda") aws lambda get-function --function-name "$id" &>/dev/null ;;
        *) return 1 ;;
    esac
}

# @function execute_with_retry
# @brief Execute command with retry logic
# @param $1 command to execute
# @param $2 max retries (default: 3)
execute_with_retry() {
    local cmd="$1"
    local max_retries="${2:-3}"
    local count=0
    
    while [[ $count -lt $max_retries ]]; do
        if eval "$cmd"; then
            return 0
        fi
        ((count++))
        sleep 2
    done
    return 1
}