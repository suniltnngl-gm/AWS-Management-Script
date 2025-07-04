#!/bin/bash

# @file core/core_logger.sh
# @brief Centralized logging system - Single source of truth
# @description High-performance structured logging with correlation tracking

set -euo pipefail

# Core configuration
readonly LOG_DIR="${AWS_MGMT_LOG_DIR:-/tmp/aws-mgmt}"
readonly LOG_LEVEL="${AWS_MGMT_LOG_LEVEL:-INFO}"
readonly CORRELATION_ID="${AWS_MGMT_CORRELATION_ID:-$(date +%s%N | cut -b1-13)}"
readonly SERVICE_NAME="${AWS_MGMT_SERVICE:-aws-mgmt}"

# Performance optimization
readonly LOG_BUFFER_SIZE=1000
declare -a LOG_BUFFER=()
declare -i BUFFER_COUNT=0

# Initialize logging
mkdir -p "$LOG_DIR" 2>/dev/null || true

# @function log_structured
# @brief High-performance structured logging
log_structured() {
    local level="$1"
    local component="$2"
    local message="$3"
    local metadata="${4:-{}}"
    
    # Skip if level not enabled
    case "$LOG_LEVEL" in
        "ERROR") [[ "$level" =~ ^(ERROR|FATAL)$ ]] || return 0 ;;
        "WARN") [[ "$level" =~ ^(WARN|ERROR|FATAL)$ ]] || return 0 ;;
        "INFO") [[ "$level" =~ ^(INFO|WARN|ERROR|FATAL)$ ]] || return 0 ;;
        "DEBUG") ;; # Log everything
    esac
    
    # Structured log entry
    local log_entry=$(cat <<EOF
{"timestamp":"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)","level":"$level","service":"$SERVICE_NAME","component":"$component","correlation_id":"$CORRELATION_ID","message":"$message","metadata":$metadata,"hostname":"$(hostname)","pid":$$}
EOF
)
    
    # Buffer for performance
    LOG_BUFFER[BUFFER_COUNT]="$log_entry"
    ((BUFFER_COUNT++))
    
    # Flush buffer when full
    if [[ $BUFFER_COUNT -ge $LOG_BUFFER_SIZE ]]; then
        flush_logs
    fi
    
    # Console output for development
    [[ "${AWS_MGMT_DEBUG:-}" == "true" ]] && echo "$log_entry" >&2
}

# @function flush_logs
# @brief Flush buffered logs to file
flush_logs() {
    [[ $BUFFER_COUNT -eq 0 ]] && return 0
    
    local log_file="$LOG_DIR/aws-mgmt.jsonl"
    printf '%s\n' "${LOG_BUFFER[@]:0:$BUFFER_COUNT}" >> "$log_file"
    
    # Reset buffer
    LOG_BUFFER=()
    BUFFER_COUNT=0
    
    # Rotate if needed
    [[ -f "$log_file" ]] && [[ $(stat -c%s "$log_file" 2>/dev/null || echo "0") -gt 10485760 ]] && rotate_logs
}

# @function rotate_logs
# @brief Intelligent log rotation
rotate_logs() {
    local log_file="$LOG_DIR/aws-mgmt.jsonl"
    [[ -f "$log_file" ]] || return 0
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$log_file" "${log_file}.${timestamp}"
    
    # Keep only last 10 files
    find "$LOG_DIR" -name "aws-mgmt.jsonl.*" -type f | sort | head -n -10 | xargs rm -f 2>/dev/null || true
}

# Convenience functions
log_debug() { log_structured "DEBUG" "$1" "$2" "${3:-{}}" ; }
log_info() { log_structured "INFO" "$1" "$2" "${3:-{}}" ; }
log_warn() { log_structured "WARN" "$1" "$2" "${3:-{}}" ; }
log_error() { log_structured "ERROR" "$1" "$2" "${3:-{}}" ; }
log_fatal() { log_structured "FATAL" "$1" "$2" "${3:-{}}" ; }

# @function log_metric
# @brief Log performance metrics
log_metric() {
    local metric_name="$1"
    local value="$2"
    local tags="${3:-{}}"
    
    log_structured "METRIC" "metrics" "$metric_name" "{\"value\":$value,\"tags\":$tags}"
}

# @function log_trace
# @brief Distributed tracing
log_trace() {
    local operation="$1"
    local duration_ms="$2"
    local status="${3:-success}"
    
    log_structured "TRACE" "tracing" "$operation" "{\"duration_ms\":$duration_ms,\"status\":\"$status\"}"
}

# Cleanup on exit
trap 'flush_logs' EXIT