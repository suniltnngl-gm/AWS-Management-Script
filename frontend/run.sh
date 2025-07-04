#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enhanced logging
source "$SCRIPT_DIR/../lib/log_utils.sh" 2>/dev/null || true

# @file frontend/run.sh
# @brief Frontend development server
# @description Start frontend development server

set -euo pipefail

echo "🌐 Starting AWS Management Frontend..."
echo "📱 Dashboard available at: http://localhost:3000"
echo "🔗 Make sure backend is running at: http://localhost:5000"
echo ""

# Check if backend is running
if curl -s http://localhost:5000/api/resources >/dev/null 2>&1; then
    echo "✅ Backend API is running"
else
    echo "⚠️  Backend API not detected - start with: cd backend && ./run.sh"
fi

echo ""
echo "Press Ctrl+C to stop frontend server"

# Start frontend server
python3 server.py