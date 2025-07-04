#!/bin/bash

# @file tools/file_analyzer.sh
# @brief Comprehensive file analysis and metrics tool
# @description Reusable analysis framework for all project files

set -euo pipefail

# Source logging utilities
source "$(dirname "$0")/../lib/log_utils.sh" 2>/dev/null || {
    mkdir -p "$(dirname "$0")/../lib"
    cat > "$(dirname "$0")/../lib/log_utils.sh" << 'EOF'
#!/bin/bash
# Logging utilities
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FILE=${LOG_FILE:-/tmp/aws-mgmt.log}

log() {
    local level=$1; shift
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $*" | tee -a "$LOG_FILE"
}

log_info() { [[ "$LOG_LEVEL" =~ (DEBUG|INFO) ]] && log "INFO" "$@"; }
log_warn() { [[ "$LOG_LEVEL" =~ (DEBUG|INFO|WARN) ]] && log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && log "DEBUG" "$@"; }
EOF
    source "$(dirname "$0")/../lib/log_utils.sh"
}

# @function analyze_file
# @brief Comprehensive file analysis
analyze_file() {
    local file="$1"
    local analysis_type="${2:-full}"
    
    log_info "Analyzing file: $file"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    local metrics=()
    
    # Basic metrics
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    local lines=$(wc -l < "$file" 2>/dev/null || echo "0")
    local words=$(wc -w < "$file" 2>/dev/null || echo "0")
    
    metrics+=("SIZE:$size" "LINES:$lines" "WORDS:$words")
    
    # File type analysis
    local extension="${file##*.}"
    local file_type="unknown"
    
    case "$extension" in
        sh) file_type="shell"; analyze_shell_file "$file" ;;
        py) file_type="python"; analyze_python_file "$file" ;;
        js) file_type="javascript"; analyze_js_file "$file" ;;
        md) file_type="markdown" ;;
        json) file_type="json"; analyze_json_file "$file" ;;
        yml|yaml) file_type="yaml" ;;
    esac
    
    metrics+=("TYPE:$file_type")
    
    # Output results
    printf "ANALYSIS:%s|%s\n" "$file" "$(IFS='|'; echo "${metrics[*]}")"
    
    log_debug "Analysis complete for $file"
}

# @function analyze_shell_file
# @brief Shell script specific analysis
analyze_shell_file() {
    local file="$1"
    
    # Syntax check
    if bash -n "$file" 2>/dev/null; then
        echo "SYNTAX:valid"
    else
        echo "SYNTAX:invalid"
        log_warn "Syntax error in $file"
    fi
    
    # Function count
    local func_count=$(grep -c "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" "$file" 2>/dev/null || echo "0")
    echo "FUNCTIONS:$func_count"
    
    # Shebang check
    if head -1 "$file" | grep -q "^#!"; then
        echo "SHEBANG:present"
    else
        echo "SHEBANG:missing"
        log_warn "Missing shebang in $file"
    fi
}

# @function analyze_python_file
# @brief Python file specific analysis
analyze_python_file() {
    local file="$1"
    
    # Syntax check
    if python3 -m py_compile "$file" 2>/dev/null; then
        echo "SYNTAX:valid"
    else
        echo "SYNTAX:invalid"
        log_warn "Python syntax error in $file"
    fi
    
    # Import count
    local import_count=$(grep -c "^import\|^from.*import" "$file" 2>/dev/null || echo "0")
    echo "IMPORTS:$import_count"
}

# @function analyze_js_file
# @brief JavaScript file specific analysis
analyze_js_file() {
    local file="$1"
    
    # Basic validation
    if command -v node >/dev/null 2>&1; then
        if node -c "$file" 2>/dev/null; then
            echo "SYNTAX:valid"
        else
            echo "SYNTAX:invalid"
            log_warn "JavaScript syntax error in $file"
        fi
    else
        echo "SYNTAX:unchecked"
    fi
}

# @function analyze_json_file
# @brief JSON file specific analysis
analyze_json_file() {
    local file="$1"
    
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$file" 2>/dev/null; then
            echo "SYNTAX:valid"
        else
            echo "SYNTAX:invalid"
            log_warn "Invalid JSON in $file"
        fi
    elif python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        echo "SYNTAX:valid"
    else
        echo "SYNTAX:invalid"
        log_warn "Invalid JSON in $file"
    fi
}

# @function analyze_directory
# @brief Analyze all files in directory
analyze_directory() {
    local dir="${1:-.}"
    local output_file="${2:-analysis_report.txt}"
    
    log_info "Starting directory analysis: $dir"
    
    {
        echo "# File Analysis Report - $(date)"
        echo "# Directory: $dir"
        echo "# Format: ANALYSIS:file|metric1:value1|metric2:value2|..."
        echo
        
        find "$dir" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) | while read -r file; do
            analyze_file "$file"
        done
        
        echo
        echo "# Analysis completed: $(date)"
    } > "$output_file"
    
    log_info "Analysis report saved: $output_file"
}

# @function generate_summary
# @brief Generate analysis summary
generate_summary() {
    local report_file="${1:-analysis_report.txt}"
    
    if [[ ! -f "$report_file" ]]; then
        log_error "Report file not found: $report_file"
        return 1
    fi
    
    echo "📊 Analysis Summary"
    echo "=================="
    
    local total_files=$(grep -c "^ANALYSIS:" "$report_file" 2>/dev/null || echo "0")
    echo "Total files analyzed: $total_files"
    
    # File type breakdown
    echo
    echo "File types:"
    grep "^ANALYSIS:" "$report_file" | cut -d'|' -f2- | grep -o "TYPE:[^|]*" | sort | uniq -c | while read -r count type; do
        echo "  ${type#TYPE:}: $count"
    done
    
    # Syntax issues
    echo
    local syntax_errors=$(grep "SYNTAX:invalid" "$report_file" | wc -l)
    if [[ $syntax_errors -gt 0 ]]; then
        echo "⚠️  Syntax errors found: $syntax_errors files"
        grep "SYNTAX:invalid" "$report_file" | cut -d'|' -f1 | sed 's/ANALYSIS:/  - /'
    else
        echo "✅ No syntax errors found"
    fi
}

# Main execution
case "${1:-help}" in
    "file") analyze_file "$2" "${3:-full}" ;;
    "dir") analyze_directory "$2" "${3:-analysis_report.txt}" ;;
    "summary") generate_summary "$2" ;;
    "help"|*)
        echo "Usage: $0 {file|dir|summary} [args...]"
        echo "  file <path> [type]     - Analyze single file"
        echo "  dir <path> [output]    - Analyze directory"
        echo "  summary [report]       - Generate summary"
        ;;
esac