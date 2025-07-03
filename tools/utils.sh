#!/bin/bash

# @file utils.sh
# @brief Utility functions for AWS Management Scripts
# @description Shared functions for AWS CLI validation, formatting, and logging
# @version 2.0
# @usage Source this file in other scripts: source ./utils.sh

# @function check_aws_cli
# @brief Validates AWS CLI installation
# @return 1 if AWS CLI not found, 0 if found
# @usage check_aws_cli || exit 1
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI not installed" >&2
        return 1
    fi
}

# @function check_aws_credentials
# @brief Validates AWS credentials configuration
# @return 1 if credentials invalid, 0 if valid
# @api aws sts get-caller-identity
# @usage check_aws_credentials || exit 1
check_aws_credentials() {
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "Error: AWS credentials not configured" >&2
        return 1
    fi
}

# @function format_output
# @brief Formats service output consistently
# @param $1 Service title string
# @param $2 Resource count number
# @format "%-20s: %s\n"
# @usage format_output "EC2 Instances" "5"
format_output() {
    local title="$1"
    local count="$2"
    printf "%-20s: %s\n" "$title" "$count"
}

# Central log file support
# Set AWS_MGMT_LOG_FILE to override, or defaults to ~/.aws_management_logs/main.log
LOG_FILE="${AWS_MGMT_LOG_FILE:-$HOME/.aws_management_logs/main.log}"
LOG_TO_FILE=true
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

# @function log_error
# @brief Logs error messages to stderr and central log file
# @param $* Error message string
# @output stderr
# @usage log_error "Something went wrong"
log_error() {
    local msg="Error: $*"
    echo "$msg" >&2
    if [ "$LOG_TO_FILE" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_FILE"
    fi
}

# @function log_info
# @brief Logs informational messages to stdout and central log file
# @param $* Info message string
# @output stdout
# @usage log_info "Process completed"
log_info() {
    local msg="Info: $*"
    echo "$msg"
    if [ "$LOG_TO_FILE" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_FILE"
    fi
}