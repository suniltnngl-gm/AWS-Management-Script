#!/bin/bash

# @file router-logic/router_hub.sh
# @brief Router Logic Hub - Resource availability management
# @description Intelligent routing based on resource availability and health

set -euo pipefail

source "$(dirname "$0")/../core/config_loader.sh"

# @function check_resource_availability
# @brief Check availability of AWS resources across regions
check_resource_availability() {
    local resource_type="${1:-all}"
    
    echo "🌐 RESOURCE AVAILABILITY CHECK"
    echo "============================="
    
    case "$resource_type" in
        "ec2"|"all")
            echo "EC2 Instances:"
            aws ec2 describe-regions --query 'Regions[].RegionName' --output text | \
            while read -r region; do
                local count=$(aws ec2 describe-instances --region "$region" \
                    --query 'length(Reservations[*].Instances[?State.Name==`running`])' \
                    --output text 2>/dev/null || echo "0")
                printf "  %-15s: %s running\n" "$region" "$count"
            done
            ;;
        "s3"|"all")
            echo "S3 Buckets:"
            aws s3api list-buckets --query 'Buckets[].Name' --output text | \
            while read -r bucket; do
                local region=$(aws s3api get-bucket-location --bucket "$bucket" \
                    --query 'LocationConstraint' --output text 2>/dev/null || echo "us-east-1")
                [[ "$region" == "None" ]] && region="us-east-1"
                printf "  %-30s: %s\n" "$bucket" "$region"
            done
            ;;
    esac
}

# @function route_to_available_resource
# @brief Route requests to available resources
# @param $1 service_type (web|api|db)
# @param $2 preferred_region
route_to_available_resource() {
    local service_type="$1"
    local preferred_region="${2:-us-east-1}"
    
    echo "🔀 ROUTING TO AVAILABLE RESOURCE"
    echo "==============================="
    echo "Service: $service_type | Preferred: $preferred_region"
    
    case "$service_type" in
        "web")
            # Check for healthy web servers
            local instances=$(aws ec2 describe-instances --region "$preferred_region" \
                --filters "Name=tag:Service,Values=web" "Name=instance-state-name,Values=running" \
                --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
                --output text 2>/dev/null)
            
            if [[ -n "$instances" ]]; then
                echo "✅ Available web servers in $preferred_region:"
                echo "$instances" | while read -r id ip; do
                    echo "  $id: $ip"
                done
            else
                echo "⚠️  No web servers in $preferred_region - checking alternatives"
                find_alternative_region "web"
            fi
            ;;
        "api")
            # Check API Gateway or Lambda functions
            local functions=$(aws lambda list-functions --region "$preferred_region" \
                --query 'Functions[?contains(FunctionName, `api`)].FunctionName' \
                --output text 2>/dev/null)
            
            if [[ -n "$functions" ]]; then
                echo "✅ Available API functions in $preferred_region:"
                echo "$functions" | tr '\t' '\n' | sed 's/^/  /'
            else
                find_alternative_region "api"
            fi
            ;;
        "db")
            # Check RDS instances
            local databases=$(aws rds describe-db-instances --region "$preferred_region" \
                --query 'DBInstances[?DBInstanceStatus==`available`].[DBInstanceIdentifier,Endpoint.Address]' \
                --output text 2>/dev/null)
            
            if [[ -n "$databases" ]]; then
                echo "✅ Available databases in $preferred_region:"
                echo "$databases" | while read -r id endpoint; do
                    echo "  $id: $endpoint"
                done
            else
                find_alternative_region "db"
            fi
            ;;
    esac
}

# @function find_alternative_region
# @brief Find alternative regions with available resources
find_alternative_region() {
    local service_type="$1"
    
    echo "🔍 Searching alternative regions for $service_type..."
    
    local regions=("us-west-2" "eu-west-1" "ap-southeast-1")
    for region in "${regions[@]}"; do
        case "$service_type" in
            "web")
                local count=$(aws ec2 describe-instances --region "$region" \
                    --filters "Name=tag:Service,Values=web" "Name=instance-state-name,Values=running" \
                    --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
                ;;
            "api")
                local count=$(aws lambda list-functions --region "$region" \
                    --query 'length(Functions[?contains(FunctionName, `api`)])' --output text 2>/dev/null || echo "0")
                ;;
            "db")
                local count=$(aws rds describe-db-instances --region "$region" \
                    --query 'length(DBInstances[?DBInstanceStatus==`available`])' --output text 2>/dev/null || echo "0")
                ;;
        esac
        
        if [[ "$count" -gt 0 ]]; then
            echo "✅ Found $count $service_type resources in $region"
            return 0
        fi
    done
    
    echo "❌ No alternative regions found for $service_type"
    return 1
}

# @function health_check_routing
# @brief Route based on health checks
health_check_routing() {
    echo "🏥 HEALTH-BASED ROUTING"
    echo "======================"
    
    # Check ELB target health
    local load_balancers=$(aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null)
    
    if [[ -n "$load_balancers" ]]; then
        echo "$load_balancers" | while read -r lb_arn; do
            local lb_name=$(aws elbv2 describe-load-balancers --load-balancer-arns "$lb_arn" \
                --query 'LoadBalancers[0].LoadBalancerName' --output text)
            
            local target_groups=$(aws elbv2 describe-target-groups --load-balancer-arn "$lb_arn" \
                --query 'TargetGroups[].TargetGroupArn' --output text)
            
            echo "Load Balancer: $lb_name"
            echo "$target_groups" | while read -r tg_arn; do
                local healthy=$(aws elbv2 describe-target-health --target-group-arn "$tg_arn" \
                    --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text)
                echo "  Healthy targets: $healthy"
            done
        done
    else
        echo "No load balancers found - checking individual instances"
        
        # Direct instance health check
        aws ec2 describe-instances \
            --filters "Name=instance-state-name,Values=running" \
            --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
            --output text | while read -r id ip; do
            if [[ -n "$ip" ]] && curl -s --connect-timeout 3 "http://$ip" >/dev/null 2>&1; then
                echo "✅ $id ($ip): Healthy"
            else
                echo "❌ $id ($ip): Unhealthy"
            fi
        done
    fi
}

# @function generate_routing_config
# @brief Generate routing configuration
generate_routing_config() {
    echo "⚙️  GENERATING ROUTING CONFIG"
    echo "============================"
    
    cat > /tmp/routing_config.json << EOF
{
  "routing_rules": [
    {
      "service": "web",
      "primary_region": "us-east-1",
      "fallback_regions": ["us-west-2", "eu-west-1"],
      "health_check_path": "/health"
    },
    {
      "service": "api",
      "primary_region": "us-east-1", 
      "fallback_regions": ["us-west-2"],
      "health_check_path": "/api/health"
    },
    {
      "service": "db",
      "primary_region": "us-east-1",
      "fallback_regions": ["us-west-2"],
      "read_replicas": true
    }
  ]
}
EOF
    
    echo "✅ Routing config saved to /tmp/routing_config.json"
    cat /tmp/routing_config.json
}

case "${1:-check}" in
    "check") check_resource_availability "${2:-all}" ;;
    "route") route_to_available_resource "${2:-web}" "${3:-us-east-1}" ;;
    "health") health_check_routing ;;
    "config") generate_routing_config ;;
    *) echo "Usage: $0 [check <type>|route <service> <region>|health|config]" ;;
esac