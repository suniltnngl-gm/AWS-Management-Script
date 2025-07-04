

#!/bin/bash
# @file router-logic/routing/traffic_router.sh
# @brief Intelligent traffic routing based on resource availability
# @description Route traffic to healthy resources with automatic failover
# @ai-optimized: true
# @ai-dry-run-support: true
# @ai-usage: This script is batch-enhanced for AI/automation workflows, supports dry-run/test mode, and is ready for integration with AI agents and workflow orchestrators.


set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/log_utils.sh"
source "$SCRIPT_DIR/../../../lib/aws_utils.sh"


usage() {
    echo "Usage: $0 [web <region>|api|database|health|failover] [--dry-run|--test] [--help|-h]"
    echo "  web <region>  Route web traffic (default region: us-east-1)"
    echo "  api           Route API traffic"
    echo "  database      Route database traffic"
    echo "  health        Route based on health checks"
    echo "  failover      Failover to alternative region"
    echo "  --dry-run     Simulate actions, do not make AWS changes"
    echo "  --test        Alias for --dry-run (for AI/automation)"
    echo "  --help, -h    Show this help message"
    exit 0
}


# Dry-run/test mode support
DRY_RUN=false
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" || "$arg" == "--test" ]]; then
        DRY_RUN=true
    fi
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        usage
    fi
done

