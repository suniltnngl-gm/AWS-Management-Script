#!/bin/bash

# @file tools/log_analyzer.sh
# @brief Log analysis and monitoring tool
# @description Phase 3: Log Analysis Tools implementation

set -euo pipefail

source "$(dirname "$0")/../lib/log_utils.sh" 2>/dev/null || true

LOG_DIR="/tmp"
ANALYSIS_OUTPUT="log_analysis_report.txt"

# @function parse_logs
# @brief Parse and categorize log entries
parse_logs() {
    local log_file="${1:-$LOG_FILE}"
    
    if [[ ! -f "$log_file" ]]; then
        log_error "Log file not found: $log_file"
        return 1
    fi
    
    log_info "Parsing logs from $log_file"
    
    {
        echo "# Log Analysis Report - $(date)"
        echo "# Source: $log_file"
        echo "# =========================="
        echo
        
        # Error detection
        echo "## Error Summary"
        local error_count=$(grep -c "\[ERROR\]" "$log_file" 2>/dev/null || echo "0")
        local warn_count=$(grep -c "\[WARN\]" "$log_file" 2>/dev/null || echo "0")
        echo "Errors: $error_count"
        echo "Warnings: $warn_count"
        
        if [[ $error_count -gt 0 ]]; then
            echo
            echo "### Recent Errors:"
            grep "\[ERROR\]" "$log_file" | tail -5
        fi
        
        # Performance metrics
        echo
        echo "## Performance Metrics"
        grep "PERF:" "$log_file" 2>/dev/null | tail -10 || echo "No performance data found"
        
        # Usage statistics
        echo
        echo "## Usage Statistics"
        echo "Total log entries: $(wc -l < "$log_file")"
        echo "Analysis entries: $(grep -c "ANALYSIS:" "$log_file" 2>/dev/null || echo "0")"
        echo "Info entries: $(grep -c "\[INFO\]" "$log_file" 2>/dev/null || echo "0")"
        
    } > "$ANALYSIS_OUTPUT"
    
    log_info "Log analysis saved to $ANALYSIS_OUTPUT"
}

# @function monitor_errors
# @brief Real-time error monitoring
monitor_errors() {
    local log_file="${1:-$LOG_FILE}"
    local threshold="${2:-5}"
    
    log_info "Monitoring errors in $log_file (threshold: $threshold)"
    
    while true; do
        local recent_errors=$(tail -100 "$log_file" 2>/dev/null | grep -c "\[ERROR\]" || echo "0")
        
        if [[ $recent_errors -ge $threshold ]]; then
            log_error "ALERT: $recent_errors errors in last 100 entries"
            
            # Generate alert report
            {
                echo "# ERROR ALERT - $(date)"
                echo "Threshold exceeded: $recent_errors >= $threshold"
                echo
                echo "Recent errors:"
                tail -100 "$log_file" | grep "\[ERROR\]" | tail -5
            } > "error_alert_$(date +%s).txt"
        fi
        
        sleep 30
    done
}

# @function generate_usage_stats
# @brief Generate usage statistics
generate_usage_stats() {
    local log_file="${1:-$LOG_FILE}"
    
    {
        echo "# Usage Statistics Report"
        echo "# Generated: $(date)"
        echo "# ========================"
        echo
        
        # Component usage
        echo "## Component Usage"
        grep "ANALYSIS:" "$log_file" 2>/dev/null | cut -d':' -f3 | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -10
        
        # Hourly activity
        echo
        echo "## Hourly Activity"
        grep -o "\[20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:" "$log_file" 2>/dev/null | sort | uniq -c | tail -24
        
        # Performance trends
        echo
        echo "## Performance Trends"
        grep "PERF:" "$log_file" 2>/dev/null | tail -20
        
    } > "usage_stats_$(date +%Y%m%d).txt"
    
    log_info "Usage statistics generated"
}

case "${1:-help}" in
    "parse") parse_logs "${2:-}" ;;
    "monitor") monitor_errors "$2" "$3" ;;
    "stats") generate_usage_stats "$2" ;;
    "help"|*)
        echo "Usage: $0 {parse|monitor|stats} [args...]"
        echo "  parse [logfile]           - Parse and analyze logs"
        echo "  monitor [logfile] [threshold] - Monitor for errors"
        echo "  stats [logfile]           - Generate usage statistics"
        ;;
esac