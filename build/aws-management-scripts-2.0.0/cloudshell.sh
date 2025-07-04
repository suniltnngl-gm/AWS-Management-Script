#!/bin/bash

# Enhanced logging
source "$(dirname "$0")/../lib/log_utils.sh" 2>/dev/null || true
# Wrapper for running manage.sh in AWS CloudShell
set -e
SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
bash "$PROJECT_ROOT/scripts/manage.sh" "$@"
bash "$PROJECT_ROOT/bin/orchestrate.sh" "$@"
