#!/bin/bash

#---------------------------------------------------------------------------------
#Script Name	:    AWS Management Script                                                                                          
#Description	:    Streamline the monitoring and management of AWS services with this script, offering comprehensive details and instance counts of all utilized services. By running the script, effortlessly obtain an overview of AWS services in use, eliminating the need for manual inspection through the AWS console. This solution simplifies tracking, reduces manual effort, and enables more efficient management of AWS resources.
#Version        :    1.4v
#Author         :    Shivanshu Sharma                                                
#Email         	:    shivanshus133@gmail.com                                           
#---------------------------------------------------------------------------------

ec2_instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text) # EC2 Instance Usage
ec2_count=$(echo "$ec2_instances" | wc -w)  # Counting the number of EC2 instances

ec2_name=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].Tags[*].Value" --output text) #EC2 Instance Name 

s3_buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text) # S3 Buckets Usage
s3_count=$(echo "$s3_buckets" | wc -w)  # Counting the number of S3 buckets

lambda_functions=$(aws lambda list-functions --query 'Functions[*].[FunctionName]' --output text) # Lambda Functions Usage
lambda_count=$(echo "$lambda_functions" | wc -w)  # Counting the number of Lambda functions

sns_topics=$(aws sns list-topics --query 'Topics[].TopicArn' --output text) # SNS Topics Usage
sns_count=$(echo "$sns_topics" | wc -w)  # Counting the number of SNS topics

iam_users=$(aws iam list-users --query 'Users[*].[UserName]' --output text) # IAM DashBoard Usage
iam_count=$(echo "$iam_users" | wc -w)  # Counting the number of IAM users

echo "AWS Usage Info"
echo "---------------------"
echo "EC2 Instances: $ec2_count"        
echo "EC2 Names:"                        
echo $ec2_name 
echo "S3 Buckets: $s3_count"            
echo "Lambda Functions: $lambda_count"  
echo "SNS Topics: $sns_count"           
echo "IAM Users: $iam_count"            

aws ce get-cost-and-usage --time-period Start=2023-07-01,End=2023-07-12 --granularity MONTHLY --metrics "BlendedCost" "UnblendedCost" "UsageQuantity" --query "ResultsByTime[*].Total" --output table



