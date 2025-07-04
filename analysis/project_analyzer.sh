#!/bin/bash
# Project Analysis Tool - Find missing/broken files

set -euo pipefail

echo "🔍 PROJECT ANALYSIS REPORT"
echo "=========================="
echo "Date: $(date)"
echo "Path: $(pwd)"
echo

# File counts by type
echo "📊 FILE STATISTICS"
echo "Shell scripts: $(find . -name "*.sh" | wc -l)"
echo "Python files: $(find . -name "*.py" | wc -l)"
echo "Config files: $(find . -name "*.json" -o -name "*.yml" -o -name "*.yaml" | wc -l)"
echo "Docs: $(find . -name "*.md" | wc -l)"
echo

# Check main entry points
echo "🚀 MAIN ENTRY POINTS"
for file in aws-cli.sh aws.sh tools.sh; do
    if [[ -f "$file" ]]; then
        echo "✅ $file ($(wc -l < "$file") lines)"
    else
        echo "❌ $file MISSING"
    fi
done
echo

# Check critical directories
echo "📁 DIRECTORY STRUCTURE"
for dir in bin lib tools client; do
    if [[ -d "$dir" ]]; then
        count=$(find "$dir" -name "*.sh" | wc -l)
        echo "✅ $dir/ ($count scripts)"
    else
        echo "❌ $dir/ MISSING"
    fi
done
echo

# Find broken symlinks
echo "🔗 BROKEN LINKS"
find . -type l ! -exec test -e {} \; -print 2>/dev/null || echo "None found"
echo

# Check executable permissions
echo "⚡ EXECUTABLE STATUS"
find . -name "*.sh" ! -executable -print | head -5 | while read -r file; do
    echo "❌ Not executable: $file"
done
echo

# Find large files
echo "📦 LARGE FILES (>1MB)"
find . -type f -size +1M -exec ls -lh {} \; | awk '{print $5, $9}' | head -5
echo

# Git status
echo "📝 GIT STATUS"
git status --porcelain | head -10
echo

echo "Analysis complete. Check for ❌ items that need attention."