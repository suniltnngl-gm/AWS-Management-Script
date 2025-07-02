#!/bin/bash

# @file tools.sh
# @brief Unified AWS Management Tools Entry Point
# @description Single interface for all AWS management tools and utilities

set -euo pipefail

show_tools_menu() {
    echo "🛠️  AWS Management Tools"
    echo "======================="
    echo "1. Resource Overview    (tools/aws_manager.sh)"
    echo "2. MFA Authentication   (tools/aws_mfa.sh)"
    echo "3. Billing Analysis     (tools/billing.sh)"
    echo "4. CloudFront Audit     (tools/cloudfront_audit.sh)"
    echo "5. Run Integrations     (tools/integration_runner.sh)"
    echo "6. Usage Summary        (tools/aws_usage.sh)"
    echo "7. Utilities            (tools/utils.sh)"
    echo "8. Save Chat History    (tools/save_chat.sh)"
    echo
    echo "🧠 Logic Hubs:"
    echo "H. Hub Logic            (hub-logic/spend_hub.sh)"
    echo "R. Router Logic         (router-logic/router_hub.sh)"
    echo "S. Switch Logic         (switch-logic/switch_hub.sh)"
    echo
    echo "0. Exit"
    echo
    read -p "Select option [1-8,H,R,S,0]: " choice
}

run_tool() {
    case $1 in
        1) ./tools/aws_manager.sh ;;
        2) read -p "MFA Token: " token; read -p "Profile [default]: " profile; ./tools/aws_mfa.sh "$token" "${profile:-default}" ;;
        3) ./tools/billing.sh ;;
        4) ./tools/cloudfront_audit.sh ;;
        5) ./tools/integration_runner.sh ;;
        6) ./tools/aws_usage.sh ;;
        7) ./tools/utils.sh ;;
        8) read -p "Summary: " summary; ./tools/save_chat.sh "$summary" ;;
        H|h) read -p "Budget [\$0]: " budget; ./hub-logic/spend_hub.sh recommend "${budget:-0}" ;;
        R|r) ./router-logic/router_hub.sh check ;;
        S|s) ./switch-logic/switch_hub.sh status ;;
        0) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
}

while true; do
    show_tools_menu
    run_tool "$choice"
    echo; read -p "Press Enter to continue..."
done