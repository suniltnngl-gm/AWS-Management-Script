#!/bin/bash
# Automated test for all .sh scripts: checks --help or usage output
# Logs output to test_results.log
#
# POLICY & TROUBLESHOOTING (for maintainers):
# - All scripts must source shared libraries using SCRIPT_DIR pattern.
# - Scripts requiring arguments or external dependencies are skipped in CI.
# - Do not test this runner itself.
# - Document all fixes and path conventions in DOCS_CI_POLICY_AND_TROUBLESHOOTING.md and script headers.
#
# PATH CONVENTION:
#   Project root scripts:   source "$SCRIPT_DIR/lib/log_utils.sh"
#   Subdirectory scripts:   source "$SCRIPT_DIR/../lib/log_utils.sh"
#
# To add a new script, ensure it follows these conventions.

set -e

# Log rotation: keep last 5 logs
LOG_FILE="test_results.log"
if [ -f "$LOG_FILE" ]; then
  for i in 5 4 3 2 1; do
    [ -f "test_results.log.$i" ] && mv "test_results.log.$i" "test_results.log.$((i+1))"
  done
  mv "$LOG_FILE" test_results.log.1
fi

echo "Test run: $(date)" > "$LOG_FILE"
echo "[INFO] POLICY: See DOCS_CI_POLICY_AND_TROUBLESHOOTING.md for test and path conventions." >> "$LOG_FILE"

TIMEOUT=10

PASS=0
FAIL=0
FAIL_LIST=()

# Exclude test_all.sh and scripts that require arguments or are known to fail due to missing dependencies
find . -name "*.sh" | while read -r file; do
  # Skip this test runner itself
  if [[ "$file" == *"bin/test_all.sh" ]]; then
    continue
  fi
  # Skip scripts that require arguments or are known to fail (add more as needed)
  case "$file" in
    *"bin/ai_tools.sh"|*"bin/analyze_test_log.sh"|*"backend/run.sh"|*"aws.sh"|*"build/aws-management-scripts-2.0.0/client/aws_client.sh"|*"bin/archive_tools.sh")
      echo -e "\033[1;33m[SKIP]\033[0m $file (requires arguments or dependency)" | tee -a "$LOG_FILE"
      echo "[SKIP] $file at $(date)" >> "$LOG_FILE"
      continue
      ;;
  esac
  START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "\n\033[1;34m[INFO]\033[0m Testing $file (timeout: ${TIMEOUT}s)" | tee -a "$LOG_FILE"
  if timeout $TIMEOUT bash "$file" --help > tmp_test_output 2>&1; then
    cat tmp_test_output | tee -a "$LOG_FILE"
    echo -e "\033[1;32m[PASS]\033[0m $file" | tee -a "$LOG_FILE"
    echo "[PASS] $file at $START_TIME" >> "$LOG_FILE"
    PASS=$((PASS+1))
  else
    cat tmp_test_output | tee -a "$LOG_FILE"
    echo -e "\033[1;31m[FAIL]\033[0m $file (timeout or error)" | tee -a "$LOG_FILE"
    echo "[FAIL] $file at $START_TIME" >> "$LOG_FILE"
    FAIL_LIST+=("$file")
    FAIL=$((FAIL+1))
    # Enhanced logging: record timestamp and error context
    echo "[ERROR] $START_TIME: $file failed. See above for output." >> "$LOG_FILE"
  fi
  rm -f tmp_test_output
  done

echo -e "\n\033[1;34m[SUMMARY]\033[0m $PASS passed, $FAIL failed. See $LOG_FILE for details."
echo "\n[SUMMARY] $PASS passed, $FAIL failed." >> "$LOG_FILE"
echo "[INFO] Test run completed at $(date)." >> "$LOG_FILE"
echo "[INFO] For troubleshooting and policy, see DOCS_CI_POLICY_AND_TROUBLESHOOTING.md" >> "$LOG_FILE"

if [ $FAIL -gt 0 ]; then
  echo -e "\033[1;31m[FAILURES]\033[0m The following scripts failed:" | tee -a "$LOG_FILE"
  for f in "${FAIL_LIST[@]}"; do
    echo "  - $f" | tee -a "$LOG_FILE"
  done
fi

# Log analysis summary
# Show last 5 summaries and last 10 lines of log for quick review
echo -e "\n\033[1;36m[LOG ANALYSIS]\033[0m Last 5 test runs:"
for i in 1 2 3 4 5; do
  [ -f "test_results.log.$i" ] && grep '\[SUMMARY\]' "test_results.log.$i" | tail -1
  done

echo -e "\n\033[1;36m[LOG TAIL]\033[0m Last 10 lines of $LOG_FILE:"
tail -10 "$LOG_FILE"
