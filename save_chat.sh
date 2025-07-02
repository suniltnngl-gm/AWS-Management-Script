#!/bin/bash

# @file save_chat.sh
# @brief Save AI assistant chat history
# @usage ./save_chat.sh "conversation summary"

set -euo pipefail

CHAT_DIR="./chat"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CHAT_FILE="$CHAT_DIR/session_$TIMESTAMP.md"

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
}

[[ $# -gt 0 ]] && save_chat "$*" || save_chat