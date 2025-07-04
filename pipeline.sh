#!/bin/bash
# Complete pipeline: test/build/deploy/run with logging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log_utils.sh" 2>/dev/null || echo "Warning: log_utils not found"

# Pipeline stages
test_stage() {
    log_info "pipeline" "Starting test stage"
    start_time=$(date +%s)
    
    ./test/test_runner.sh > test_results.log 2>&1 || {
        log_error "pipeline" "Tests failed"
        return 1
    }
    
    end_time=$(date +%s)
    log_performance "test_stage" "$start_time" "$end_time"
    log_info "pipeline" "Tests passed"
}

build_stage() {
    log_info "pipeline" "Starting build stage"
    start_time=$(date +%s)
    
    # Build process
    chmod +x *.sh bin/*.sh tools/*.sh lib/*.sh 2>/dev/null || true
    
    # Validate main scripts
    for script in aws-cli.sh tools.sh aws.sh; do
        if [[ -f "$script" ]]; then
            bash -n "$script" || {
                log_error "pipeline" "Syntax error in $script"
                return 1
            }
        fi
    done
    
    end_time=$(date +%s)
    log_performance "build_stage" "$start_time" "$end_time"
    log_info "pipeline" "Build completed"
}

deploy_stage() {
    log_info "pipeline" "Starting deploy stage"
    start_time=$(date +%s)
    
    # Deployment simulation
    mkdir -p /tmp/aws-mgmt-deploy
    cp -r . /tmp/aws-mgmt-deploy/ 2>/dev/null || true
    
    end_time=$(date +%s)
    log_performance "deploy_stage" "$start_time" "$end_time"
    log_info "pipeline" "Deploy completed"
}

run_stage() {
    log_info "pipeline" "Starting run stage"
    start_time=$(date +%s)
    
    # Run main components
    ./aws-cli.sh --help >/dev/null 2>&1 || log_warn "pipeline" "aws-cli.sh issues"
    ./tools.sh --help >/dev/null 2>&1 || log_warn "pipeline" "tools.sh issues"
    
    # Generate analysis
    ./tools/log_analyzer.sh parse >/dev/null 2>&1 || log_warn "pipeline" "log analyzer issues"
    
    end_time=$(date +%s)
    log_performance "run_stage" "$start_time" "$end_time"
    log_info "pipeline" "Run stage completed"
}

analyze_results() {
    log_info "pipeline" "Analyzing pipeline results"
    
    # Generate comprehensive report
    {
        echo "# Pipeline Analysis Report - $(date)"
        echo "=================================="
        echo
        echo "## Test Results"
        tail -10 test_results.log 2>/dev/null || echo "No test results"
        echo
        echo "## Log Analysis"
        cat log_analysis_report.txt 2>/dev/null || echo "No log analysis"
        echo
        echo "## Performance Metrics"
        grep "PERF:" /tmp/aws-mgmt.log 2>/dev/null | tail -5 || echo "No performance data"
    } > pipeline_report.txt
    
    log_info "pipeline" "Analysis saved to pipeline_report.txt"
}

# Main pipeline execution
main() {
    log_info "pipeline" "Starting complete pipeline"
    pipeline_start=$(date +%s)
    
    case "${1:-all}" in
        "test") test_stage ;;
        "build") build_stage ;;
        "deploy") deploy_stage ;;
        "run") run_stage ;;
        "analyze") analyze_results ;;
        "all")
            test_stage && 
            build_stage && 
            deploy_stage && 
            run_stage && 
            analyze_results
            ;;
        *) 
            echo "Usage: $0 {test|build|deploy|run|analyze|all}"
            exit 1
            ;;
    esac
    
    pipeline_end=$(date +%s)
    log_performance "complete_pipeline" "$pipeline_start" "$pipeline_end"
    log_info "pipeline" "Pipeline completed successfully"
}

main "$@"