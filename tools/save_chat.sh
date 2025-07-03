
#!/bin/bash
# @file save_chat.sh
# @brief Save AI assistant chat history
# @usage ./save_chat.sh "conversation summary"
# @ai_optimization This script is designed for AI/automation workflows to persist chat and context. Integrate with orchestration scripts for audit and traceability.


set -euo pipefail

# Source shared utilities for logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

CHAT_DIR="./chat"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CHAT_FILE="$CHAT_DIR/session_$TIMESTAMP.md"

usage() {
    echo "Usage: $0 [summary] [--help|-h]"
    echo "  Saves AI assistant chat history with optional summary."
    echo "  --help, -h     Show this help message"
    exit 0
}
save_chat() {
    local summary="${1:-Manual save}"
    
    cat > "$CHAT_FILE" << EOF
# AI Assistant Chat History
**Session:** $(date '+%Y-%m-%d %H:%M:%S')

## Summary
$summary

## Context
- Project: AWS Management Scripts
- Status: $(git status --porcelain 2>/dev/null | wc -l) files modified
- Last commit: $(git log -1 --oneline 2>/dev/null || echo "No git history")

## Files Modified
$(find . -name "*.sh" -newer "$CHAT_DIR/../README.md" 2>/dev/null | head -10 || echo "No recent changes")
EOF
    
    echo "Chat saved: $CHAT_FILE"
    log_info "Chat saved: $CHAT_FILE"
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

if [[ $# -gt 0 ]]; then
    save_chat "$*"
else
    save_chat
fi