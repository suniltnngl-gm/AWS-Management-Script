#!/bin/bash
# @file aws_mfa.sh
# @brief AWS MFA Session Token Generator
# @description Generates temporary AWS credentials using MFA authentication
# @version 2.2
# @requires aws-cli, mfa.cfg configuration file
# @usage ./aws_mfa.sh <token_code> [profile] [--dry-run|--test]
# @ai_optimization This script is designed for automation and AI workflows. Use --dry-run/--test to avoid unnecessary AWS calls and optimize token usage.

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Usage/help function
usage() {
    echo "Usage: $0 <MFA_TOKEN_CODE> [AWS_CLI_PROFILE] [--dry-run|--test] [--help|-h]"
    echo "  MFA_TOKEN_CODE: Code from MFA device"
    echo "  AWS_CLI_PROFILE: AWS profile (default: default)"
    echo "  --dry-run, --test  Show what would be done, do not call AWS"
    echo "  --help, -h     Show this help message"
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

if [[ $# -eq 0 ]]; then
    usage
fi

AWS_CLI_PROFILE=${2:-default}
MFA_TOKEN_CODE=$1
MFA_CONFIG="$SCRIPT_DIR/mfa.cfg"

check_aws_cli || exit 1

if [[ ! -r "$MFA_CONFIG" ]]; then
    log_error "Config file $MFA_CONFIG not found"
    log_error "Create mfa.cfg with format: profile_name=arn:aws:iam::account:mfa/username"
    exit 1
fi

ARN_OF_MFA=$(grep "^$AWS_CLI_PROFILE=" "$MFA_CONFIG" | cut -d'=' -f2- | tr -d '"')
if [[ -z "$ARN_OF_MFA" ]]; then
    log_error "No MFA ARN found for profile $AWS_CLI_PROFILE"
    exit 1
fi

log_info "Generating temporary credentials..."
log_info "Profile: $AWS_CLI_PROFILE"
log_info "MFA ARN: $ARN_OF_MFA"

if $DRY_RUN; then
    log_info "[DRY RUN] Would call: aws --profile $AWS_CLI_PROFILE sts get-session-token ..."
    log_info "[DRY RUN] Would save credentials to $HOME/.aws_temp_creds"
    exit 0
fi

aws --profile "$AWS_CLI_PROFILE" sts get-session-token \
    --duration-seconds 43200 \
    --serial-number "$ARN_OF_MFA" \
    --token-code "$MFA_TOKEN_CODE" \
    --output text | \
    awk '{printf("export AWS_ACCESS_KEY_ID=%s\nexport AWS_SECRET_ACCESS_KEY=%s\nexport AWS_SESSION_TOKEN=%s\n",$2,$4,$5)}' | \
    tee "$HOME/.aws_temp_creds"

log_info "Credentials saved to $HOME/.aws_temp_creds"
log_info "Run: source $HOME/.aws_temp_creds"
