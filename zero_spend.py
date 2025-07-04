#!/usr/bin/env python3

"""
Zero Spend Strategy - Cost-optimized resource utilization
Budget-based load balancing and availability management
"""

import json
import subprocess
import time
from datetime import datetime, timedelta

class ZeroSpendManager:
    def __init__(self, budget=0):
        self.budget = float(budget)
        self.current_spend = 0
        self.resources = {}
        
    def analyze_spend(self):
        """Get current AWS spend"""
        try:
            result = subprocess.run([
                'aws', 'ce', 'get-cost-and-usage',
                '--time-period', f'Start={self._get_date(-30)},End={self._get_date(0)}',
                '--granularity', 'MONTHLY', '--metrics', 'BlendedCost'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                data = json.loads(result.stdout)
                self.current_spend = float(data.get('ResultsByTime', [{}])[0]
                                         .get('Total', {}).get('BlendedCost', {}).get('Amount', '0'))
        except:
            self.current_spend = 0
        
        return {
            'current_spend': self.current_spend,
            'budget': self.budget,
            'remaining': max(0, self.budget - self.current_spend),
            'status': 'OVER_BUDGET' if self.current_spend > self.budget else 'OK'
        }
    
    def get_free_resources(self):
        """Identify free-tier and zero-cost resources"""
        free_resources = {
            'ec2': {
                't2.micro': {'hours': 750, 'cost': 0},  # Free tier
                't3.micro': {'hours': 750, 'cost': 0}   # Free tier
            },
            'lambda': {
                'requests': 1000000,  # 1M free requests
                'compute': 400000,    # 400K GB-seconds
                'cost': 0
            },
            's3': {
                'storage': 5,         # 5GB free
                'requests': 20000,    # 20K GET requests
                'cost': 0
            },
            'cloudfront': {
                'data_transfer': 50,  # 50GB free
                'requests': 2000000,  # 2M requests
                'cost': 0
            },
            'rds': {
                'db.t2.micro': {'hours': 750, 'cost': 0}  # Free tier
            }
        }
        return free_resources
    
    def optimize_for_zero_spend(self):
        """Optimize resources for zero spend"""
        recommendations = []
        
        # Stop non-essential instances
        try:
            result = subprocess.run([
                'aws', 'ec2', 'describe-instances',
                '--query', 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,Tags[?Key==`Environment`].Value|[0]]',
                '--output', 'json'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                instances = json.loads(result.stdout)
                for instance in instances:
                    instance_id, instance_type, env = instance[0], instance[1], instance[2] or 'unknown'
                    
                    if instance_type not in ['t2.micro', 't3.micro']:
                        recommendations.append({
                            'action': 'STOP_INSTANCE',
                            'resource': instance_id,
                            'reason': f'Non-free tier instance: {instance_type}',
                            'savings': self._estimate_instance_cost(instance_type)
                        })
                    
                    if env.lower() in ['dev', 'test', 'staging']:
                        recommendations.append({
                            'action': 'SCHEDULE_STOP',
                            'resource': instance_id,
                            'reason': 'Non-production environment',
                            'schedule': 'Stop 6PM-8AM, weekends'
                        })
        except:
            pass
        
        return recommendations
    
    def implement_load_balancing(self, target_availability=99.0):
        """Budget-based load balancing strategy"""
        strategy = {
            'primary': 'free_tier_instances',
            'scaling': 'horizontal_free_tier',
            'availability_target': target_availability,
            'cost_target': 0
        }
        
        if self.budget > 0:
            # Use budget for critical availability
            strategy.update({
                'backup_instances': min(2, int(self.budget / 10)),  # $10/instance/month
                'reserved_instances': self.budget > 100,
                'multi_az': self.budget > 50
            })
        
        return {
            'strategy': strategy,
            'implementation': [
                'Use t2.micro/t3.micro instances (free tier)',
                'Implement auto-scaling with free tier limits',
                'Use CloudFront for caching (50GB free)',
                'Lambda for serverless compute (1M requests free)',
                'S3 for storage (5GB free)',
                f'Target availability: {target_availability}%'
            ]
        }
    
    def emergency_cost_control(self):
        """Emergency actions when over budget"""
        actions = []
        
        if self.current_spend > self.budget:
            actions = [
                {'action': 'STOP_ALL_NON_PROD', 'priority': 1},
                {'action': 'DOWNSIZE_TO_FREE_TIER', 'priority': 2},
                {'action': 'ENABLE_SPOT_INSTANCES', 'priority': 3},
                {'action': 'PAUSE_NON_CRITICAL_SERVICES', 'priority': 4}
            ]
        
        return {
            'triggered': len(actions) > 0,
            'actions': actions,
            'estimated_savings': self.current_spend - self.budget
        }
    
    def generate_zero_spend_architecture(self):
        """Generate architecture for zero spend"""
        return {
            'compute': {
                'primary': 'AWS Lambda (1M requests free)',
                'backup': 't2.micro EC2 (750 hours free)',
                'scaling': 'Horizontal scaling with free tier'
            },
            'storage': {
                'primary': 'S3 (5GB free)',
                'backup': 'EBS with free tier instances'
            },
            'networking': {
                'cdn': 'CloudFront (50GB free)',
                'load_balancer': 'Application Load Balancer (free tier)',
                'dns': 'Route 53 (hosted zone only cost)'
            },
            'database': {
                'primary': 'DynamoDB (25GB free)',
                'backup': 'RDS t2.micro (750 hours free)'
            },
            'monitoring': {
                'logs': 'CloudWatch Logs (5GB free)',
                'metrics': 'CloudWatch (10 metrics free)',
                'alerts': 'SNS (1000 notifications free)'
            },
            'estimated_monthly_cost': 0,
            'availability_target': '99%+',
            'scalability': 'Auto-scaling within free limits'
        }
    
    def _estimate_instance_cost(self, instance_type):
        """Estimate monthly cost for instance type"""
        costs = {
            't2.small': 16.79, 't2.medium': 33.58, 't2.large': 67.16,
            't3.small': 15.18, 't3.medium': 30.37, 't3.large': 60.74,
            'm5.large': 70.08, 'm5.xlarge': 140.16
        }
        return costs.get(instance_type, 50)
    
    def _get_date(self, days_offset):
        return (datetime.now() + timedelta(days=days_offset)).strftime('%Y-%m-%d')

def main():
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 zero_spend.py {analyze|optimize|balance|emergency|architecture} [budget]")
        return
    
    command = sys.argv[1]
    budget = float(sys.argv[2]) if len(sys.argv) > 2 else 0
    
    manager = ZeroSpendManager(budget)
    
    if command == 'analyze':
        result = manager.analyze_spend()
        print(f"💰 Current spend: ${result['current_spend']:.2f}")
        print(f"🎯 Budget: ${result['budget']:.2f}")
        print(f"💵 Remaining: ${result['remaining']:.2f}")
        print(f"📊 Status: {result['status']}")
        
    elif command == 'optimize':
        recommendations = manager.optimize_for_zero_spend()
        print("🔧 Zero Spend Optimizations:")
        for rec in recommendations:
            print(f"  • {rec['action']}: {rec['reason']}")
            if 'savings' in rec:
                print(f"    Savings: ${rec['savings']:.2f}/month")
                
    elif command == 'balance':
        strategy = manager.implement_load_balancing()
        print("⚖️ Load Balancing Strategy:")
        for impl in strategy['implementation']:
            print(f"  • {impl}")
            
    elif command == 'emergency':
        emergency = manager.emergency_cost_control()
        if emergency['triggered']:
            print("🚨 EMERGENCY COST CONTROL ACTIVATED")
            for action in emergency['actions']:
                print(f"  {action['priority']}. {action['action']}")
        else:
            print("✅ No emergency actions needed")
            
    elif command == 'architecture':
        arch = manager.generate_zero_spend_architecture()
        print("🏗️ Zero Spend Architecture:")
        print(f"  Compute: {arch['compute']['primary']}")
        print(f"  Storage: {arch['storage']['primary']}")
        print(f"  CDN: {arch['networking']['cdn']}")
        print(f"  Database: {arch['database']['primary']}")
        print(f"  💰 Estimated cost: ${arch['estimated_monthly_cost']}")
        print(f"  📈 Availability: {arch['availability_target']}")
    
    else:
        print(f"Unknown command: {command}")

if __name__ == '__main__':
    main()