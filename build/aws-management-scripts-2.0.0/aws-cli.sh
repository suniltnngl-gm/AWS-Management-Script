#!/bin/bash

# @file aws-cli.sh
# @brief Main entry point for AWS Management Scripts
# @description Interactive menu for all AWS tools and integrations

set -euo pipefail

show_menu() {
    echo "AWS Management Scripts"
    echo "====================="
    echo "1. Resource Overview    (aws_manager.sh)"
    echo "2. MFA Authentication   (aws_mfa.sh)"
    echo "3. Billing Analysis     (billing.sh)"
    echo "4. CloudFront Audit     (cloudfront_audit.sh)"
    echo "5. Run Integrations     (integration_runner.sh)"
    echo "6. Automation Client    (client/aws_client.sh)"
    echo "7. Save Chat History    (save_chat.sh)"
    echo "0. Exit"
    echo
    read -p "Select option [0-7]: " choice
}

run_option() {
    case $1 in
        1) ./aws_manager.sh ;;
        2) read -p "MFA Token: " token; read -p "Profile [default]: " profile; ./aws_mfa.sh "$token" "${profile:-default}" ;;
        3) ./billing.sh ;;
        4) ./cloudfront_audit.sh ;;
        5) ./integration_runner.sh ;;
        6) ./client/aws_client.sh ;;
        7) read -p "Summary: " summary; ./save_chat.sh "$summary" ;;
        0) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
}

while true; do
    show_menu
    run_option "$choice"
    echo; read -p "Press Enter to continue..."
done