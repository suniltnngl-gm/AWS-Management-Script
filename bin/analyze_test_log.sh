#!/bin/bash
# Analyze test_results.log for CI/CD and advanced reporting
#
# POLICY & TROUBLESHOOTING (for maintainers):
#
# - All scripts must source shared libraries using the SCRIPT_DIR pattern.
# - Scripts requiring arguments or external dependencies are skipped in CI.
# - If you see '[FAIL]' due to missing files, check path conventions in test_all.sh and script headers.
# - If you see '[FAIL]' due to timeouts, check for missing dependencies or required arguments.
# - If you see '[SKIP]', the script is intentionally excluded from CI (see test_all.sh for skip list).
# - To add or remove scripts from CI, update the skip list in test_all.sh.
# - Always check the error context and timestamps in test_results.log for debugging.
# - Document any new fixes or conventions here for future maintainers.
#
# Example Fixes:
#   - Fixed path sourcing for log_utils.sh and aws_utils.sh using SCRIPT_DIR.
#   - Excluded scripts requiring arguments from CI to avoid false failures.
#   - Enhanced logging to include timestamps and error context.

LOG_FILE="test_results.log"
FAIL_COUNT=$(grep -c '\[FAIL\]' "$LOG_FILE")
PASS_COUNT=$(grep -c '\[PASS\]' "$LOG_FILE")
SKIP_COUNT=$(grep -c '\[SKIP\]' "$LOG_FILE")

echo "Test Summary:"
echo "  PASS: $PASS_COUNT"
echo "  FAIL: $FAIL_COUNT"
echo "  SKIP: $SKIP_COUNT"
echo "  See DOCS_CI_POLICY_AND_TROUBLESHOOTING.md for policy and troubleshooting."

echo "\n[INFO] For troubleshooting and common fixes, see the header of this script and DOCS_CI_POLICY_AND_TROUBLESHOOTING.md."

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "\nFailed scripts (last 5):"
  grep '\[FAIL\]' "$LOG_FILE" | tail -5
  echo "\n[ERROR] See $LOG_FILE for error context and timestamps."
  echo "\nRecent PASS entries (last 5):"
  grep '\[PASS\]' "$LOG_FILE" | tail -5
  echo "\nRecent SKIP entries (last 5):"
  grep '\[SKIP\]' "$LOG_FILE" | tail -5
  echo "\n[INFO] Log summary:"
  tail -20 "$LOG_FILE"
  exit 1  # Block CI/CD if any fail
else
  echo "All scripts passed or skipped."
  echo "\n[INFO] Log summary:"
  tail -20 "$LOG_FILE"
  exit 0
fi
