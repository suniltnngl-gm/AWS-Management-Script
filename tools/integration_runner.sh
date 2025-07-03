
#!/bin/bash
# @file integration_runner.sh
# @brief Orchestrates all AWS integrations
# @description Runs multiple integrations and consolidates output
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

usage() {
    echo "Usage: $0 [--dry-run|--test] [--help|-h]"
    echo "  Runs all AWS integrations and consolidates output."
    echo "  --dry-run, --test  Show what would be done, do not call AWS/integrations"
    echo "  --help, -h     Show this help message"
    exit 0
}

DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --dry-run|--test)
            DRY_RUN=true;;
        --help|-h)
            usage;;
    esac
done

run_integrations() {
    log_info "AWS Integration Report - $(date)"
    log_info "=================================="

    if $DRY_RUN; then
        log_info "[DRY RUN] Would run: CloudWatch Metrics, Cost Anomalies, Compliance Summary, Terraform Sync, Slack notification."
        return 0
    fi

    log_info "[CloudWatch Metrics]"
    aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text | \
    while read -r instance; do
        [[ -n "$instance" ]] && log_info "$instance: $(./integrations/cloudwatch_metrics.sh "$instance")% CPU"
    done 2>/dev/null || log_info "No running instances"

    log_info "[Cost Anomalies]"
    ./integrations/cost_anomaly.sh list

    log_info "[Compliance Summary]"
    ./integrations/aws_config.sh summary

    log_info "[Terraform Sync]"
    ./integrations/terraform_sync.sh 2>/dev/null || log_info "Terraform not available"
}

if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
    if $DRY_RUN; then
        log_info "[DRY RUN] Would send Slack notification: Daily AWS Integration Report completed."
        exit 0
    fi
    report=$(run_integrations)
    echo "$report"
    ./integrations/slack_notify.sh "Daily AWS Integration Report completed" "good"
else
    run_integrations
fi