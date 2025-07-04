#!/bin/bash

# @file integrations/terraform/tf_integration.sh
# @brief Terraform integration for infrastructure automation
# @description Cost-effective infrastructure as code integration

set -euo pipefail

source "$(dirname "$0")/../../core/core_logger.sh"

# @function analyze_terraform_costs
# @brief Analyze Terraform infrastructure costs
analyze_terraform_costs() {
    local tf_dir="${1:-.}"
    log_info "terraform" "Analyzing Terraform costs in $tf_dir"
    
    if [[ ! -f "$tf_dir/main.tf" ]]; then
        echo '{"error":"No Terraform files found"}'
        return 1
    fi
    
    # Parse Terraform files for resource costs
    local resources=$(grep -r "resource\s*\"" "$tf_dir" | wc -l)
    local ec2_instances=$(grep -r "aws_instance" "$tf_dir" | wc -l)
    local rds_instances=$(grep -r "aws_db_instance" "$tf_dir" | wc -l)
    
    # Estimate costs (simplified)
    local estimated_cost=$((ec2_instances * 50 + rds_instances * 100))
    
    cat <<EOF
{
  "terraform_analysis": {
    "directory": "$tf_dir",
    "total_resources": $resources,
    "ec2_instances": $ec2_instances,
    "rds_instances": $rds_instances,
    "estimated_monthly_cost": $estimated_cost
  },
  "recommendations": $(generate_tf_recommendations "$ec2_instances" "$rds_instances")
}
EOF
}

# @function generate_tf_recommendations
# @brief Generate Terraform optimization recommendations
generate_tf_recommendations() {
    local ec2_count="$1"
    local rds_count="$2"
    local recommendations=()
    
    if [[ $ec2_count -gt 3 ]]; then
        recommendations+=('{"type":"ec2","message":"Consider using auto-scaling groups","savings":"20-30%"}')
    fi
    
    if [[ $rds_count -gt 1 ]]; then
        recommendations+=('{"type":"rds","message":"Consider read replicas instead of multiple instances","savings":"40-50%"}')
    fi
    
    recommendations+=('{"type":"general","message":"Use Terraform modules for reusability","benefit":"consistency"}')
    
    echo "[$(IFS=','; echo "${recommendations[*]}")]"
}

# @function validate_terraform
# @brief Validate Terraform configuration
validate_terraform() {
    local tf_dir="${1:-.}"
    
    if command -v terraform >/dev/null 2>&1; then
        cd "$tf_dir"
        terraform validate 2>/dev/null && echo "✅ Terraform configuration valid" || echo "❌ Terraform validation failed"
    else
        echo "⚠️ Terraform not installed"
    fi
}

case "${1:-analyze}" in
    "analyze") analyze_terraform_costs "$2" ;;
    "validate") validate_terraform "$2" ;;
    *) echo "Usage: $0 {analyze|validate} [directory]" ;;
esac