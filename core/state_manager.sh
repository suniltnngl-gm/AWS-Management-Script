#!/bin/bash

# @file core/state_manager.sh
# @brief Session state management for resilience
# @description Handles session recovery and state persistence

set -euo pipefail

STATE_DIR="${HOME}/.aws_management_state"
SESSION_FILE="$STATE_DIR/current_session"

# @function init_state
# @brief Initialize state management
init_state() {
    mkdir -p "$STATE_DIR"
    echo "$(date +%s):$$:$(pwd)" > "$SESSION_FILE"
}

# @function save_state
# @brief Save current operation state
# @param $1 operation name
# @param $2 state data
save_state() {
    local operation="$1"
    local state="$2"
    echo "$operation:$state:$(date +%s)" >> "$STATE_DIR/operations.log"
}

# @function recover_state
# @brief Recover from interrupted session
recover_state() {
    if [[ -f "$SESSION_FILE" ]]; then
        local last_session=$(cat "$SESSION_FILE")
        echo "Previous session detected: $last_session"
        read -p "Resume previous session? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
    return 1
}

# @function cleanup_state
# @brief Clean up state files
cleanup_state() {
    find "$STATE_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
}

init_state