#!/bin/bash

# @file aws-cli.sh
# @brief Main entry point for AWS Management Scripts
# @description Simple launcher for tools and automation

set -euo pipefail

echo "🚀 AWS Management Scripts v2.0.0"
echo "================================"
echo
echo "Choose your interface:"
echo "1. Tools Menu           (tools.sh)"
echo "2. Automation Client    (client/aws_client.sh)"
echo "3. Build System         (build.sh)"
echo "4. Deploy System        (deploy.sh)"
echo "0. Exit"
echo

read -p "Select option [0-4]: " choice

case $choice in
    1) ./tools.sh ;;
    2) ./client/aws_client.sh ;;
    3) ./build.sh ;;
    4) ./deploy.sh ;;
    0) exit 0 ;;
    *) echo "Invalid option" ;;
esac