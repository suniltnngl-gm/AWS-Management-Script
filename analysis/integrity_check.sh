#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Check for missing critical functions/files

echo "🔧 INTEGRITY CHECK"
echo "=================="

# Check main scripts have required functions
for script in aws-cli.sh tools.sh; do
    if [[ -f "$script" ]]; then
        echo "Checking $script..."
        if grep -q "main()" "$script"; then
            echo "✅ Has main() function"
        else
            echo "❌ Missing main() function"
        fi
    fi
done

# Check for missing imports/sources
echo -e "\n📋 MISSING DEPENDENCIES"
grep -r "source.*lib/" --include="*.sh" . | cut -d: -f2 | sort -u | while read -r dep; do
    file=$(echo "$dep" | sed 's/.*source[[:space:]]*"\([^"]*\)".*/\1/')
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing: $file"
    fi
done

echo -e "\nIntegrity check complete."