# @function route_web_traffic
# @brief Route web traffic to available instances
route_web_traffic() {
    local target_region="${1:-us-east-1}"
    echo "🌐 WEB TRAFFIC ROUTING"
    echo "====================="
    echo "Target region: $target_region"
    if $DRY_RUN; then
        echo "[DRY-RUN] Would check and route web traffic in $target_region (simulate output)"
        echo "Available web servers:"
        echo "✅ i-1234567890abcdef0: 203.0.113.1 (healthy)"
        echo "⚙️  GENERATING UPSTREAM CONFIG"
        echo "✅ Upstream config saved to /tmp/upstream.conf"
        return
    fi
    # Get healthy web instances
    local instances=$(aws ec2 describe-instances --region "$target_region" \
        --filters "Name=tag:Service,Values=web,frontend" "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,PrivateIpAddress]' \
        --output text 2>/dev/null)
    if [[ -n "$instances" ]]; then
        echo "Available web servers:"
        local server_count=0
        echo "$instances" | while read -r id public_ip private_ip; do
            # Health check
            if [[ -n "$public_ip" ]] && curl -s --connect-timeout 3 "http://$public_ip" >/dev/null 2>&1; then
                echo "✅ $id: $public_ip (healthy)"
                server_count=$((server_count + 1))
            else
                echo "❌ $id: $public_ip (unhealthy)"
            fi
        done
        # Generate nginx upstream config
        generate_upstream_config "$instances"
    else
        echo "⚠️  No web servers found in $target_region"
        failover_web_routing
    fi
}

# @function route_api_traffic
# @brief Route API traffic to available endpoints
route_api_traffic() {
    echo "🔌 API TRAFFIC ROUTING"
    echo "====================="
    if $DRY_RUN; then
        echo "[DRY-RUN] Would check API Gateway and Lambda API functions (simulate output)"
        echo "Available API Gateways:"
        echo "✅ example-api: https://abc123.execute-api.us-east-1.amazonaws.com"
        echo "Available API Functions:"
        echo "✅ Lambda: api-handler"
        return
    fi
    # Check API Gateway
    local apis=$(aws apigateway get-rest-apis \
        --query 'items[].[id,name]' --output text 2>/dev/null)
    if [[ -n "$apis" ]]; then
        echo "Available API Gateways:"
        echo "$apis" | while read -r api_id name; do
            local url="https://$api_id.execute-api.$(aws configure get region).amazonaws.com"
            echo "✅ $name: $url"
        done
    fi
    # Check Lambda functions for API
    local api_functions=$(aws lambda list-functions \
        --query 'Functions[?contains(FunctionName, `api`)].FunctionName' \
        --output text 2>/dev/null)
    if [[ -n "$api_functions" ]]; then
        echo "Available API Functions:"
        echo "$api_functions" | tr '\t' '\n' | while read -r func; do
            echo "✅ Lambda: $func"
        done
    fi
}

# @function route_database_traffic
# @brief Route database traffic with read/write separation
route_database_traffic() {
    echo "🗄️  DATABASE TRAFFIC ROUTING"
    echo "=========================="
    if $DRY_RUN; then
        echo "[DRY-RUN] Would check RDS and DynamoDB for routing (simulate output)"
        echo "Primary Database (Write):"
        echo "✅ db-primary: db-primary.abcdefg.us-east-1.rds.amazonaws.com"
        echo "Read Replicas (Read):"
        echo "✅ db-replica: db-replica.abcdefg.us-east-1.rds.amazonaws.com"
        echo "DynamoDB Tables:"
        echo "✅ example-table"
        return
    fi
    # Primary database (write operations)
    local primary_db=$(aws rds describe-db-instances \
        --query 'DBInstances[?DBInstanceStatus==`available` && !ReadReplicaDBInstanceIdentifiers].[DBInstanceIdentifier,Endpoint.Address]' \
        --output text 2>/dev/null | head -1)
    if [[ -n "$primary_db" ]]; then
        echo "Primary Database (Write):"
        echo "$primary_db" | while read -r id endpoint; do
            echo "✅ $id: $endpoint"
        done
    fi
    # Read replicas
    local read_replicas=$(aws rds describe-db-instances \
        --query 'DBInstances[?DBInstanceStatus==`available` && ReadReplicaSourceDBInstanceIdentifier].[DBInstanceIdentifier,Endpoint.Address]' \
        --output text 2>/dev/null)
    if [[ -n "$read_replicas" ]]; then
        echo "Read Replicas (Read):"
        echo "$read_replicas" | while read -r id endpoint; do
            echo "✅ $id: $endpoint"
        done
    fi
    # DynamoDB tables
    local dynamo_tables=$(aws dynamodb list-tables --query 'TableNames[]' --output text 2>/dev/null)
    if [[ -n "$dynamo_tables" ]]; then
        echo "DynamoDB Tables:"
        echo "$dynamo_tables" | tr '\t' '\n' | sed 's/^/✅ /'
    fi
}

# @function generate_upstream_config
# @brief Generate load balancer upstream configuration
generate_upstream_config() {
    local instances="$1"
    
    echo "⚙️  GENERATING UPSTREAM CONFIG"
    echo "============================="
    
    cat > /tmp/upstream.conf << EOF
upstream web_servers {
    least_conn;
EOF
    
    echo "$instances" | while read -r id public_ip private_ip; do
        if [[ -n "$public_ip" ]]; then
            echo "    server $public_ip:80 max_fails=3 fail_timeout=30s;" >> /tmp/upstream.conf
        fi
    done
    
    cat >> /tmp/upstream.conf << EOF
}

server {
    listen 80;
    location / {
        proxy_pass http://web_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
    
    echo "✅ Upstream config saved to /tmp/upstream.conf"
}

# @function failover_web_routing
# @brief Failover to alternative regions
failover_web_routing() {
    echo "🔄 FAILOVER ROUTING"
    echo "=================="
    
    local fallback_regions=("us-west-2" "eu-west-1" "ap-southeast-1")
    
    for region in "${fallback_regions[@]}"; do
        local instances=$(aws ec2 describe-instances --region "$region" \
            --filters "Name=tag:Service,Values=web" "Name=instance-state-name,Values=running" \
            --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
        
        if [[ "$instances" -gt 0 ]]; then
            echo "✅ Failover to $region: $instances instances available"
            route_web_traffic "$region"
            return 0
        fi
    done
    
    echo "❌ No failover regions available"
    return 1
}

# @function health_based_routing
# @brief Route based on real-time health checks
health_based_routing() {
    echo "🏥 HEALTH-BASED ROUTING"
    echo "======================"
    if $DRY_RUN; then
        echo "[DRY-RUN] Would check health and route traffic accordingly (simulate output)"
        echo "✅ web (i-1234567890abcdef0): Healthy - Route traffic here"
        echo "❌ api (i-abcdef1234567890): Unhealthy - Remove from rotation"
        return
    fi
    # Get all running instances
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==`Service`].Value|[0]]' \
        --output text | while read -r id ip service; do
        if [[ -n "$ip" && -n "$service" ]]; then
            # Perform health check
            if curl -s --connect-timeout 3 "http://$ip/health" >/dev/null 2>&1; then
                echo "✅ $service ($id): Healthy - Route traffic here"
            else
                echo "❌ $service ($id): Unhealthy - Remove from rotation"
            fi
        fi
    done
}


# Main command dispatch (AI/dry-run aware)
case "${1:-web}" in
    "web") route_web_traffic "${2:-us-east-1}" ;;
    "api") route_api_traffic ;;
    "database") route_database_traffic ;;
    "health") health_based_routing ;;
    "failover") failover_web_routing ;;
    *) usage ;;
esac