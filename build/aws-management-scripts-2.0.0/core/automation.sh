#!/bin/bash

# @file core/automation.sh
# @brief Core automation engine
# @description Handles automated workflows and scheduling

set -euo pipefail

source "$(dirname "$0")/helpers.sh"

# @function run_automated_audit
# @brief Automated AWS audit with notifications
run_automated_audit() {
    local threshold=$(prompt_user "Cost alert threshold" "100")
    local notify=$(confirm_action "Enable Slack notifications?")
    
    echo "Running automated audit..."
    
    # Run audit
    local report_file="/tmp/aws_audit_$(date +%s).txt"
    {
        echo "AWS Automated Audit - $(date)"
        echo "============================="
        ../aws_manager.sh
        echo
        ../cloudfront_audit.sh
    } > "$report_file"
    
    # Check costs
    local current_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$(date -d '1 day ago' +%Y-%m-%d)",End="$(date +%Y-%m-%d)" \
        --granularity DAILY --metrics BlendedCost \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text 2>/dev/null || echo "0")
    
    if (( $(echo "$current_cost > $threshold" | bc -l 2>/dev/null || echo "0") )); then
        echo "ALERT: Cost $current_cost exceeds threshold $threshold" >> "$report_file"
        [[ "$notify" == true ]] && ../integrations/slack_notify.sh "Cost alert: \$$current_cost" "danger"
    fi
    
    cat "$report_file"
    rm "$report_file"
}

# @function setup_scheduled_monitoring
# @brief Setup cron job for monitoring
setup_scheduled_monitoring() {
    local frequency=$(prompt_user "Schedule frequency (daily/weekly)" "daily")
    local time=$(prompt_user "Time (HH:MM)" "09:00")
    
    local cron_schedule
    case "$frequency" in
        "daily") cron_schedule="0 ${time%:*} * * *" ;;
        "weekly") cron_schedule="0 ${time%:*} * * 1" ;;
        *) echo "Invalid frequency"; return 1 ;;
    esac
    
    local script_path="$(cd "$(dirname "$0")/.." && pwd)/integration_runner.sh"
    local cron_entry="$cron_schedule $script_path"
    
    if confirm_action "Add cron job: $cron_entry"; then
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        echo "Scheduled monitoring enabled"
    fi
}