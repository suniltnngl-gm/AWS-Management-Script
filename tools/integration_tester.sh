#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# @file tools/integration_tester.sh
# @brief Phase 4: Integration & Testing implementation
# @description Test logging integration across all components

set -euo pipefail

source "$SCRIPT_DIR/../lib/log_utils.sh" 2>/dev/null || true

TEST_LOG="/tmp/integration_test.log"
RESULTS_FILE="integration_test_results.txt"

# @function test_logging_integration
# @brief Test logging across all components
test_logging_integration() {
    log_info "Starting integration testing"
    
    local test_count=0
    local pass_count=0
    local fail_count=0
    
    {
        echo "# Integration Test Results - $(date)"
        echo "# =================================="
        echo
        
        # Test main components
        local components=(
            "aws-cli.sh"
            "tools.sh"
            "hub-logic/spend_hub.sh"
            "router-logic/router_hub.sh"
            "switch-logic/switch_hub.sh"
        )
        
        for component in "${components[@]}"; do
            if [[ -f "$component" ]]; then
                test_count=$((test_count + 1))
                echo "## Testing: $component"
                
                # Syntax test
                if bash -n "$component" 2>/dev/null; then
                    echo "  ✅ Syntax: PASS"
                    pass_count=$((pass_count + 1))
                else
                    echo "  ❌ Syntax: FAIL"
                    fail_count=$((fail_count + 1))
                fi
                
                # Logging integration test
                if grep -q "log_utils\|log(" "$component" 2>/dev/null; then
                    echo "  ✅ Logging: INTEGRATED"
                else
                    echo "  ⚠️  Logging: NOT INTEGRATED"
                fi
                
                echo
            fi
        done
        
        echo "## Test Summary"
        echo "Total tests: $test_count"
        echo "Passed: $pass_count"
        echo "Failed: $fail_count"
        echo "Success rate: $(( pass_count * 100 / test_count ))%"
        
    } > "$RESULTS_FILE"
    
    log_info "Integration test results saved to $RESULTS_FILE"
}

# @function performance_test
# @brief Test performance with logging enabled
performance_test() {
    log_info "Running performance tests"
    
    local start_time=$(date +%s)
    
    # Test file analysis performance
    bash tools/enhanced_analyzer.sh structure >/dev/null 2>&1
    
    local end_time=$(date +%s)
    log_performance "File analysis" "$start_time" "$end_time"
    
    # Test log parsing performance
    start_time=$(date +%s)
    bash tools/log_analyzer.sh parse "$LOG_FILE" >/dev/null 2>&1
    end_time=$(date +%s)
    log_performance "Log parsing" "$start_time" "$end_time"
}

# @function validate_analysis_accuracy
# @brief Validate analysis accuracy
validate_analysis_accuracy() {
    log_info "Validating analysis accuracy"
    
    # Create test files for validation
    local test_dir="/tmp/test_validation"
    mkdir -p "$test_dir"
    
    # Create test shell script
    cat > "$test_dir/test_valid.sh" << 'EOF'
#!/bin/bash
set -euo pipefail
echo "Valid test script"
EOF
    
    # Create invalid shell script
    cat > "$test_dir/test_invalid.sh" << 'EOF'
#!/bin/bash
echo "Invalid script
EOF
    
    # Run analysis
    bash tools/enhanced_analyzer.sh shell >/dev/null 2>&1
    
    # Validate results
    if grep -q "test_valid.sh.*✅.*Syntax: Valid" shell_analysis.txt 2>/dev/null; then
        log_analysis "Validation" "PASS" "Valid script correctly identified"
    else
        log_analysis "Validation" "FAIL" "Valid script not identified"
    fi
    
    # Cleanup
    rm -rf "$test_dir"
}

# Main execution
case "${1:-all}" in
    "integration") test_logging_integration ;;
    "performance") performance_test ;;
    "validate") validate_analysis_accuracy ;;
    "all")
        test_logging_integration
        performance_test
        validate_analysis_accuracy
        log_info "All integration tests completed"
        ;;
    *)
        echo "Usage: $0 {integration|performance|validate|all}"
        ;;
esac