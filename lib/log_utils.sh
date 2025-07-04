#!/bin/bash

# @file lib/log_utils.sh
# @brief Centralized logging utilities
# @description Standardized logging system for AWS Management Scripts

# Configuration
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FILE=${LOG_FILE:-/tmp/aws-mgmt.log}
LOG_MAX_SIZE=${LOG_MAX_SIZE:-10485760}  # 10MB

# @function log
# @brief Core logging function
log() {
    local level=$1; shift
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[$timestamp] [$level] $*"
    
    # Output to console and file
    echo "$message" | tee -a "$LOG_FILE"
    
    # Log rotation if needed
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo "0") -gt $LOG_MAX_SIZE ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
    fi
}

# @function log_info
# @brief Info level logging
log_info() { 
    [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO)$ ]] && log "INFO" "$@"
}

# @function log_warn
# @brief Warning level logging
log_warn() { 
    [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARN)$ ]] && log "WARN" "$@"
}

# @function log_error
# @brief Error level logging
log_error() { 
    log "ERROR" "$@"
}

# @function log_debug
# @brief Debug level logging
log_debug() { 
    [[ "$LOG_LEVEL" == "DEBUG" ]] && log "DEBUG" "$@"
}

# @function log_performance
# @brief Performance timing logging
log_performance() {
    local operation="$1"
    local start_time="$2"
    local end_time="${3:-$(date +%s)}"
    local duration=$((end_time - start_time))
    
    log_info "PERF: $operation completed in ${duration}s"
}

# @function log_analysis
# @brief Analysis result logging
log_analysis() {
    local component="$1"
    local result="$2"
    local details="${3:-}"
    
    log_info "ANALYSIS: $component -> $result${details:+ ($details)}"
}

# Initialize log file
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"