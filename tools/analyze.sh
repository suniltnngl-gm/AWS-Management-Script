#!/bin/bash

# Enhanced logging
source "$(dirname "$0")/../lib/log_utils.sh" 2>/dev/null || true
set -euo pipefail

echo "--- Starting Project Analysis ---"
ANALYSIS_PASSED=true

# --- 1. Shell Script Linting (shellcheck) ---
echo
echo "=> Running ShellCheck for static analysis..."
if ! command -v shellcheck &> /dev/null; then
    echo "Warning: shellcheck is not installed. Skipping linting."
    echo "         To install, see: https://github.com/koalaman/shellcheck"
else
    # Find all shell scripts, excluding .git directory
    SCRIPTS_TO_CHECK=$(find . -name "*.sh" -not -path "./.git/*")
    if [ -n "$SCRIPTS_TO_CHECK" ]; then
        if ! shellcheck $SCRIPTS_TO_CHECK; then
            echo "ShellCheck found issues."
            ANALYSIS_PASSED=false
        else
            echo "ShellCheck passed."
        fi
    else
        echo "No shell scripts found to check."
    fi
fi

# --- 2. Executable Permissions Check ---
echo
echo "=> Checking for executable permissions on scripts..."
EXECUTABLE_DIRS=("scripts" "run" "tools")
PERMISSION_ERRORS=0
for dir in "${EXECUTABLE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Find non-executable .sh files
        NON_EXEC_SCRIPTS=$(find "$dir" -name "*.sh" -not -executable)
        if [ -n "$NON_EXEC_SCRIPTS" ]; then
            echo "Error: The following scripts are not executable:"
            echo "$NON_EXEC_SCRIPTS"
            echo "Run 'chmod +x <file>' to fix."
            PERMISSION_ERRORS=1
        fi
    fi
done

if [ $PERMISSION_ERRORS -eq 0 ]; then
    echo "All scripts have correct executable permissions."
else
    ANALYSIS_PASSED=false
fi


# --- 3. Basic Secret Scanning ---
echo
echo "=> Performing basic secret scan..."
# Patterns to detect common secrets. This is not exhaustive.
SECRET_PATTERNS=("AWS_SECRET_ACCESS_KEY" "BEGIN RSA PRIVATE KEY" "ghp_[0-9a-zA-Z]{36}")
if grep -rE --exclude-dir={.git,artifacts} --exclude="*/analyze.sh" "$(IFS=\|; echo "${SECRET_PATTERNS[*]}")" . ; then
    echo "Error: Potential secrets detected. Review the matches above."
    ANALYSIS_PASSED=false
else
    echo "Basic secret scan passed."
fi

# --- Final Summary ---
echo
echo "--- Analysis Complete ---"
if [ "$ANALYSIS_PASSED" = true ]; then
    echo "✅ All checks passed successfully."
    exit 0
else
    echo "❌ Analysis failed. Please review the errors above."
    exit 1
fi