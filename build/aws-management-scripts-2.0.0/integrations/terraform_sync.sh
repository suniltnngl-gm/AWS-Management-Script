#!/bin/bash

# @file terraform_sync.sh
# @brief Terraform state integration
# @requires terraform CLI

set -euo pipefail

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
[[ "${1:-}" == "compare" ]] && compare_with_aws || get_tf_resources