#!/bin/bash
# Fix project logging and analysis issues

set -euo pipefail

echo "🔧 FIXING PROJECT LOGGING & ANALYSIS"
echo "===================================="

# Fix import paths in all scripts
echo "1. Fixing import paths..."
find . -name "*.sh" -type f -exec grep -l "source.*lib/" {} \; | while read -r file; do
    if [[ -f "$file" ]]; then
        # Add SCRIPT_DIR pattern if missing
        if ! grep -q "SCRIPT_DIR.*dirname.*BASH_SOURCE" "$file"; then
            sed -i '1a\\nSCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"' "$file"
        fi
        
        # Fix relative paths
        sed -i 's|source "$(dirname "$0")/\.\./lib/|source "$SCRIPT_DIR/../lib/|g' "$file"
        sed -i 's|source "\./lib/|source "$SCRIPT_DIR/lib/|g' "$file"
    fi
done

# Fix tools.sh main function
echo "2. Adding main() to tools.sh..."
if ! grep -q "^main()" tools.sh; then
    cat >> tools.sh << 'EOF'

main() {
    echo "🛠️ AWS Management Tools"
    echo "======================"
    echo "1. MFA Authentication"
    echo "2. Save Chat History" 
    echo "3. Budget Recommendations"
    echo "4. Log Analysis"
    
    read -p "Select option (1-4): " choice
    case $choice in
        1) ./bin/mfa_aws.sh ;;
        2) read -p "Summary: " summary; echo "$summary" > "chat_$(date +%s).txt" ;;
        3) ./hub-logic/spend_hub.sh ;;
        4) ./tools/log_analyzer.sh parse ;;
        *) echo "Invalid option" ;;
    esac
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
EOF
fi

# Initialize logging
echo "3. Initializing logging system..."
mkdir -p /tmp/aws-mgmt
touch /tmp/aws-mgmt.log

# Test logging
echo "4. Testing logging..."
source lib/log_utils.sh 2>/dev/null || echo "Warning: log_utils.sh not found"
log_info "project-fix" "Project logging system initialized"

# Run analysis
echo "5. Running project analysis..."
./analysis/project_analyzer.sh > project_status.txt

echo "✅ Project fix complete!"
echo "📊 Check project_status.txt for current status"