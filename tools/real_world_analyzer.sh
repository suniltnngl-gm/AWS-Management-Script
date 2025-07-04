#!/bin/bash

# @file tools/real_world_analyzer.sh
# @brief Real-world AWS analysis with production logging
# @description Enhanced analysis for production AWS environments

set -euo pipefail

source "$(dirname "$0")/../lib/production_logger.sh"

# @function analyze_aws_costs
# @brief Real-world cost analysis with detailed breakdown
analyze_aws_costs() {
    local start_date="${1:-$(date -d '30 days ago' '+%Y-%m-%d')}"
    local end_date="${2:-$(date '+%Y-%m-%d')}"
    
    prod_log "INFO" "cost-analyzer" "start" "Analyzing costs from $start_date to $end_date"
    
    local analysis_start=$(date +%s%3N)
    
    # Get cost data from AWS
    local cost_data=$(aws ce get-cost-and-usage \
        --time-period Start="$start_date",End="$end_date" \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE 2>/dev/null || echo '{"ResultsByTime":[]}')
    
    local analysis_end=$(date +%s%3N)
    local duration=$((analysis_end - analysis_start))
    
    # Parse and analyze results
    local total_cost=$(echo "$cost_data" | jq -r '.ResultsByTime[0].Total.BlendedCost.Amount // "0"' 2>/dev/null || echo "0")
    
    {
        echo "# Real-World AWS Cost Analysis Report"
        echo "# Generated: $(date)"
        echo "# Period: $start_date to $end_date"
        echo "# =================================="
        echo
        echo "## Executive Summary"
        echo "Total Cost: \$${total_cost}"
        echo "Analysis Duration: ${duration}ms"
        echo
        
        # Service breakdown
        echo "## Service Breakdown"
        echo "$cost_data" | jq -r '.ResultsByTime[0].Groups[]? | "\(.Keys[0]): $\(.Metrics.BlendedCost.Amount)"' 2>/dev/null || echo "No service data available"
        
        # Cost optimization recommendations
        echo
        echo "## Optimization Recommendations"
        if (( $(echo "$total_cost > 100" | bc -l 2>/dev/null || echo "0") )); then
            echo "- Consider Reserved Instances for consistent workloads"
            echo "- Review unused resources and terminate if unnecessary"
            echo "- Implement auto-scaling for variable workloads"
        else
            echo "- Current spending is within reasonable limits"
            echo "- Monitor for unexpected cost increases"
        fi
        
    } > "real_world_cost_analysis_$(date +%Y%m%d).txt"
    
    log_aws_operation "ce" "get-cost-and-usage" "success" "$duration" "$total_cost"
    log_cost_analysis "all-services" "$total_cost" "$(echo "$total_cost * 1.1" | bc -l 2>/dev/null || echo "$total_cost")" "Monitor and optimize high-cost services"
    
    prod_log "INFO" "cost-analyzer" "complete" "Analysis saved with total cost \$${total_cost}"
}

# @function analyze_security_posture
# @brief Real-world security analysis
analyze_security_posture() {
    prod_log "INFO" "security-analyzer" "start" "Starting security posture analysis"
    
    local analysis_start=$(date +%s%3N)
    
    {
        echo "# Real-World Security Posture Analysis"
        echo "# Generated: $(date)"
        echo "# ====================================="
        echo
        
        # IAM Analysis
        echo "## IAM Security Analysis"
        local iam_users=$(aws iam list-users --query 'Users[].UserName' --output text 2>/dev/null || echo "Unable to fetch IAM users")
        echo "IAM Users: $iam_users"
        
        # Check for root access keys
        local root_keys=$(aws iam get-account-summary --query 'SummaryMap.AccountAccessKeysPresent' --output text 2>/dev/null || echo "0")
        if [[ "$root_keys" == "1" ]]; then
            echo "⚠️  WARNING: Root access keys detected"
            log_security_event "root-keys-detected" "root-account" "HIGH" "Root access keys should be removed"
        else
            echo "✅ No root access keys detected"
        fi
        
        # S3 Bucket Security
        echo
        echo "## S3 Security Analysis"
        aws s3api list-buckets --query 'Buckets[].Name' --output text 2>/dev/null | while read -r bucket; do
            if [[ -n "$bucket" ]]; then
                local public_access=$(aws s3api get-public-access-block --bucket "$bucket" 2>/dev/null || echo "No public access block")
                echo "Bucket: $bucket - Public Access: $public_access"
                
                if [[ "$public_access" == "No public access block" ]]; then
                    log_security_event "public-bucket" "$bucket" "MEDIUM" "Bucket may have public access"
                fi
            fi
        done
        
        # CloudTrail Status
        echo
        echo "## CloudTrail Analysis"
        local trails=$(aws cloudtrail describe-trails --query 'trailList[].Name' --output text 2>/dev/null || echo "Unable to fetch trails")
        echo "Active Trails: $trails"
        
        if [[ "$trails" == "Unable to fetch trails" ]] || [[ -z "$trails" ]]; then
            echo "⚠️  WARNING: No CloudTrail trails detected"
            log_security_event "no-cloudtrail" "account" "HIGH" "CloudTrail should be enabled for audit logging"
        fi
        
    } > "security_posture_analysis_$(date +%Y%m%d).txt"
    
    local analysis_end=$(date +%s%3N)
    local duration=$((analysis_end - analysis_start))
    
    log_aws_operation "iam" "security-analysis" "success" "$duration"
    prod_log "INFO" "security-analyzer" "complete" "Security analysis completed in ${duration}ms"
}

