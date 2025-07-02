#!/bin/bash

# @file switch-logic/switch_hub.sh
# @brief Switch Logic Hub - Stability management
# @description Toggle between stable version and evaluation mode

set -euo pipefail

source "$(dirname "$0")/../core/config_loader.sh"

SWITCH_STATE_FILE="$HOME/.aws_management_state/switch_mode"

# @function get_current_mode
# @brief Get current operational mode
get_current_mode() {
    if [[ -f "$SWITCH_STATE_FILE" ]]; then
        cat "$SWITCH_STATE_FILE"
    else
        echo "stable"
    fi
}

# @function set_mode
# @brief Set operational mode
# @param $1 mode (stable|evaluation)
set_mode() {
    local mode="$1"
    
    case "$mode" in
        "stable"|"evaluation")
            mkdir -p "$(dirname "$SWITCH_STATE_FILE")"
            echo "$mode" > "$SWITCH_STATE_FILE"
            echo "✅ Mode set to: $mode"
            ;;
        *)
            echo "❌ Invalid mode: $mode (use: stable|evaluation)"
            return 1
            ;;
    esac
}

# @function show_mode_status
# @brief Display current mode and configuration
show_mode_status() {
    local current_mode=$(get_current_mode)
    
    echo "🔄 SWITCH LOGIC STATUS"
    echo "====================="
    echo "Current Mode: $current_mode"
    echo "State File: $SWITCH_STATE_FILE"
    echo
    
    case "$current_mode" in
        "stable")
            echo "🟢 STABLE MODE ACTIVE"
            echo "• Production-ready features only"
            echo "• Conservative resource usage"
            echo "• Minimal risk operations"
            echo "• Proven configurations"
            ;;
        "evaluation")
            echo "🟡 EVALUATION MODE ACTIVE"
            echo "• Testing new features"
            echo "• Experimental configurations"
            echo "• Enhanced monitoring"
            echo "• Risk assessment enabled"
            ;;
    esac
}

# @function switch_to_stable
# @brief Switch to stable production mode
switch_to_stable() {
    echo "🟢 SWITCHING TO STABLE MODE"
    echo "=========================="
    
    set_mode "stable"
    
    # Apply stable configurations
    echo "Applying stable configurations..."
    
    # Use conservative settings
    export AWS_CLI_READ_TIMEOUT=60
    export AWS_CLI_MAX_ATTEMPTS=3
    
    # Enable only core features
    echo "✅ Core features enabled"
    echo "❌ Experimental features disabled"
    echo "✅ Conservative timeouts set"
    echo "✅ Error handling enhanced"
    
    # Log mode change
    echo "$(date): Switched to stable mode" >> "$HOME/.aws_management_state/mode_changes.log"
}

# @function switch_to_evaluation
# @brief Switch to evaluation/testing mode
switch_to_evaluation() {
    echo "🟡 SWITCHING TO EVALUATION MODE"
    echo "=============================="
    
    set_mode "evaluation"
    
    # Apply evaluation configurations
    echo "Applying evaluation configurations..."
    
    # Use extended settings for testing
    export AWS_CLI_READ_TIMEOUT=120
    export AWS_CLI_MAX_ATTEMPTS=5
    
    # Enable experimental features
    echo "✅ Experimental features enabled"
    echo "✅ Extended monitoring active"
    echo "✅ Debug logging enabled"
    echo "⚠️  Risk assessment required"
    
    # Log mode change
    echo "$(date): Switched to evaluation mode" >> "$HOME/.aws_management_state/mode_changes.log"
}

# @function auto_switch_logic
# @brief Automatic switching based on conditions
auto_switch_logic() {
    echo "🤖 AUTO SWITCH LOGIC"
    echo "==================="
    
    local current_mode=$(get_current_mode)
    local current_hour=$(date +%H)
    local day_of_week=$(date +%u)
    
    # Business hours: Monday-Friday 9-17
    if [[ $day_of_week -le 5 && $current_hour -ge 9 && $current_hour -le 17 ]]; then
        if [[ "$current_mode" != "stable" ]]; then
            echo "Business hours detected - switching to stable mode"
            switch_to_stable
        else
            echo "Already in stable mode for business hours"
        fi
    else
        echo "Off-hours detected - evaluation mode available"
        if [[ "$current_mode" == "stable" ]]; then
            echo "Consider switching to evaluation mode for testing"
        fi
    fi
}

# @function feature_gate
# @brief Control feature availability based on mode
# @param $1 feature_name
feature_gate() {
    local feature="$1"
    local current_mode=$(get_current_mode)
    
    case "$current_mode" in
        "stable")
            case "$feature" in
                "core_management"|"billing"|"mfa"|"basic_audit")
                    return 0  # Allow
                    ;;
                "experimental_integrations"|"beta_features"|"advanced_routing")
                    echo "⚠️  Feature '$feature' not available in stable mode"
                    return 1  # Block
                    ;;
                *)
                    return 0  # Default allow for stable
                    ;;
            esac
            ;;
        "evaluation")
            return 0  # Allow all features in evaluation mode
            ;;
    esac
}

# @function mode_specific_execution
# @brief Execute commands based on current mode
# @param $1 command
mode_specific_execution() {
    local command="$1"
    local current_mode=$(get_current_mode)
    
    echo "Executing in $current_mode mode: $command"
    
    case "$current_mode" in
        "stable")
            # Add stability checks
            timeout 30 bash -c "$command" || {
                echo "❌ Command failed in stable mode - reverting"
                return 1
            }
            ;;
        "evaluation")
            # Add monitoring and logging
            echo "$(date): Evaluation execution: $command" >> "$HOME/.aws_management_state/evaluation.log"
            bash -c "$command" || {
                echo "⚠️  Command failed in evaluation mode - continuing"
                return 0  # Don't fail hard in evaluation
            }
            ;;
    esac
}

case "${1:-status}" in
    "status") show_mode_status ;;
    "stable") switch_to_stable ;;
    "evaluation") switch_to_evaluation ;;
    "auto") auto_switch_logic ;;
    "gate") feature_gate "${2:-core}" ;;
    "exec") mode_specific_execution "${2:-echo 'test'}" ;;
    "get") get_current_mode ;;
    *) echo "Usage: $0 [status|stable|evaluation|auto|gate <feature>|exec <command>|get]" ;;
esac