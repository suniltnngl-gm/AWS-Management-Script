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

# @function log_error
# @brief Logs error messages to stderr
# @param $* Error message string
# @output stderr
# @usage log_error "Something went wrong"
log_error() {
    echo "Error: $*" >&2
}

# @function log_info
# @brief Logs informational messages to stdout
# @param $* Info message string
# @output stdout
# @usage log_info "Process completed"
log_info() {
    echo "Info: $*"
}