# CI/CD Policy & Troubleshooting Guide

## Policy
- All scripts must source shared libraries using the `SCRIPT_DIR` pattern.
- Scripts requiring arguments or external dependencies are skipped in CI.
- Do not test the test runner itself (`bin/test_all.sh`).
- Document all fixes and path conventions in this file and in script headers for future maintainers.

## Path Conventions
- **Project root scripts:**
  ```bash
  SCRIPT_DIR="$(cd "$(dirname \"${BASH_SOURCE[0]}\")" && pwd)"
  source "$SCRIPT_DIR/lib/log_utils.sh"
  source "$SCRIPT_DIR/lib/aws_utils.sh"
  ```
- **Subdirectory scripts:**
  ```bash
  SCRIPT_DIR="$(cd "$(dirname \"${BASH_SOURCE[0]}\")" && pwd)"
  source "$SCRIPT_DIR/../lib/log_utils.sh"
  source "$SCRIPT_DIR/../lib/aws_utils.sh"
  ```

## Test Runner (bin/test_all.sh)
- Skips itself and scripts that require arguments or have missing dependencies.
- Enhanced logging includes timestamps, error context, and `[SKIP]` for intentionally excluded scripts.
- To add or remove scripts from CI, update the skip list in `bin/test_all.sh`.

## Log Analysis (bin/analyze_test_log.sh)
- Reports `[PASS]`, `[FAIL]`, and `[SKIP]` counts.
- References this policy for maintainers.
- Always check `test_results.log` for error context and timestamps.

## Troubleshooting & Common Fixes
- **[FAIL] due to missing files:** Check path conventions and ensure correct sourcing of shared libraries.
- **[FAIL] due to timeouts:** Check for missing dependencies or required arguments.
- **[SKIP]:** Script is intentionally excluded from CI (see skip list in `bin/test_all.sh`).
- **To add new scripts:** Ensure they follow the sourcing and argument conventions above.
- **Document any new fixes or conventions here for future maintainers.**

## Example Fixes
- Fixed path sourcing for `log_utils.sh` and `aws_utils.sh` using `SCRIPT_DIR`.
- Excluded scripts requiring arguments from CI to avoid false failures.
- Enhanced logging to include timestamps and error context.

---

**For any persistent or new issues, update this file and relevant script headers to help future maintainers.**
