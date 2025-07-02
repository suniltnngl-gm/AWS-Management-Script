#!/bin/bash

# @file client/aws_client.sh
# @brief AWS automation client
# @description Client interface for automated AWS operations

set -euo pipefail

source "$(dirname "$0")/../core/helpers.sh"
source "$(dirname "$0")/../core/automation.sh"

show_automation_menu() {
    echo "AWS Automation Client"
    echo "===================="
    echo "1. Interactive Resource Setup"
    echo "2. Automated Audit with Alerts"
    echo "3. Schedule Monitoring"
    echo "4. Bulk Resource Operations"
    echo "5. Custom Automation Workflow"
    echo "0. Back to Main Menu"
    echo
    read -p "Select option [0-5]: " choice
}

# @function interactive_resource_setup
# @brief Interactive AWS resource configuration
interactive_resource_setup() {
    echo "Interactive AWS Resource Setup"
    echo "============================="
    
    local resource_type=$(prompt_user "Resource type (ec2/s3/lambda)" "ec2")
    local action=$(prompt_user "Action (create/delete/modify)" "create")
    
    case "$resource_type-$action" in
        "ec2-create")
            local instance_type=$(prompt_user "Instance type" "t2.micro")
            local key_name=$(prompt_user "Key pair name")
            echo "Would create EC2 instance: $instance_type with key: $key_name"
            ;;
        "s3-create")
            local bucket_name=$(prompt_user "Bucket name")
            local region=$(prompt_user "Region" "us-east-1")
            if confirm_action "Create S3 bucket $bucket_name in $region?"; then
                execute_with_retry "aws s3 mb s3://$bucket_name --region $region"
            fi
            ;;
        *) echo "Configuration for $resource_type-$action not implemented" ;;
    esac
}

# @function bulk_operations
# @brief Bulk AWS resource operations
bulk_operations() {
    echo "Bulk Operations"
    echo "==============="
    
    local operation=$(prompt_user "Operation (stop-instances/delete-buckets/list-unused)")
    
    case "$operation" in
        "stop-instances")
            local instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text)
            if [[ -n "$instances" ]] && confirm_action "Stop all running instances?"; then
                aws ec2 stop-instances --instance-ids $instances
            fi
            ;;
        "list-unused")
            echo "Unused Resources:"
            aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`stopped`].[InstanceId,LaunchTime]' --output table
            ;;
    esac
}

run_client() {
    while true; do
        show_automation_menu
        case "$choice" in
            1) interactive_resource_setup ;;
            2) run_automated_audit ;;
            3) setup_scheduled_monitoring ;;
            4) bulk_operations ;;
            5) echo "Custom workflows - Coming soon" ;;
            0) return 0 ;;
            *) echo "Invalid option" ;;
        esac
        echo; read -p "Press Enter to continue..."
    done
}

run_client