#!/bin/bash

# @file backend/run.sh
# @brief Backend server runner
# @description Start Flask API server with proper environment

set -euo pipefail

# Source CI logging utilities
CI_LOG_FILE="run_results.log"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../bin/ci_log_utils.sh"

ci_log_stage "Run Step Started: $(date)"

# Setup Python environment
if [[ ! -d "venv" ]]; then
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

# Load environment variables
export FLASK_APP=api/server.py
export FLASK_ENV=development
export PYTHONPATH="${PYTHONPATH:-}:$(pwd)"

# Start server
echo "🚀 Starting AWS Management API Server..."
echo "📡 API available at: http://localhost:5000"
echo "📋 Endpoints:"
echo "  GET  /api/resources"
echo "  GET  /api/billing" 
echo "  GET  /api/audit/cloudfront"
echo "  POST /api/mfa"
echo "  GET  /api/integrations"

python3 api/server.py

ci_log_summary "Run Step Completed: $(date)"