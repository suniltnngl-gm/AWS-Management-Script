

#!/bin/bash
# @file terraform_sync.sh
# @brief Terraform state integration
# @requires terraform CLI
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary Terraform/AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../tools/utils.sh"


usage() {
    echo "Usage: $0 [compare|list|--dry-run|--test|--help|-h]"
    echo "  compare      Compare Terraform and AWS resources"
    echo "  list         List Terraform resources"
    echo "  --dry-run, --test  Show what would be done, do not call Terraform/AWS"
    echo "  --help, -h   Show this help message"
    exit 0
}

DRY_RUN=false
ARGS=()
for arg in "$@"; do
    case $arg in
        --dry-run|--test)
            DRY_RUN=true;;
        --help|-h)
            usage;;
        *)
            ARGS+=("$arg");;
    esac
done
set -- "${ARGS[@]}"

check_terraform() {
    command -v terraform &>/dev/null || { echo "Error: Terraform not installed" >&2; exit 1; }
}

get_tf_resources() {
    terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[]? | select(.type | startswith("aws_")) | "\(.type): \(.values.id // .values.name // "unnamed")"' 2>/dev/null || echo "No Terraform state found"
}

compare_with_aws() {
    echo "Terraform Resources:"
    get_tf_resources
    echo
    echo "AWS Resources:"
    ../aws_manager.sh | grep -E "(EC2|S3|Lambda)" || true
}

check_terraform
if $DRY_RUN; then
    echo "[DRY RUN] Would run: $0 ${ARGS[*]} (no Terraform or AWS calls)"
    exit 0
fi
[[ "${1:-}" == "compare" ]] && compare_with_aws || get_tf_resources