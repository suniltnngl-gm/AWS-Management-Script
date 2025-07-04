#!/bin/bash

# @file modules/performance/monitor.sh
# @brief Real-time performance monitoring with GitHub integration
# @description High-performance monitoring without AWS CloudWatch costs

set -euo pipefail

source "$(dirname "$0")/../../core/core_logger.sh"
source "$(dirname "$0")/../../core/secrets_manager.sh" 2>/dev/null || true

# @function monitor_performance
# @brief Comprehensive performance monitoring
monitor_performance() {
    local start_time=$(date +%s%3N)
    log_info "performance-monitor" "Starting performance monitoring"
    
    local metrics=()
    
    # System performance
    local system_metrics=$(collect_system_metrics)
    metrics+=("$system_metrics")
    
    # AWS resource performance
    local aws_metrics=$(collect_aws_metrics)
    metrics+=("$aws_metrics")
    
    # Application performance
    local app_metrics=$(collect_app_metrics)
    metrics+=("$app_metrics")
    
    local report=$(cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "monitoring_type": "comprehensive",
  "metrics": [$(IFS=','; echo "${metrics[*]}")],
  "alerts": $(generate_performance_alerts "${metrics[@]}")
}
EOF
)
    
    local end_time=$(date +%s%3N)
    log_trace "performance_monitoring" $((end_time - start_time)) "success"
    
    echo "$report"
}

# @function collect_system_metrics
# @brief Collect system-level performance metrics
collect_system_metrics() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d',' -f1)
    local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
    
    cat <<EOF
{
  "type": "system",
  "cpu_usage": $cpu_usage,
  "memory_usage": $memory_usage,
  "disk_usage": $disk_usage,
  "load_average": $load_avg
}
EOF
}

# @function collect_aws_metrics
# @brief Collect AWS resource performance metrics
collect_aws_metrics() {
    setup_aws_credentials || { echo '{"type":"aws","error":"credentials_unavailable"}'; return 1; }
    
    # EC2 instances count and status
    local ec2_running=$(aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`] | length(@)' --output text 2>/dev/null || echo "0")
    local ec2_stopped=$(aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`stopped`] | length(@)' --output text 2>/dev/null || echo "0")
    
    # S3 buckets count
    local s3_buckets=$(aws s3api list-buckets --query 'length(Buckets)' --output text 2>/dev/null || echo "0")
    
    # Lambda functions count
    local lambda_functions=$(aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo "0")
    
    cat <<EOF
{
  "type": "aws_resources",
  "ec2_running": $ec2_running,
  "ec2_stopped": $ec2_stopped,
  "s3_buckets": $s3_buckets,
  "lambda_functions": $lambda_functions
}
EOF
}

# @function collect_app_metrics
# @brief Collect application performance metrics
collect_app_metrics() {
    local log_file="/tmp/aws-mgmt/aws-mgmt.jsonl"
    local log_entries=$(wc -l < "$log_file" 2>/dev/null || echo "0")
    local error_count=$(grep -c '"level":"ERROR"' "$log_file" 2>/dev/null || echo "0")
    local cache_dir="/tmp/aws-mgmt-cache"
    local cache_files=$(find "$cache_dir" -type f 2>/dev/null | wc -l || echo "0")
    
    cat <<EOF
{
  "type": "application",
  "log_entries": $log_entries,
  "error_count": $error_count,
  "cache_files": $cache_files,
  "uptime_seconds": $(cat /proc/uptime | cut -d' ' -f1 | cut -d'.' -f1)
}
EOF
}

# @function generate_performance_alerts
# @brief Generate performance alerts based on metrics
generate_performance_alerts() {
    local alerts=()
    
    for metric in "$@"; do
        local type=$(echo "$metric" | jq -r '.type')
        
        case "$type" in
            "system")
                local cpu=$(echo "$metric" | jq -r '.cpu_usage // 0')
                local memory=$(echo "$metric" | jq -r '.memory_usage // 0')
                
                if (( $(echo "$cpu > 80" | bc -l 2>/dev/null || echo "0") )); then
                    alerts+=('{"severity":"HIGH","type":"cpu","message":"High CPU usage: '$cpu'%"}')
                fi
                
                if (( $(echo "$memory > 85" | bc -l 2>/dev/null || echo "0") )); then
                    alerts+=('{"severity":"HIGH","type":"memory","message":"High memory usage: '$memory'%"}')
                fi
                ;;
            "application")
                local errors=$(echo "$metric" | jq -r '.error_count // 0')
                if [[ $errors -gt 10 ]]; then
                    alerts+=('{"severity":"MEDIUM","type":"errors","message":"High error count: '$errors'"}')
                fi
                ;;
        esac
    done
    
    if [[ ${#alerts[@]} -eq 0 ]]; then
        echo '[]'
    else
        echo "[$(IFS=','; echo "${alerts[*]}")]"
    fi
}

# @function send_performance_alert
# @brief Send performance alerts via GitHub/Slack
send_performance_alert() {
    local alert_data="$1"
    local webhook_url=$(get_github_secret "SLACK_WEBHOOK")
    
    if [[ -n "$webhook_url" ]]; then
        local message="🚨 Performance Alert: $alert_data"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$webhook_url" 2>/dev/null || true
    fi
    
    log_warn "performance-monitor" "Performance alert: $alert_data"
}

case "${1:-monitor}" in
    "monitor") monitor_performance ;;
    "system") collect_system_metrics ;;
    "aws") collect_aws_metrics ;;
    "app") collect_app_metrics ;;
    "alert") send_performance_alert "$2" ;;
    *) echo "Usage: $0 {monitor|system|aws|app|alert} [args...]" ;;
esac