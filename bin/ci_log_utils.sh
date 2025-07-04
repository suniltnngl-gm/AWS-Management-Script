#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enhanced logging
source "$SCRIPT_DIR/../lib/log_utils.sh" 2>/dev/null || true
# CI/CD Logging Utilities for build, deploy, run steps
#
# Provides standardized logging and status reporting for all pipeline stages.
# Source this in build/deploy/run scripts for consistent log format and analysis.

ci_log_info() {
  echo -e "\033[1;36m[CI-INFO]\033[0m $*"
  echo "[CI-INFO] $*" >> "$CI_LOG_FILE"
}

ci_log_warn() {
  echo -e "\033[1;33m[CI-WARN]\033[0m $*"
  echo "[CI-WARN] $*" >> "$CI_LOG_FILE"
}

ci_log_error() {
  echo -e "\033[1;31m[CI-ERROR]\033[0m $*" >&2
  echo "[CI-ERROR] $*" >> "$CI_LOG_FILE"
}

ci_log_stage() {
  echo -e "\n\033[1;34m[CI-STAGE]\033[0m $*"
  echo "[CI-STAGE] $*" >> "$CI_LOG_FILE"
}

ci_log_summary() {
  echo -e "\n\033[1;35m[CI-SUMMARY]\033[0m $*"
  echo "[CI-SUMMARY] $*" >> "$CI_LOG_FILE"
}

# Usage: export CI_LOG_FILE=build_results.log (or deploy_results.log, etc)
