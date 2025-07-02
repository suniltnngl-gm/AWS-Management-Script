#!/bin/bash

# @file integration_runner.sh
# @brief Orchestrates all AWS integrations
# @description Runs multiple integrations and consolidates output

set -euo pipefail

run_integrations() {
    echo "AWS Integration Report - $(date)"
    echo "=================================="
    
    # CloudWatch metrics for running instances
    echo -e "\n[CloudWatch Metrics]"
    aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text | \
    while read -r instance; do
        [[ -n "$instance" ]] && echo "$instance: $(./integrations/cloudwatch_metrics.sh "$instance")% CPU"
    done 2>/dev/null || echo "No running instances"
    
    # Cost anomalies
    echo -e "\n[Cost Anomalies]"
    ./integrations/cost_anomaly.sh list
    
    # Compliance status
    echo -e "\n[Compliance Summary]"
    ./integrations/aws_config.sh summary
    
    # Terraform comparison
    echo -e "\n[Terraform Sync]"
    ./integrations/terraform_sync.sh 2>/dev/null || echo "Terraform not available"
}

# Send to Slack if configured
if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
    report=$(run_integrations)
    echo "$report"
    ./integrations/slack_notify.sh "Daily AWS Integration Report completed" "good"
else
    run_integrations
fi