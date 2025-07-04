
#!/bin/bash
# @file aws-cli.sh
# @brief Main entry point for AWS Management Scripts
# @description Simple launcher for tools and automation

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log_utils.sh"
source "$SCRIPT_DIR/lib/aws_utils.sh"

usage() {
    echo "Usage: $0 [OPTION]"
    echo "  Main entry point for AWS Management Scripts."
    echo "  --help, -h           Show this help message"
    echo "  --select <option>    Run by option number (non-interactive)"
    echo "  --menu               Show interactive menu (default if no args)"
    echo
    echo "Options:"
    echo "  1  Tools Menu           (tools.sh)"
    echo "  2  Automation Client    (client/aws_client.sh)"
    echo "  3  Build System         (build.sh)"
    echo "  4  Deploy System        (deploy.sh)"
    echo "  0  Exit"
    echo
    echo "Examples:"
    echo "  $0 --select 1"
    exit 0
}

run_main() {
    case $1 in
        1) ./tools.sh ;;
        2) ./client/aws_client.sh ;;
        3) ./build.sh ;;
        4) ./deploy.sh ;;
        0) exit 0 ;;
        *) log_error "Invalid option" ;;
    esac
}

if [[ $# -eq 0 || $1 == "--menu" ]]; then
    log_info "🚀 AWS Management Scripts v2.0.0"
    echo "================================"
    echo
    echo "Choose your interface:"
    echo "1. Tools Menu           (tools.sh)"
    echo "2. Automation Client    (client/aws_client.sh)"
    echo "3. Build System         (build.sh)"
    echo "4. Deploy System        (deploy.sh)"
    echo "0. Exit"
    echo
    read -p "Select option [0-4]: " choice
    run_main "$choice"
    exit 0
fi

case $1 in
    --help|-h)
        usage
        ;;
    --select)
        if [[ -z "${2:-}" ]]; then log_error "Missing option for --select"; exit 1; fi
        run_main "$2"
        ;;
    *)
        log_error "Unknown argument: $1"; usage
        ;;
esac