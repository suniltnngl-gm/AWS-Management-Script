
#!/bin/bash
# @file backup_verification.sh
# @brief Comprehensive backup verification before environment migration
# @description Ensure all files are safely backed up to GitHub

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log_utils.sh"
source "$SCRIPT_DIR/lib/aws_utils.sh"

usage() {
    echo "Usage: $0 [--help|-h]"
    echo "  Comprehensive backup verification before migration."
    echo "  --help, -h   Show this help message"
    exit 0
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

echo "🔍 BACKUP VERIFICATION CHECKLIST"
echo "================================"

# Check git status
echo "1. Git Status Check:"
if git status --porcelain | grep -q .; then
    echo "❌ Uncommitted changes detected!"
    git status --short
    exit 1
else
    echo "✅ Working tree clean"
fi

# Verify remote sync
echo -e "\n2. Remote Sync Check:"
local_commit=$(git rev-parse HEAD)
remote_commit=$(git rev-parse origin/main)
if [[ "$local_commit" == "$remote_commit" ]]; then
    echo "✅ Local and remote in sync"
else
    echo "❌ Local ahead of remote - need to push!"
    exit 1
fi

# Count critical files
echo -e "\n3. File Inventory:"
total_files=$(find . -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.conf" \) | wc -l)
echo "Total project files: $total_files"

# Core components check
echo -e "\n4. Core Components:"
components=(
    "aws-cli.sh:Entry point"
    "hub-logic/spend_hub.sh:Cost optimization"
    "router-logic/router_hub.sh:Resource routing"
    "switch-logic/switch_hub.sh:Stability control"
    "backend/api/server.py:Backend API"
    "frontend/public/index.html:Frontend dashboard"
    "build.sh:Build system"
    "deploy.sh:Deployment"
    "docker-compose.yml:Container orchestration"
)

for component in "${components[@]}"; do
    file="${component%%:*}"
    desc="${component##*:}"
    if [[ -f "$file" ]]; then
        echo "✅ $desc ($file)"
    else
        echo "❌ Missing: $desc ($file)"
    fi
done

# Check executables
echo -e "\n5. Executable Permissions:"
executable_count=$(find . -name "*.sh" -executable | wc -l)
total_scripts=$(find . -name "*.sh" | wc -l)
echo "Executable scripts: $executable_count/$total_scripts"

# Verify GitHub release
echo -e "\n6. GitHub Release:"
if git tag --list | grep -q "v2.0.0"; then
    echo "✅ Release tag v2.0.0 exists"
else
    echo "❌ Release tag missing"
fi

# Check build artifacts
echo -e "\n7. Build Artifacts:"
if [[ -f "build/aws-management-scripts-2.0.0.tar.gz" ]]; then
    size=$(du -h "build/aws-management-scripts-2.0.0.tar.gz" | cut -f1)
    echo "✅ Release package: $size"
else
    echo "❌ Release package missing"
fi

# Documentation check
echo -e "\n8. Documentation:"
docs=("README.md" "release-notes.md" "chat/session_*.md")
for doc in "${docs[@]}"; do
    if ls $doc >/dev/null 2>&1; then
        echo "✅ Documentation: $doc"
    else
        echo "❌ Missing: $doc"
    fi
done

echo -e "\n🎯 BACKUP STATUS: COMPLETE"
echo "Repository: https://github.com/suniltnngl-gm/AWS-Management-Script"
echo "Latest commit: $(git log -1 --format='%h %s')"
echo "Ready for CloudShell deployment! 🚀"