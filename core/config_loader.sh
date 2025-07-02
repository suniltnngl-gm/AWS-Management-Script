#!/bin/bash

# @file core/config_loader.sh
# @brief Configuration loader with fallbacks
# @description Resilient config loading with defaults

set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-$(dirname "$0")/../config/settings.conf}"

# @function load_config
# @brief Load configuration with fallback defaults
load_config() {
    # Set defaults first
    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    export DEFAULT_PROFILE="${DEFAULT_PROFILE:-default}"
    export COST_THRESHOLD="${COST_THRESHOLD:-100}"
    export AUTO_RETRY_COUNT="${AUTO_RETRY_COUNT:-3}"
    
    # Load from config file if exists
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^[A-Z_]+$ ]] && export "$key"="$value"
        done < <(grep -E '^[A-Z_]+=.*' "$CONFIG_FILE" 2>/dev/null || true)
    fi
}

# @function get_config
# @brief Get configuration value with fallback
# @param $1 config key
# @param $2 default value
get_config() {
    local key="$1"
    local default="${2:-}"
    echo "${!key:-$default}"
}

load_config