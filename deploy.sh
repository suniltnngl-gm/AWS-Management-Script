
#!/bin/bash
# @file deploy.sh
# @brief Deploy AWS Management Scripts
# @description Multi-target deployment script

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tools/utils.sh"

usage() {
    echo "Usage: $0 [local|docker|github|s3|backend|frontend|--help|-h]"
    echo "  local        Deploy locally"
    echo "  docker       Deploy with Docker"
    echo "  github       Prepare GitHub release"
    echo "  s3           Deploy to S3"
    echo "  backend      Deploy backend API"
    echo "  frontend     Deploy frontend dashboard"
    echo "  --help, -h   Show this help message"
    exit 0
}

if [[ $# -gt 0 && ( $1 == "--help" || $1 == "-h" ) ]]; then
    usage
fi

VERSION="2.0.0"
PACKAGE="aws-management-scripts-$VERSION.tar.gz"

deploy_local() {
    echo "Deploying locally..."
    local install_dir="$HOME/.local/bin/aws-management"
    mkdir -p "$HOME/.local/bin"
    
    tar -xzf "build/$PACKAGE" -C "$HOME/.local/bin/"
    ln -sf "$install_dir/aws-management-scripts-$VERSION/aws-cli.sh" "$HOME/.local/bin/aws-mgmt"
    
    echo "✅ Installed to: $install_dir"
    echo "🚀 Run: aws-mgmt"
}

deploy_docker() {
    echo "Creating Docker image..."
    cat > Dockerfile << EOF
FROM alpine:latest
RUN apk add --no-cache bash curl jq aws-cli
WORKDIR /app
COPY build/aws-management-scripts-$VERSION/ .
RUN chmod +x *.sh
ENTRYPOINT ["./aws-cli.sh"]
EOF
    
    docker build -t aws-management:$VERSION . && echo "✅ Docker image created"
}

deploy_github() {
    echo "Preparing GitHub release..."
    
    # Create release info
    cat > release-notes.md << EOF
# AWS Management Scripts v$VERSION

## Features
- Interactive AWS resource management
- Multi-tool integrations (Slack, CloudWatch, Terraform)
- Automated monitoring and alerting
- Resilient architecture with state management

## Installation
\`\`\`bash
tar -xzf aws-management-scripts-$VERSION.tar.gz
cd aws-management-scripts-$VERSION
./aws-cli.sh
\`\`\`
EOF
    
    echo "✅ Release notes created"
    echo "📦 Upload: build/$PACKAGE"
}

deploy_s3() {
    local bucket="${1:-aws-management-releases}"
    echo "Deploying to S3: s3://$bucket/"
    
    aws s3 cp "build/$PACKAGE" "s3://$bucket/releases/" && \
    aws s3 cp "build/$PACKAGE" "s3://$bucket/latest.tar.gz" && \
    echo "✅ Deployed to S3"
}

deploy_backend() {
    echo "Deploying backend API..."
    cd backend
    docker build -t aws-management-api:$VERSION .
    cd ..
    echo "✅ Backend API image created"
}

deploy_frontend() {
    echo "Deploying frontend dashboard..."
    cd frontend
    docker build -t aws-management-frontend:$VERSION .
    cd ..
    echo "✅ Frontend dashboard image created"
}

deploy_fullstack() {
    echo "Deploying full stack..."
    docker-compose build
    docker-compose up -d
    echo "✅ Full stack deployed at http://localhost:3000"
}

case "${1:-local}" in
    "local") deploy_local ;;
    "docker") deploy_docker ;;
    "backend") deploy_backend ;;
    "frontend") deploy_frontend ;;
    "fullstack") deploy_fullstack ;;
    "github") deploy_github ;;
    "s3") deploy_s3 "${2:-}" ;;
    "all") deploy_local && deploy_docker && deploy_backend && deploy_frontend && deploy_github ;;
    *) echo "Usage: $0 [local|docker|backend|frontend|fullstack|github|s3|all]" ;;
esac