# @function analyze_performance_metrics
# @brief Real-world performance analysis
analyze_performance_metrics() {
    prod_log "INFO" "performance-analyzer" "start" "Starting performance metrics analysis"
    
    local analysis_start=$(date +%s%3N)
    
    {
        echo "# Real-World Performance Metrics Analysis"
        echo "# Generated: $(date)"
        echo "# ========================================"
        echo
        
        # EC2 Instance Analysis
        echo "## EC2 Performance Analysis"
        aws ec2 describe-instances \
            --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,LaunchTime]' \
            --output table 2>/dev/null || echo "Unable to fetch EC2 instances"
        
        # CloudWatch Metrics (if available)
        echo
        echo "## CloudWatch Metrics Summary"
        local metric_start=$(date -d '1 hour ago' -u '+%Y-%m-%dT%H:%M:%S')
        local metric_end=$(date -u '+%Y-%m-%dT%H:%M:%S')
        
        # CPU Utilization
        aws cloudwatch get-metric-statistics \
            --namespace AWS/EC2 \
            --metric-name CPUUtilization \
            --start-time "$metric_start" \
            --end-time "$metric_end" \
            --period 3600 \
            --statistics Average \
            --query 'Datapoints[0].Average' \
            --output text 2>/dev/null | while read -r cpu_avg; do
                if [[ "$cpu_avg" != "None" ]] && [[ -n "$cpu_avg" ]]; then
                    echo "Average CPU Utilization (1h): ${cpu_avg}%"
                    if (( $(echo "$cpu_avg > 80" | bc -l 2>/dev/null || echo "0") )); then
                        prod_log "METRIC" "performance" "high-cpu" "CPU utilization at ${cpu_avg}%"
                    fi
                fi
            done
        
    } > "performance_metrics_$(date +%Y%m%d).txt"
    
    local analysis_end=$(date +%s%3N)
    local duration=$((analysis_end - analysis_start))
    
    log_aws_operation "cloudwatch" "get-metrics" "success" "$duration"
    prod_log "INFO" "performance-analyzer" "complete" "Performance analysis completed in ${duration}ms"
}

# @function generate_executive_dashboard
# @brief Generate executive summary dashboard
generate_executive_dashboard() {
    prod_log "INFO" "dashboard" "generate" "Creating executive dashboard"
    
    {
        echo "# 📊 AWS Management Executive Dashboard"
        echo "# Generated: $(date)"
        echo "# ====================================="
        echo
        
        echo "## 🎯 Key Metrics"
        echo "- **Analysis Date:** $(date)"
        echo "- **Environment:** Production"
        echo "- **Logging:** Enhanced with CloudWatch integration"
        echo
        
        echo "## 💰 Cost Summary"
        if [[ -f "real_world_cost_analysis_$(date +%Y%m%d).txt" ]]; then
            grep "Total Cost:" "real_world_cost_analysis_$(date +%Y%m%d).txt" || echo "Cost analysis pending"
        else
            echo "Cost analysis not yet run"
        fi
        
        echo
        echo "## 🔒 Security Status"
        if [[ -f "security_posture_analysis_$(date +%Y%m%d).txt" ]]; then
            grep -c "WARNING" "security_posture_analysis_$(date +%Y%m%d).txt" | while read -r warnings; do
                echo "Security warnings: $warnings"
            done
        else
            echo "Security analysis not yet run"
        fi
        
        echo
        echo "## 📈 Performance Overview"
        if [[ -f "performance_metrics_$(date +%Y%m%d).txt" ]]; then
            echo "Performance metrics collected - see detailed report"
        else
            echo "Performance analysis not yet run"
        fi
        
        echo
        echo "## 🚀 Recommendations"
        echo "1. Run cost analysis: \`bash tools/real_world_analyzer.sh costs\`"
        echo "2. Check security posture: \`bash tools/real_world_analyzer.sh security\`"
        echo "3. Monitor performance: \`bash tools/real_world_analyzer.sh performance\`"
        echo "4. Enable CloudWatch logging: \`export AWS_MGMT_CLOUDWATCH=true\`"
        
    } > "executive_dashboard_$(date +%Y%m%d).md"
    
    prod_log "INFO" "dashboard" "complete" "Executive dashboard generated"
}

# Main execution
case "${1:-help}" in
    "costs") analyze_aws_costs "$2" "$3" ;;
    "security") analyze_security_posture ;;
    "performance") analyze_performance_metrics ;;
    "dashboard") generate_executive_dashboard ;;
    "all")
        analyze_aws_costs
        analyze_security_posture
        analyze_performance_metrics
        generate_executive_dashboard
        send_to_cloudwatch
        ;;
    *)
        echo "Usage: $0 {costs|security|performance|dashboard|all} [args...]"
        echo "  costs [start-date] [end-date] - Analyze AWS costs"
        echo "  security                      - Security posture analysis"
        echo "  performance                   - Performance metrics analysis"
        echo "  dashboard                     - Generate executive dashboard"
        echo "  all                          - Run all analyses"
        ;;
esac