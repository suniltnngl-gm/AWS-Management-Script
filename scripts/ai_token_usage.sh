#!/bin/bash

# @file ai_token_usage.sh
# @brief Track and summarize AI token/credit usage from logs for cost monitoring
# @description Parses log files for token/credit usage patterns and summarizes totals. Use this to monitor and optimize AI usage in your workflow. Integrate with manage.sh for regular reporting.
#
# Usage: ./ai_token_usage.sh [logfile]
# Example: ./ai_token_usage.sh ~/.aws_management_logs/main.log
#
# AI Optimization: This script enables both human users and AI assistants to track and report on AI resource consumption, supporting cost control and workflow transparency.

LOGFILE="${1:-$HOME/.aws_management_logs/main.log}"

if [[ ! -f "$LOGFILE" ]]; then
  echo "Log file not found: $LOGFILE"
  exit 1
fi

grep -Eo 'tokens=[0-9]+' "$LOGFILE" | awk -F= '{sum+=$2} END {print "Total tokens used:", sum}'
grep -Eo 'credits=[0-9]+' "$LOGFILE" | awk -F= '{sum+=$2} END {print "Total credits used:", sum}'
