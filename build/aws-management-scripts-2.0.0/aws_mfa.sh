#!/bin/bash

# @file aws_mfa.sh
# @brief AWS MFA Session Token Generator
# @description Generates temporary AWS credentials using MFA authentication
# @version 2.0
# @requires aws-cli, mfa.cfg configuration file
# @usage ./aws_mfa.sh <token_code> [profile]

set -euo pipefail

# @function check_aws_cli
# @brief Validates AWS CLI installation
# @return 1 if AWS CLI not found
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI not installed" >&2
        exit 1
    fi
}

# @function usage
# @brief Displays usage information and exits
usage() {
    echo "Usage: $0 <MFA_TOKEN_CODE> [AWS_CLI_PROFILE]"
    echo "  MFA_TOKEN_CODE: Code from MFA device"
    echo "  AWS_CLI_PROFILE: AWS profile (default: default)"
    exit 1
}

# @validation Input parameter validation
[[ $# -lt 1 || $# -gt 2 ]] && usage

check_aws_cli

# @var AWS_CLI_PROFILE AWS profile to use (default: default)
# @var MFA_TOKEN_CODE MFA token from user input
# @var SCRIPT_DIR Directory containing this script
# @var MFA_CONFIG Path to MFA configuration file
AWS_CLI_PROFILE=${2:-default}
MFA_TOKEN_CODE=$1
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MFA_CONFIG="$SCRIPT_DIR/mfa.cfg"

# @validation Configuration file validation
if [[ ! -r "$MFA_CONFIG" ]]; then
    echo "Error: Config file $MFA_CONFIG not found" >&2
    echo "Create mfa.cfg with format: profile_name=arn:aws:iam::account:mfa/username" >&2
    exit 1
fi

# @var ARN_OF_MFA MFA device ARN from configuration
ARN_OF_MFA=$(grep "^$AWS_CLI_PROFILE=" "$MFA_CONFIG" | cut -d'=' -f2- | tr -d '"')

# @validation MFA ARN validation
if [[ -z "$ARN_OF_MFA" ]]; then
    echo "Error: No MFA ARN found for profile $AWS_CLI_PROFILE" >&2
    exit 1
fi

echo "Generating temporary credentials..."
echo "Profile: $AWS_CLI_PROFILE"
echo "MFA ARN: $ARN_OF_MFA"

# @operation Generate temporary credentials using STS
# @duration 43200 seconds (12 hours)
# @output Exports AWS credentials to file
aws --profile "$AWS_CLI_PROFILE" sts get-session-token \
    --duration-seconds 43200 \
    --serial-number "$ARN_OF_MFA" \
    --token-code "$MFA_TOKEN_CODE" \
    --output text | \
    awk '{printf("export AWS_ACCESS_KEY_ID=%s\nexport AWS_SECRET_ACCESS_KEY=%s\nexport AWS_SESSION_TOKEN=%s\n",$2,$4,$5)}' | \
    tee "$HOME/.aws_temp_creds"

echo "Credentials saved to $HOME/.aws_temp_creds"
echo "Run: source $HOME/.aws_temp_creds"
