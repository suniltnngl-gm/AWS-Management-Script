#!/bin/bash

# AWS CloudShell One-Click Deployment
# Deploys AWS Cost Management Platform in CloudShell

echo "☁️ AWS CloudShell Deployment"
echo "============================"
echo

# Install dependencies
echo "📦 Installing dependencies..."
pip3 install flask requests --user --quiet

# Test AWS access (should work automatically in CloudShell)
echo "🔐 Testing AWS access..."
if aws sts get-caller-identity >/dev/null 2>&1; then
    echo "✅ AWS credentials working!"
else
    echo "⚠️ AWS access issue - check CloudShell permissions"
fi

# Test tools
echo "🧪 Testing cost management tools..."
python3 casual_dev.py costs

echo
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================="
echo
echo "🚀 Available commands:"
echo "  python3 casual_dev.py costs        # Check your real AWS costs"
echo "  python3 casual_dev.py emergency 100 # Emergency cost control"
echo "  python3 small_business.py overview 50 # Small business tools"
echo "  python3 app.py web                 # Launch web dashboard"
echo
echo "💰 Start saving money with real AWS data!"
echo "📊 All tools have access to your actual AWS resources!"