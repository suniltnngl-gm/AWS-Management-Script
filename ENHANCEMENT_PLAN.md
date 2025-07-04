# AWS-Management-Script Enhancement Plan

## Objective
Further enhance all Bash scripts for automation, maintainability, and usability by addressing interactive prompts, logging, error handling, usage documentation, and testability.

---


## Enhancement Checklist

### 7. AI Token/Credit Optimization
- [x] Use concise summaries and checklists to minimize repeated context.
- [x] Make targeted, specific requests to the AI assistant.
- [x] Modularize scripts and automation for focused updates.
- [x] Cache and reuse results of expensive operations.
- [x] Pass configuration/state via environment variables or config files.
- [x] Minimize file reads to only changed or relevant files.
- [x] Batch related changes or queries when possible.
- [x] Integrate helper scripts:
    - `scripts/changed_files.sh`: List only changed files for targeted review/processing.
    - `scripts/ai_batch_request.sh`: Batch related AI/automation requests.
    - `scripts/ai_token_usage.sh`: Track and summarize AI token/credit usage from logs.


### 1. Interactive Prompts
- [x] Identify all scripts using `read -p` or interactive menus.
- [x] Add CLI argument support to allow non-interactive operation.
- [x] Document both interactive and non-interactive usage in `usage()`.
- [x] Add error handling for missing arguments in non-interactive mode.

### 2. Logging Standardization
- [x] Replace all `echo` statements for status, info, and errors with `log_info` or `log_error` from `tools/utils.sh`.
- [x] Ensure all scripts source `tools/utils.sh` at the top.
- [x] Add log level support where appropriate (INFO, WARN, ERROR).
- [x] Optionally, add logging to a central log file for auditability.

### 3. Usage/Help Output
- [x] Standardize the `usage()` function in every script.
- [x] Ensure all options, flags, and exit codes are documented.
- [x] Provide usage examples in the help output.
- [x] Add a header comment block with script purpose, author, and last updated date.

### 4. Error Handling
- [x] Use `set -euo pipefail` in all scripts.
- [x] Wrap critical commands with error checks and log failures.
- [x] Use `log_error` for all error messages.
- [x] Ensure scripts exit with meaningful exit codes.

### 5. Automation & Testability
- [x] Refactor menu-driven scripts to accept command-line flags for automation.
- [x] Add a `--test` or `--dry-run` mode where applicable.
- [x] Ensure scripts can be run in CI/CD without manual input.

### 6. Documentation
- [x] Add or update header comments in every script (purpose, usage, author, date).
- [x] Update the main `README.md` to reflect new automation and usage patterns.
- [x] Document any new environment variables or dependencies.

---


## Environment Variables & Dependencies

### Required Environment Variables
- `AWS_PROFILE` (optional): AWS CLI profile to use for all scripts.
- `AWS_DEFAULT_REGION` (optional): Default AWS region for CLI/API calls.
- `LOG_LEVEL` (optional): Set to `INFO`, `WARN`, or `ERROR` to control script logging verbosity.

### Script-Specific Variables
- `MFA_CODE` (optional): Used by `aws_mfa.sh` for non-interactive MFA authentication.
- `PROMPT_USER_ARG` (optional): Used by helpers to bypass interactive prompts.
- `CONFIRM_ACTION_ARG` (optional): Used by helpers to bypass confirmation prompts.

### Dependencies
- AWS CLI v2 (required for all scripts)
- Bash 4.x or later
- Standard Unix utilities: `jq`, `awk`, `sed`, `grep`, `find`, `date`, `bc`

---


## AI Optimization Summary

This project includes a comprehensive plan to minimize AI token/credit usage and maximize automation efficiency:

### Strategies
- Use concise summaries and checklists to avoid repeated context.
- Make targeted, specific requests to the AI assistant.
- Modularize scripts and automation for focused updates.
- Cache and reuse results of expensive operations.
- Pass configuration/state via environment variables or config files.
- Minimize file reads to only changed or relevant files.
- Batch related changes or queries when possible.

### Helper Scripts
- `scripts/changed_files.sh`: List only changed files for targeted review/processing.
- `scripts/ai_batch_request.sh`: Batch related AI/automation requests.
- `scripts/ai_token_usage.sh`: Track and summarize AI token/credit usage from logs.
- `scripts/manage.sh`: Master workflow script to orchestrate batch operations, changed file detection, and reporting.

### Workflow Integration
- Use `manage.sh` to combine changed file detection, batch processing, and AI usage reporting in a single command.
- Integrate these scripts into CI/CD or local workflows to ensure only necessary files are processed and AI usage is tracked.

_This summary is designed to help maintain efficient, cost-effective AI-assisted development as your project evolves._

---

## AI Assistant Usage

This checklist is now AI-assistant enabled. You can:
- Ask the assistant to check off completed items as you work.
- Request explanations or code samples for any checklist item.
- Ask for a summary of remaining or completed tasks.
- Request automated documentation or code refactoring for any script.

**Example prompts:**
- "Mark all logging standardization items as complete."
- "Show me which scripts still need a --test mode."
- "Update the README with new usage patterns."
- "Document new environment variables."

---


## Next Steps
1. Apply checklist items to all scripts, starting with those using interactive prompts and direct `echo`.
2. Refactor and test each script for non-interactive and automated use.
3. Update documentation and usage output.
4. Review and validate enhancements via CI/CD or manual testing.
5. Implement and monitor AI token/credit optimization strategies in your workflow and documentation.
   - Use `scripts/changed_files.sh` to limit AI/code review to changed files.
   - Use `scripts/ai_batch_request.sh` to group related requests.
   - Use `scripts/ai_token_usage.sh` to monitor and report AI usage/costs.

---

_Last updated: 2025-07-03_
