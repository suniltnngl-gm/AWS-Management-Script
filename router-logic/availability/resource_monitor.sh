#!/bin/bash

# @file router-logic/availability/resource_monitor.sh
# @brief Real-time resource availability monitoring
# @description Continuous monitoring of AWS resource health and availability

set -euo pipefail

# @function monitor_ec2_availability
# @brief Monitor EC2 instance availability across regions
monitor_ec2_availability() {
    echo "🖥️  EC2 AVAILABILITY MONITOR"
    echo "==========================="
    
    local regions=("us-east-1" "us-west-2" "eu-west-1")
    local total_running=0
    
    for region in "${regions[@]}"; do
        local running=$(aws ec2 describe-instances --region "$region" \
            --filters "Name=instance-state-name,Values=running" \
            --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
        
        local stopped=$(aws ec2 describe-instances --region "$region" \
            --filters "Name=instance-state-name,Values=stopped" \
            --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
        
        printf "%-12s: %s running, %s stopped\n" "$region" "$running" "$stopped"
        total_running=$((total_running + running))
    done
    
    echo "Total running instances: $total_running"
    
    if [[ $total_running -eq 0 ]]; then
        echo "⚠️  WARNING: No running EC2 instances detected"
        return 1
    fi
}

# @function monitor_service_endpoints
# @brief Monitor service endpoint availability
monitor_service_endpoints() {
    echo "🌐 SERVICE ENDPOINT MONITOR"
    echo "=========================="
    
    # Check API Gateway endpoints
    local apis=$(aws apigateway get-rest-apis --query 'items[].id' --output text 2>/dev/null)
    if [[ -n "$apis" ]]; then
        echo "$apis" | while read -r api_id; do
            local name=$(aws apigateway get-rest-api --rest-api-id "$api_id" \
                --query 'name' --output text 2>/dev/null)
            echo "API Gateway: $name ($api_id)"
        done
    fi
    
    # Check Lambda function availability
    local functions=$(aws lambda list-functions \
        --query 'Functions[].FunctionName' --output text 2>/dev/null)
    if [[ -n "$functions" ]]; then
        echo "Lambda Functions:"
        echo "$functions" | tr '\t' '\n' | while read -r func; do
            local state=$(aws lambda get-function --function-name "$func" \
                --query 'Configuration.State' --output text 2>/dev/null || echo "Unknown")
            printf "  %-30s: %s\n" "$func" "$state"
        done
    fi
}

# @function check_database_availability
# @brief Monitor database availability and performance
check_database_availability() {
    echo "🗄️  DATABASE AVAILABILITY"
    echo "======================="
    
    # RDS instances
    local rds_instances=$(aws rds describe-db-instances \
        --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus,AvailabilityZone]' \
        --output text 2>/dev/null)
    
    if [[ -n "$rds_instances" ]]; then
        echo "RDS Instances:"
        echo "$rds_instances" | while read -r id status az; do
            printf "  %-20s: %s (%s)\n" "$id" "$status" "$az"
        done
    fi
    
    # DynamoDB tables
    local dynamo_tables=$(aws dynamodb list-tables --query 'TableNames[]' --output text 2>/dev/null)
    if [[ -n "$dynamo_tables" ]]; then
        echo "DynamoDB Tables:"
        echo "$dynamo_tables" | tr '\t' '\n' | while read -r table; do
            local status=$(aws dynamodb describe-table --table-name "$table" \
                --query 'Table.TableStatus' --output text 2>/dev/null || echo "Unknown")
            printf "  %-20s: %s\n" "$table" "$status"
        done
    fi
}

# @function availability_score
# @brief Calculate overall availability score
availability_score() {
    echo "📊 AVAILABILITY SCORE"
    echo "===================="
    
    local score=0
    local max_score=100
    
    # EC2 availability (30 points)
    local running_instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'length(Reservations[*].Instances[*])' --output text 2>/dev/null || echo "0")
    if [[ $running_instances -gt 0 ]]; then
        score=$((score + 30))
        echo "✅ EC2 instances running: +30 points"
    fi
    
    # Lambda availability (25 points)
    local lambda_count=$(aws lambda list-functions \
        --query 'length(Functions[])' --output text 2>/dev/null || echo "0")
    if [[ $lambda_count -gt 0 ]]; then
        score=$((score + 25))
        echo "✅ Lambda functions available: +25 points"
    fi
    
    # Database availability (25 points)
    local db_count=$(aws rds describe-db-instances \
        --query 'length(DBInstances[?DBInstanceStatus==`available`])' --output text 2>/dev/null || echo "0")
    local dynamo_count=$(aws dynamodb list-tables \
        --query 'length(TableNames[])' --output text 2>/dev/null || echo "0")
    if [[ $((db_count + dynamo_count)) -gt 0 ]]; then
        score=$((score + 25))
        echo "✅ Databases available: +25 points"
    fi
    
    # S3 availability (20 points)
    local bucket_count=$(aws s3api list-buckets \
        --query 'length(Buckets[])' --output text 2>/dev/null || echo "0")
    if [[ $bucket_count -gt 0 ]]; then
        score=$((score + 20))
        echo "✅ S3 buckets available: +20 points"
    fi
    
    echo "Overall Availability Score: $score/$max_score"
    
    if [[ $score -ge 80 ]]; then
        echo "🟢 Status: EXCELLENT"
    elif [[ $score -ge 60 ]]; then
        echo "🟡 Status: GOOD"
    elif [[ $score -ge 40 ]]; then
        echo "🟠 Status: FAIR"
    else
        echo "🔴 Status: POOR"
    fi
}

case "${1:-monitor}" in
    "ec2") monitor_ec2_availability ;;
    "endpoints") monitor_service_endpoints ;;
    "database") check_database_availability ;;
    "score") availability_score ;;
    "monitor") monitor_ec2_availability && monitor_service_endpoints && check_database_availability ;;
    *) echo "Usage: $0 [ec2|endpoints|database|score|monitor]" ;;
esac