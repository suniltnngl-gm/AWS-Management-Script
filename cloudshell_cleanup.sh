#!/bin/bash

# CloudShell Cleanup Script
# Clean up CloudShell environment and optimize storage

echo "🧹 CloudShell Cleanup"
echo "===================="

# Clean up temporary files
echo "📁 Cleaning temporary files..."
rm -rf /tmp/* 2>/dev/null || true
rm -rf ~/.cache/* 2>/dev/null || true

# Clean up old logs
echo "📝 Cleaning old logs..."
find . -name "*.log" -mtime +7 -delete 2>/dev/null || true
find . -name "*.jsonl" -size +10M -delete 2>/dev/null || true

# Clean up Python cache
echo "🐍 Cleaning Python cache..."
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

# Clean up old AWS CLI cache
echo "☁️ Cleaning AWS CLI cache..."
rm -rf ~/.aws/cli/cache/* 2>/dev/null || true

# Show storage usage
echo "💾 Storage usage:"
du -sh . 2>/dev/null || echo "Unable to check storage"

# Clean up old git files
echo "🔄 Cleaning git cache..."
git gc --prune=now 2>/dev/null || true

echo "✅ CloudShell cleanup complete!"
echo "💡 Freed up space for better performance"