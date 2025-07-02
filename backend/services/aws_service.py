#!/usr/bin/env python3

# @file backend/services/aws_service.py
# @brief AWS service layer for backend operations
# @description Python wrapper for AWS operations

import boto3
import json
from datetime import datetime, timedelta

class AWSService:
    def __init__(self):
        self.session = boto3.Session()
    
    def get_resources_summary(self):
        """Get AWS resources summary"""
        try:
            ec2 = self.session.client('ec2')
            s3 = self.session.client('s3')
            lambda_client = self.session.client('lambda')
            
            return {
                "ec2_instances": len(ec2.describe_instances()['Reservations']),
                "s3_buckets": len(s3.list_buckets()['Buckets']),
                "lambda_functions": len(lambda_client.list_functions()['Functions']),
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            return {"error": str(e)}
    
    def get_cost_data(self, days=30):
        """Get cost data from Cost Explorer"""
        try:
            ce = self.session.client('ce')
            end_date = datetime.now().date()
            start_date = end_date - timedelta(days=days)
            
            response = ce.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date.strftime('%Y-%m-%d'),
                    'End': end_date.strftime('%Y-%m-%d')
                },
                Granularity='MONTHLY',
                Metrics=['BlendedCost']
            )
            
            return {
                "total_cost": response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'],
                "currency": response['ResultsByTime'][0]['Total']['BlendedCost']['Unit'],
                "period": f"{start_date} to {end_date}"
            }
        except Exception as e:
            return {"error": str(e)}
    
    def get_security_findings(self):
        """Get basic security findings"""
        findings = []
        
        try:
            # Check for public S3 buckets
            s3 = self.session.client('s3')
            buckets = s3.list_buckets()['Buckets']
            
            for bucket in buckets[:5]:  # Limit to 5 for demo
                try:
                    acl = s3.get_bucket_acl(Bucket=bucket['Name'])
                    for grant in acl['Grants']:
                        if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers':
                            findings.append({
                                "type": "public_s3_bucket",
                                "resource": bucket['Name'],
                                "severity": "HIGH"
                            })
                except:
                    pass
                    
        except Exception as e:
            findings.append({"error": str(e)})
            
        return {"findings": findings}