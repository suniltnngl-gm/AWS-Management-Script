#!/bin/bash

# @file lib/production_logger.sh
# @brief Production-grade logging for real-world AWS operations
# @description Enhanced logging with AWS CloudWatch integration

set -euo pipefail

# Production logging configuration
PROD_LOG_DIR="${AWS_MGMT_LOG_DIR:-/tmp/aws-mgmt}"
PROD_LOG_FILE="${PROD_LOG_DIR}/aws-management.log"
AUDIT_LOG_FILE="${PROD_LOG_DIR}/audit.log"
ERROR_LOG_FILE="${PROD_LOG_DIR}/errors.log"
METRICS_LOG_FILE="${PROD_LOG_DIR}/metrics.log"

# Create log directories
mkdir -p "$PROD_LOG_DIR" 2>/dev/null || true

# @function prod_log
# @brief Production logging with structured format
prod_log() {
    local level="$1"
    local component="$2"
    local action="$3"
    shift 3
    local message="$*"
    
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local hostname=$(hostname)
    local pid=$$
    
    # Structured JSON log entry
    local log_entry=$(cat <<EOF
{"timestamp":"$timestamp","level":"$level","hostname":"$hostname","pid":$pid,"component":"$component","action":"$action","message":"$message"}
EOF
)
    
    # Write to appropriate log files
    echo "$log_entry" >> "$PROD_LOG_FILE"
    
    case "$level" in
        "ERROR"|"FATAL") echo "$log_entry" >> "$ERROR_LOG_FILE" ;;
        "AUDIT") echo "$log_entry" >> "$AUDIT_LOG_FILE" ;;
        "METRIC") echo "$log_entry" >> "$METRICS_LOG_FILE" ;;
    esac
    
    # Console output for development
    [[ "${AWS_MGMT_DEBUG:-}" == "true" ]] && echo "[$timestamp] [$level] $component.$action: $message"
}

# @function log_aws_operation
# @brief Log AWS API operations with details
log_aws_operation() {
    local service="$1"
    local operation="$2"
    local status="$3"
    local duration="${4:-0}"
    local cost="${5:-0.00}"
    
    prod_log "AUDIT" "aws-$service" "$operation" "status=$status duration=${duration}ms cost=\$${cost}"
    
    # Metrics logging
    prod_log "METRIC" "aws-api" "call" "service=$service operation=$operation duration=$duration cost=$cost"
}

# @function log_cost_analysis
# @brief Log cost analysis results
log_cost_analysis() {
    local service="$1"
    local current_cost="$2"
    local projected_cost="$3"
    local recommendation="$4"
    
    prod_log "INFO" "cost-analyzer" "analysis" "service=$service current=\$${current_cost} projected=\$${projected_cost} recommendation='$recommendation'"
}

# @function log_security_event
# @brief Log security-related events
log_security_event() {
    local event_type="$1"
    local resource="$2"
    local severity="$3"
    local details="$4"
    
    prod_log "AUDIT" "security" "$event_type" "resource=$resource severity=$severity details='$details'"
}

# @function send_to_cloudwatch
# @brief Send logs to AWS CloudWatch (if configured)
send_to_cloudwatch() {
    local log_group="${AWS_MGMT_LOG_GROUP:-/aws/management-scripts}"
    local log_stream="${AWS_MGMT_LOG_STREAM:-$(hostname)-$(date +%Y%m%d)}"
    
    if command -v aws >/dev/null 2>&1 && [[ "${AWS_MGMT_CLOUDWATCH:-}" == "true" ]]; then
        # Create log group if it doesn't exist
        aws logs create-log-group --log-group-name "$log_group" 2>/dev/null || true
        
        # Create log stream if it doesn't exist
        aws logs create-log-stream --log-group-name "$log_group" --log-stream-name "$log_stream" 2>/dev/null || true
        
        # Send recent logs to CloudWatch
        tail -100 "$PROD_LOG_FILE" | while read -r log_line; do
            aws logs put-log-events \
                --log-group-name "$log_group" \
                --log-stream-name "$log_stream" \
                --log-events timestamp=$(date +%s000),message="$log_line" 2>/dev/null || true
        done
    fi
}

# @function rotate_logs
# @brief Production log rotation
rotate_logs() {
    local max_size=104857600  # 100MB
    
    for log_file in "$PROD_LOG_FILE" "$AUDIT_LOG_FILE" "$ERROR_LOG_FILE" "$METRICS_LOG_FILE"; do
        if [[ -f "$log_file" ]] && [[ $(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo "0") -gt $max_size ]]; then
            mv "$log_file" "${log_file}.$(date +%Y%m%d_%H%M%S)"
            touch "$log_file"
            prod_log "INFO" "logger" "rotate" "rotated $log_file"
        fi
    done
}

# Initialize production logging
prod_log "INFO" "logger" "init" "Production logging initialized"