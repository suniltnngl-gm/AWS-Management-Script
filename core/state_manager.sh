

#!/bin/bash
# @file core/state_manager.sh
# @brief Session state management for resilience
# @description Handles session recovery and state persistence
# @ai-optimized: true
# @ai-dry-run-support: true
# @ai-usage: This script is batch-enhanced for AI/automation workflows, supports dry-run/test mode, and is ready for integration with AI agents and workflow orchestrators.


set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../tools/utils.sh"



usage() {
    echo "Usage: $0 [--help|-h] [--dry-run|--test]"
    echo "  Session state management for resilience."
    echo "  --help, -h     Show this help message"
    echo "  --resume [yes|no]   Non-interactive session resume confirmation"
    echo "  --dry-run      Simulate actions, do not make changes"
    echo "  --test         Alias for --dry-run (for AI/automation)"
    echo
    echo "Examples:"
    echo "  $0 --resume yes"
    exit 0
}

# Dry-run/test mode support
DRY_RUN=false
RESUME_ARG=""
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" || "$arg" == "--test" ]]; then
        DRY_RUN=true
    fi
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        usage
    fi
    if [[ "$arg" == "--resume" ]]; then
        RESUME_ARG="$2"; shift
    fi
done

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
        log_info "Previous session detected: $last_session"
        if [[ -n "$RESUME_ARG" ]]; then
            [[ "$RESUME_ARG" =~ ^[Yy]$ ]] && return 0 || return 1
        fi
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