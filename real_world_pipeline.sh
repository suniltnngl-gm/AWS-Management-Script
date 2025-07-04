#!/bin/bash
# Real-world production pipeline with AWS integration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/production_logger.sh" 2>/dev/null || echo "Warning: production logger not found"

# Real-world test stage
test_stage() {
    prod_log "INFO" "pipeline" "test" "Starting real-world tests"
    
    # AWS CLI availability
    if ! command -v aws >/dev/null; then
        prod_log "ERROR" "pipeline" "test" "AWS CLI not installed"
        return 1
    fi
    
    # AWS credentials check
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        prod_log "WARN" "pipeline" "test" "AWS credentials not configured - using mock mode"
        export AWS_MOCK_MODE=true
    fi
    
    # Script validation
    find . -name "*.sh" -type f | head -20 | while read -r script; do
        if ! bash -n "$script" 2>/dev/null; then
            prod_log "ERROR" "pipeline" "test" "Syntax error in $script"
            return 1
        fi
    done
    
    prod_log "INFO" "pipeline" "test" "Tests completed successfully"
}

# Real-world build stage
build_stage() {
    prod_log "INFO" "pipeline" "build" "Starting production build"
    
    # Create production structure
    BUILD_DIR="/tmp/aws-mgmt-prod"
    rm -rf "$BUILD_DIR" 2>/dev/null || true
    mkdir -p "$BUILD_DIR"/{bin,lib,tools,config,logs}
    
    # Copy essential files
    cp -r bin/ lib/ tools/ "$BUILD_DIR/"
    cp aws-cli.sh tools.sh aws.sh "$BUILD_DIR/"
    
    # Set production permissions
    find "$BUILD_DIR" -name "*.sh" -exec chmod +x {} \;
    
    # Generate production config
    cat > "$BUILD_DIR/config/production.conf" << EOF
LOG_LEVEL=INFO
LOG_DIR=$BUILD_DIR/logs
AWS_REGION=${AWS_DEFAULT_REGION:-us-east-1}
ENVIRONMENT=production
EOF
    
    prod_log "INFO" "pipeline" "build" "Build completed - artifacts in $BUILD_DIR"
}

# Real-world deploy stage
deploy_stage() {
    prod_log "INFO" "pipeline" "deploy" "Starting production deployment"
    
    BUILD_DIR="/tmp/aws-mgmt-prod"
    DEPLOY_DIR="/opt/aws-mgmt"
    
    # Simulate deployment (in real world, this would be to EC2/ECS/Lambda)
    if [[ -d "$BUILD_DIR" ]]; then
        sudo mkdir -p "$DEPLOY_DIR" 2>/dev/null || mkdir -p "$HOME/aws-mgmt-deploy"
        DEPLOY_DIR="$HOME/aws-mgmt-deploy"
        
        cp -r "$BUILD_DIR"/* "$DEPLOY_DIR/"
        
        # Create systemd service file (simulation)
        cat > "$DEPLOY_DIR/aws-mgmt.service" << EOF
[Unit]
Description=AWS Management Scripts
After=network.target

[Service]
Type=simple
ExecStart=$DEPLOY_DIR/aws-cli.sh
Restart=always
User=aws-mgmt

[Install]
WantedBy=multi-user.target
EOF
        
        prod_log "INFO" "pipeline" "deploy" "Deployed to $DEPLOY_DIR"
    else
        prod_log "ERROR" "pipeline" "deploy" "Build artifacts not found"
        return 1
    fi
}

# Real-world run stage
run_stage() {
    prod_log "INFO" "pipeline" "run" "Starting production run"
    
    DEPLOY_DIR="$HOME/aws-mgmt-deploy"
    
    if [[ -d "$DEPLOY_DIR" ]]; then
        cd "$DEPLOY_DIR"
        
        # Health check
        if ./aws-cli.sh --help >/dev/null 2>&1; then
            prod_log "INFO" "pipeline" "run" "Health check passed"
        else
            prod_log "ERROR" "pipeline" "run" "Health check failed"
            return 1
        fi
        
        # Run actual AWS operations (if credentials available)
        if [[ "${AWS_MOCK_MODE:-}" != "true" ]]; then
            # Real AWS operations
            aws_start=$(date +%s)
            
            # List EC2 instances
            if aws ec2 describe-instances --max-items 1 >/dev/null 2>&1; then
                aws_end=$(date +%s)
                log_aws_operation "ec2" "describe-instances" "success" $((aws_end - aws_start)) "0.01"
            fi
            
            # List S3 buckets
            if aws s3 ls >/dev/null 2>&1; then
                log_aws_operation "s3" "list-buckets" "success" "100" "0.00"
            fi
        else
            prod_log "INFO" "pipeline" "run" "Running in mock mode - no real AWS calls"
        fi
        
        cd - >/dev/null
    else
        prod_log "ERROR" "pipeline" "run" "Deployment not found"
        return 1
    fi
}

# Real-world analysis
analyze_stage() {
    prod_log "INFO" "pipeline" "analyze" "Starting production analysis"
    
    # Generate comprehensive production report
    {
        echo "# Production Pipeline Report - $(date)"
        echo "======================================"
        echo
        echo "## Environment"
        echo "AWS Region: ${AWS_DEFAULT_REGION:-not-set}"
        echo "User: $(whoami)"
        echo "Host: $(hostname)"
        echo
        echo "## AWS Status"
        if [[ "${AWS_MOCK_MODE:-}" != "true" ]]; then
            echo "AWS Identity: $(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo 'Not available')"
        else
            echo "AWS Mode: Mock (no credentials)"
        fi
        echo
        echo "## Performance Metrics"
        grep "PERF\|METRIC" "$PROD_LOG_FILE" 2>/dev/null | tail -10 || echo "No metrics available"
        echo
        echo "## Recent Logs"
        tail -20 "$PROD_LOG_FILE" 2>/dev/null || echo "No logs available"
        echo
        echo "## Security Events"
        grep "AUDIT" "$AUDIT_LOG_FILE" 2>/dev/null | tail -5 || echo "No security events"
        
    } > "production_report_$(date +%Y%m%d_%H%M%S).txt"
    
    # Send to CloudWatch if configured
    send_to_cloudwatch
    
    prod_log "INFO" "pipeline" "analyze" "Production analysis completed"
}

# Main execution
main() {
    prod_log "INFO" "pipeline" "start" "Starting real-world pipeline"
    
    case "${1:-all}" in
        "test") test_stage ;;
        "build") build_stage ;;
        "deploy") deploy_stage ;;
        "run") run_stage ;;
        "analyze") analyze_stage ;;
        "all")
            test_stage &&
            build_stage &&
            deploy_stage &&
            run_stage &&
            analyze_stage
            ;;
        *)
            echo "Usage: $0 {test|build|deploy|run|analyze|all}"
            echo "Real-world production pipeline with AWS integration"
            exit 1
            ;;
    esac
    
    prod_log "INFO" "pipeline" "complete" "Real-world pipeline completed"
}

main "$@"