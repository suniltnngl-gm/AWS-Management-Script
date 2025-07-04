#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# @file tools/monitoring_dashboard.sh
# @brief Real-time monitoring dashboard for production AWS environments
# @description Live monitoring with alerts and notifications

set -euo pipefail

source "$SCRIPT_DIR/../lib/production_logger.sh"

DASHBOARD_PORT="${AWS_MGMT_DASHBOARD_PORT:-8080}"
REFRESH_INTERVAL="${AWS_MGMT_REFRESH:-30}"

# @function start_monitoring
# @brief Start real-time monitoring dashboard
start_monitoring() {
    prod_log "INFO" "monitor" "start" "Starting real-time monitoring dashboard on port $DASHBOARD_PORT"
    
    # Create monitoring web interface
    cat > "/tmp/aws_dashboard.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Management Dashboard</title>
    <meta http-equiv="refresh" content="30">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric { display: inline-block; margin: 10px 20px; }
        .alert { background: #ffebee; border-left: 4px solid #f44336; }
        .success { background: #e8f5e8; border-left: 4px solid #4caf50; }
        .warning { background: #fff3e0; border-left: 4px solid #ff9800; }
        h1 { color: #333; text-align: center; }
        h2 { color: #666; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .timestamp { color: #999; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS Management Dashboard</h1>
        <div class="timestamp">Last Updated: $(date)</div>
        
        <div class="card success">
            <h2>📊 System Status</h2>
            <div class="metric">Status: <strong>OPERATIONAL</strong></div>
            <div class="metric">Uptime: <strong>$(uptime -p 2>/dev/null || echo "Unknown")</strong></div>
            <div class="metric">Load: <strong>$(uptime | awk -F'load average:' '{print $2}' 2>/dev/null || echo "Unknown")</strong></div>
        </div>
        
        <div class="card">
            <h2>💰 Cost Monitoring</h2>
            <div id="cost-data">Loading cost data...</div>
        </div>
        
        <div class="card">
            <h2>🔒 Security Alerts</h2>
            <div id="security-data">Checking security status...</div>
        </div>
        
        <div class="card">
            <h2>📈 Performance Metrics</h2>
            <div id="performance-data">Collecting performance data...</div>
        </div>
        
        <div class="card">
            <h2>📋 Recent Logs</h2>
            <div id="log-data">
                <pre>$(tail -10 /var/log/aws-mgmt/aws-management.log 2>/dev/null || echo "No logs available")</pre>
            </div>
        </div>
    </div>
</body>
</html>
EOF
    
    # Start simple HTTP server for dashboard
    if command -v python3 >/dev/null 2>&1; then
        cd /tmp && python3 -m http.server "$DASHBOARD_PORT" >/dev/null 2>&1 &
        local server_pid=$!
        prod_log "INFO" "monitor" "server-start" "Dashboard server started with PID $server_pid"
        echo "🌐 Dashboard available at: http://localhost:$DASHBOARD_PORT/aws_dashboard.html"
        echo "🔄 Auto-refresh every $REFRESH_INTERVAL seconds"
        echo "Press Ctrl+C to stop monitoring"
        
        # Monitor and update dashboard
        while true; do
            update_dashboard_data
            sleep "$REFRESH_INTERVAL"
        done
    else
        prod_log "ERROR" "monitor" "no-python" "Python3 not available for dashboard server"
        echo "❌ Python3 required for dashboard server"
        return 1
    fi
}

# @function update_dashboard_data
# @brief Update dashboard with real-time data
update_dashboard_data() {
    local timestamp=$(date)
    
    # Update cost data
    local daily_cost=$(aws ce get-cost-and-usage \
        --time-period Start="$(date '+%Y-%m-%d')",End="$(date -d '+1 day' '+%Y-%m-%d')" \
        --granularity DAILY \
        --metrics BlendedCost \
        --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0.00")
    
    # Update security status
    local security_warnings=$(grep -c "WARNING" /var/log/aws-mgmt/audit.log 2>/dev/null || echo "0")
    
    # Update performance metrics
    local error_count=$(grep -c "ERROR" /var/log/aws-mgmt/errors.log 2>/dev/null || echo "0")
    
    # Log metrics
    prod_log "METRIC" "dashboard" "update" "daily_cost=$daily_cost security_warnings=$security_warnings errors=$error_count"
    
    # Send alerts if needed
    if (( $(echo "$daily_cost > 50" | bc -l 2>/dev/null || echo "0") )); then
        send_alert "COST" "Daily cost exceeds \$50: \$${daily_cost}"
    fi
    
    if [[ "$security_warnings" -gt 0 ]]; then
        send_alert "SECURITY" "$security_warnings security warnings detected"
    fi
    
    if [[ "$error_count" -gt 10 ]]; then
        send_alert "ERROR" "$error_count errors in log file"
    fi
}

# @function send_alert
# @brief Send alerts via configured channels
send_alert() {
    local alert_type="$1"
    local message="$2"
    
    prod_log "AUDIT" "alert" "$alert_type" "$message"
    
    # Console alert
    echo "🚨 ALERT [$alert_type]: $message"
    
    # Email alert (if configured)
    if [[ -n "${AWS_MGMT_EMAIL:-}" ]]; then
        echo "Subject: AWS Management Alert - $alert_type" > /tmp/alert_email.txt
        echo "Alert: $message" >> /tmp/alert_email.txt
        echo "Time: $(date)" >> /tmp/alert_email.txt
        
        # Send email using AWS SES if available
        if command -v aws >/dev/null 2>&1; then
            aws ses send-email \
                --source "aws-mgmt@$(hostname)" \
                --destination "ToAddresses=$AWS_MGMT_EMAIL" \
                --message "Subject={Data='AWS Management Alert - $alert_type'},Body={Text={Data='$message at $(date)'}}" 2>/dev/null || true
        fi
    fi
    
    # Slack notification (if configured)
    if [[ -n "${AWS_MGMT_SLACK_WEBHOOK:-}" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 AWS Management Alert: $alert_type - $message\"}" \
            "$AWS_MGMT_SLACK_WEBHOOK" 2>/dev/null || true
    fi
}

# @function generate_health_report
# @brief Generate system health report
generate_health_report() {
    prod_log "INFO" "health" "report" "Generating system health report"
    
    {
        echo "# 🏥 AWS Management System Health Report"
        echo "# Generated: $(date)"
        echo "# ======================================="
        echo
        
        echo "## System Health"
        echo "- **Status:** $(systemctl is-active aws-mgmt 2>/dev/null || echo "Manual")"
        echo "- **Uptime:** $(uptime -p 2>/dev/null || echo "Unknown")"
        echo "- **Load Average:** $(uptime | awk -F'load average:' '{print $2}' 2>/dev/null || echo "Unknown")"
        echo "- **Memory Usage:** $(free -h | awk '/^Mem:/ {print $3"/"$2}' 2>/dev/null || echo "Unknown")"
        echo "- **Disk Usage:** $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}' 2>/dev/null || echo "Unknown")"
        echo
        
        echo "## Log Statistics"
        echo "- **Total Log Entries:** $(wc -l < /var/log/aws-mgmt/aws-management.log 2>/dev/null || echo "0")"
        echo "- **Error Count (24h):** $(grep "$(date '+%Y-%m-%d')" /var/log/aws-mgmt/errors.log 2>/dev/null | wc -l || echo "0")"
        echo "- **Audit Events (24h):** $(grep "$(date '+%Y-%m-%d')" /var/log/aws-mgmt/audit.log 2>/dev/null | wc -l || echo "0")"
        echo
        
        echo "## AWS Connectivity"
        if aws sts get-caller-identity >/dev/null 2>&1; then
            echo "- **AWS CLI:** ✅ Connected"
            echo "- **Account ID:** $(aws sts get-caller-identity --query Account --output text 2>/dev/null)"
            echo "- **Region:** $(aws configure get region 2>/dev/null || echo "Not configured")"
        else
            echo "- **AWS CLI:** ❌ Not connected or configured"
        fi
        
        echo
        echo "## Recommendations"
        local log_size=$(du -sh /var/log/aws-mgmt/ 2>/dev/null | cut -f1 || echo "0")
        echo "- Log directory size: $log_size"
        if [[ "${log_size%M*}" -gt 100 ]] 2>/dev/null; then
            echo "- ⚠️  Consider log rotation (size > 100MB)"
        fi
        
    } > "health_report_$(date +%Y%m%d_%H%M%S).txt"
    
    prod_log "INFO" "health" "complete" "Health report generated"
}

# Main execution
case "${1:-help}" in
    "start") start_monitoring ;;
    "health") generate_health_report ;;
    "alert") send_alert "$2" "$3" ;;
    *)
        echo "Usage: $0 {start|health|alert} [args...]"
        echo "  start                    - Start real-time monitoring dashboard"
        echo "  health                   - Generate system health report"
        echo "  alert <type> <message>   - Send test alert"
        echo
        echo "Environment Variables:"
        echo "  AWS_MGMT_DASHBOARD_PORT  - Dashboard port (default: 8080)"
        echo "  AWS_MGMT_REFRESH         - Refresh interval (default: 30s)"
        echo "  AWS_MGMT_EMAIL           - Email for alerts"
        echo "  AWS_MGMT_SLACK_WEBHOOK   - Slack webhook URL"
        ;;
esac