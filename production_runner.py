#!/usr/bin/env python3
"""Production AWS Management with Real-World Logging & Analysis"""

import boto3
import json
import logging
import time
from datetime import datetime
from pathlib import Path

# Production logging setup
log_dir = Path("/tmp/aws-mgmt")
log_dir.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='{"time":"%(asctime)s","level":"%(levelname)s","msg":"%(message)s","component":"%(name)s"}',
    handlers=[
        logging.FileHandler(log_dir / "production.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("aws-mgmt")

class ProductionAWSManager:
    def __init__(self):
        self.session = boto3.Session()
        self.metrics = {"operations": 0, "errors": 0, "cost": 0.0}
        
    def log_operation(self, service, operation, status, duration=0, cost=0.0):
        """Log AWS operations with metrics"""
        self.metrics["operations"] += 1
        self.metrics["cost"] += cost
        if status == "error":
            self.metrics["errors"] += 1
            
        logger.info(json.dumps({
            "type": "aws_operation",
            "service": service,
            "operation": operation,
            "status": status,
            "duration_ms": duration,
            "cost_usd": cost,
            "timestamp": datetime.now().isoformat()
        }))
    
    def analyze_ec2(self):
        """Real EC2 analysis with cost tracking"""
        try:
            start = time.time()
            ec2 = self.session.client('ec2')
            
            # Get instances
            response = ec2.describe_instances()
            instances = []
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    instances.append({
                        "id": instance['InstanceId'],
                        "type": instance['InstanceType'],
                        "state": instance['State']['Name'],
                        "launch_time": instance.get('LaunchTime', '').isoformat() if instance.get('LaunchTime') else None
                    })
            
            duration = (time.time() - start) * 1000
            self.log_operation("ec2", "describe_instances", "success", duration, 0.01)
            
            # Analysis
            running_count = sum(1 for i in instances if i['state'] == 'running')
            logger.info(json.dumps({
                "type": "analysis",
                "service": "ec2",
                "total_instances": len(instances),
                "running_instances": running_count,
                "stopped_instances": len(instances) - running_count
            }))
            
            return instances
            
        except Exception as e:
            self.log_operation("ec2", "describe_instances", "error")
            logger.error(f"EC2 analysis failed: {e}")
            return []
    
    def analyze_s3(self):
        """Real S3 analysis with cost tracking"""
        try:
            start = time.time()
            s3 = self.session.client('s3')
            
            # List buckets
            response = s3.list_buckets()
            buckets = []
            total_size = 0
            
            for bucket in response['Buckets']:
                bucket_name = bucket['Name']
                try:
                    # Get bucket size (simplified)
                    objects = s3.list_objects_v2(Bucket=bucket_name, MaxKeys=1000)
                    size = sum(obj.get('Size', 0) for obj in objects.get('Contents', []))
                    total_size += size
                    
                    buckets.append({
                        "name": bucket_name,
                        "creation_date": bucket['CreationDate'].isoformat(),
                        "size_bytes": size
                    })
                except Exception:
                    buckets.append({
                        "name": bucket_name,
                        "creation_date": bucket['CreationDate'].isoformat(),
                        "size_bytes": 0,
                        "error": "access_denied"
                    })
            
            duration = (time.time() - start) * 1000
            storage_cost = (total_size / (1024**3)) * 0.023  # $0.023 per GB
            self.log_operation("s3", "analyze_buckets", "success", duration, storage_cost)
            
            logger.info(json.dumps({
                "type": "analysis",
                "service": "s3",
                "total_buckets": len(buckets),
                "total_size_gb": round(total_size / (1024**3), 2),
                "estimated_monthly_cost": round(storage_cost, 2)
            }))
            
            return buckets
            
        except Exception as e:
            self.log_operation("s3", "analyze_buckets", "error")
            logger.error(f"S3 analysis failed: {e}")
            return []
    
    def cost_analysis(self):
        """Real cost analysis using Cost Explorer"""
        try:
            start = time.time()
            ce = self.session.client('ce', region_name='us-east-1')
            
            # Get last 30 days cost
            end_date = datetime.now().strftime('%Y-%m-%d')
            start_date = (datetime.now().replace(day=1)).strftime('%Y-%m-%d')
            
            response = ce.get_cost_and_usage(
                TimePeriod={'Start': start_date, 'End': end_date},
                Granularity='MONTHLY',
                Metrics=['BlendedCost'],
                GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
            )
            
            costs = {}
            total_cost = 0
            for result in response['ResultsByTime']:
                for group in result['Groups']:
                    service = group['Keys'][0]
                    cost = float(group['Metrics']['BlendedCost']['Amount'])
                    costs[service] = cost
                    total_cost += cost
            
            duration = (time.time() - start) * 1000
            self.log_operation("ce", "get_cost_and_usage", "success", duration)
            
            logger.info(json.dumps({
                "type": "cost_analysis",
                "period": f"{start_date} to {end_date}",
                "total_cost_usd": round(total_cost, 2),
                "top_services": dict(sorted(costs.items(), key=lambda x: x[1], reverse=True)[:5])
            }))
            
            return costs
            
        except Exception as e:
            self.log_operation("ce", "get_cost_and_usage", "error")
            logger.error(f"Cost analysis failed: {e}")
            return {}
    
    def security_audit(self):
        """Basic security audit"""
        try:
            iam = self.session.client('iam')
            
            # Check for users without MFA
            users = iam.list_users()['Users']
            no_mfa_users = []
            
            for user in users:
                mfa_devices = iam.list_mfa_devices(UserName=user['UserName'])
                if not mfa_devices['MFADevices']:
                    no_mfa_users.append(user['UserName'])
            
            logger.info(json.dumps({
                "type": "security_audit",
                "total_users": len(users),
                "users_without_mfa": len(no_mfa_users),
                "mfa_compliance": round((len(users) - len(no_mfa_users)) / len(users) * 100, 1) if users else 100
            }))
            
            return {"users_without_mfa": no_mfa_users}
            
        except Exception as e:
            logger.error(f"Security audit failed: {e}")
            return {}
    
    def generate_report(self):
        """Generate comprehensive production report"""
        logger.info("Starting production AWS analysis")
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "account_id": self.session.client('sts').get_caller_identity()['Account'],
            "region": self.session.region_name or "us-east-1",
            "analysis": {}
        }
        
        # Run all analyses
        report["analysis"]["ec2"] = self.analyze_ec2()
        report["analysis"]["s3"] = self.analyze_s3()
        report["analysis"]["costs"] = self.cost_analysis()
        report["analysis"]["security"] = self.security_audit()
        report["metrics"] = self.metrics
        
        # Save report
        report_file = f"aws_production_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        
        logger.info(f"Production report saved: {report_file}")
        logger.info(json.dumps({
            "type": "summary",
            "total_operations": self.metrics["operations"],
            "total_errors": self.metrics["errors"],
            "estimated_cost": self.metrics["cost"],
            "report_file": report_file
        }))
        
        return report

if __name__ == "__main__":
    try:
        manager = ProductionAWSManager()
        report = manager.generate_report()
        print(f"✅ Production analysis complete. Check logs in {log_dir}")
    except Exception as e:
        logger.error(f"Production run failed: {e}")
        exit(1)