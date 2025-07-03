#!/bin/bash
# Analyze CI/CD logs for build, deploy, run steps
# Usage: bin/analyze_ci_log.sh <logfile>

LOG_FILE="$1"
if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
  echo "Usage: $0 <logfile>"
  echo "Log file not found: $LOG_FILE"
  exit 2
fi

INFO_COUNT=$(grep -c '\[CI-INFO\]' "$LOG_FILE")
WARN_COUNT=$(grep -c '\[CI-WARN\]' "$LOG_FILE")
ERROR_COUNT=$(grep -c '\[CI-ERROR\]' "$LOG_FILE")
STAGE_COUNT=$(grep -c '\[CI-STAGE\]' "$LOG_FILE")
SUMMARY_COUNT=$(grep -c '\[CI-SUMMARY\]' "$LOG_FILE")

echo "CI Log Analysis for $LOG_FILE:"
echo "  INFO:    $INFO_COUNT"
echo "  WARN:    $WARN_COUNT"
echo "  ERROR:   $ERROR_COUNT"
echo "  STAGE:   $STAGE_COUNT"
echo "  SUMMARY: $SUMMARY_COUNT"

echo -e "\nLast 5 errors/warnings:"
grep -E '\[CI-(ERROR|WARN)\]' "$LOG_FILE" | tail -5

echo -e "\nLast 5 stages:"
grep '\[CI-STAGE\]' "$LOG_FILE" | tail -5

echo -e "\nLast 5 summaries:"
grep '\[CI-SUMMARY\]' "$LOG_FILE" | tail -5

exit $ERROR_COUNT
