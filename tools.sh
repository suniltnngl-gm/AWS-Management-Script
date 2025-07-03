
#!/bin/bash
# @file tools.sh
# @brief Unified AWS Management Tools Entry Point
# @description Single interface for all AWS management tools and utilities

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tools/utils.sh"

usage() {
    echo "Usage: $0 [--help|-h]"
    echo "  Unified AWS Management Tools Entry Point."
    echo "  --help, -h     Show this help message"
    exit 0
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

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

usage() {
    echo "Usage: $0 [OPTION] [ARGS...]"
    echo "  Unified AWS Management Tools Entry Point."
    echo "  --help, -h           Show this help message"
    echo "  --select <option>    Run tool by option number or letter (non-interactive)"
    echo "  --mfa <token> <profile>  Run MFA Authentication non-interactively"
    echo "  --save-chat <summary>     Save chat history non-interactively"
    echo "  --budget <amount>         Run Hub Logic recommend non-interactively"
    echo "  --menu                Show interactive menu (default if no args)"
    echo "  --test                Dry-run: print actions but do not execute"
    echo
    echo "Examples:"
    echo "  $0 --select 1"
    echo "  $0 --mfa 123456 default"
    echo "  $0 --save-chat 'My summary'"
    echo "  $0 --budget 1000"
    echo "  $0 --test --select 1"
    exit 0
}
TEST_MODE=false
for arg in "$@"; do
    if [[ "$arg" == "--test" ]]; then
        TEST_MODE=true
    fi
done

if [[ $# -eq 0 || $1 == "--menu" ]]; then
    show_tools_menu() {
        log_info "AWS Management Tools"
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
        run_tool "$choice"
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
            *) log_error "Invalid option" ;;
        esac
        echo; read -p "Press Enter to continue..."
        show_tools_menu
    }
    show_tools_menu
    exit 0
fi

case $1 in
    --help|-h)
        usage
        ;;
    --select)
        if [[ -z "${2:-}" ]]; then log_error "Missing option for --select"; exit 1; fi
        run_tool() {
            case $1 in
                1) ./tools/aws_manager.sh ;;
                2) ./tools/aws_mfa.sh ;;
                3) ./tools/billing.sh ;;
                4) ./tools/cloudfront_audit.sh ;;
                5) ./tools/integration_runner.sh ;;
                6) ./tools/aws_usage.sh ;;
                7) ./tools/utils.sh ;;
                8) ./tools/save_chat.sh ;;
                H|h) ./hub-logic/spend_hub.sh recommend ;;
                R|r) ./router-logic/router_hub.sh check ;;
                S|s) ./switch-logic/switch_hub.sh status ;;
                0) exit 0 ;;
                *) log_error "Invalid option" ;;
            esac
        }
run_tool() {
    if [ "$TEST_MODE" = true ]; then
        log_info "[TEST MODE] Would execute: $1"
        return
    fi
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
        *) log_error "Invalid option" ;;
    esac
}
esac