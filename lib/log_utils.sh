#!/bin/bash

# log_utils.sh: Provides basic and structured JSON logging functions.

LOG_FILE="${CI_LOG_FILE:-ci.log}"


# --- Basic Logging Functions ---
# For simple, human-readable status updates to STDOUT and the log file.

log_info() {
    echo "[INFO] $(date -u +"%Y-%m-%dT%H:%M:%SZ"): $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo "[WARN] $(date -u +"%Y-%m-%dT%H:%M:%SZ"): $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $(date -u +"%Y-%m-%dT%H:%M:%SZ"): $1" | tee -a "$LOG_FILE"
}


# --- Structured JSON Logging ---
# For detailed, machine-readable log entries. Requires `jq`.
# Usage: log_json "LEVEL" "A short summary message" "{\"key\":\"value\",\"details\":\"more_info\"}"

log_json() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed. Cannot create JSON log."
        return 1
    fi

    local level="$1"
    local message="$2"
    # Optional: Pass a JSON string of details
    local details_json="${3:-{\}}"

    # Get the name of the script that called this function
    local calling_script
    calling_script=$(basename "${BASH_SOURCE[1]}")

    # Create the JSON log entry
    jq -n \
      --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
      --arg level "$level" \
      --arg script "$calling_script" \
      --arg message "$message" \
      --argjson details "$details_json" \
      '{timestamp: $timestamp, level: $level, script: $script, message: $message, details: $details}' | tee -a "$LOG_FILE"
}
