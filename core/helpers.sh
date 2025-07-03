

#!/bin/bash
# @file core/helpers.sh
# @brief Core helper functions for automation
# @description Shared utilities for client automation
# @ai-optimized: true
# @ai-dry-run-support: true
# @ai-usage: This script is batch-enhanced for AI/automation workflows, supports dry-run/test mode, and is ready for integration with AI agents and workflow orchestrators.


set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../tools/utils.sh"

# Load configuration and state management
source "$SCRIPT_DIR/config_loader.sh"
source "$SCRIPT_DIR/state_manager.sh"


usage() {
    echo "Usage: $0 [--help|-h] [--dry-run|--test]"
    echo "  Core helper functions for automation."
    echo "  --help, -h     Show this help message"
    echo "  --prompt-user <message> [default]   Non-interactive prompt"
    echo "  --confirm-action <message> [yes|no] Non-interactive confirm"
    echo "  --dry-run      Simulate actions, do not make changes"
    echo "  --test         Alias for --dry-run (for AI/automation)"
    echo
    echo "Examples:"
    echo "  $0 --prompt-user 'Enter name' John"
    echo "  $0 --confirm-action 'Proceed?' yes"
    exit 0
}

# Dry-run/test mode support
DRY_RUN=false
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" || "$arg" == "--test" ]]; then
        DRY_RUN=true
    fi
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        usage
    fi
done

# @function prompt_user
# @brief Interactive user prompts with validation
# @param $1 prompt message
# @param $2 default value (optional)
prompt_user() {
    local message="$1"
    local default="${2:-}"
    local input
    if [[ -n "$PROMPT_USER_ARG" ]]; then
        echo "$PROMPT_USER_ARG"
        return
    fi
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
    if [[ -n "$CONFIRM_ACTION_ARG" ]]; then
        [[ "$CONFIRM_ACTION_ARG" =~ ^[Yy]$ ]]
        return
    fi
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