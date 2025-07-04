#!/usr/bin/env python3

"""
Budget-Based Load Balancer & Availability Manager
Real-time resource scaling based on budget constraints
"""

import json
import time
from datetime import datetime

class BudgetBalancer:
    def __init__(self, budget=0):
        self.budget = budget
        self.free_tier_limits = {
            'ec2_hours': 750,      # t2.micro/t3.micro
            'lambda_requests': 1000000,
            'lambda_compute': 400000,
            's3_storage': 5,       # GB
            'cloudfront_transfer': 50,  # GB
            'rds_hours': 750       # db.t2.micro
        }
        
    def calculate_optimal_distribution(self, workload_requirements):
        """Calculate optimal resource distribution for budget"""
        distribution = {
            'serverless_percentage': 80,  # Prefer Lambda (free)
            'container_percentage': 15,   # ECS Fargate spot
            'vm_percentage': 5,           # EC2 free tier
            'estimated_cost': 0
        }
        
        if self.budget > 0:
            # Adjust based on budget
            if self.budget >= 100:
                distribution.update({
                    'serverless_percentage': 60,
                    'container_percentage': 25,
                    'vm_percentage': 15,
                    'reserved_instances': True
                })
            elif self.budget >= 50:
                distribution.update({
                    'serverless_percentage': 70,
                    'container_percentage': 20,
                    'vm_percentage': 10
                })
        
        return distribution
    
    def implement_availability_strategy(self, target_availability=99.0):
        """Implement availability strategy within budget"""
        if self.budget == 0:
            # Zero budget - maximum free tier usage
            strategy = {
                'primary_region': 'us-east-1',  # Cheapest
                'backup_regions': [],
                'instances': [
                    {'type': 't2.micro', 'count': 1, 'cost': 0},
                    {'type': 'lambda', 'requests': 1000000, 'cost': 0}
                ],
                'load_balancing': 'Application Load Balancer (free tier)',
                'auto_scaling': 'Scale within free limits',
                'availability': f'{target_availability}%'
            }
        else:
            # Budget available - enhanced availability
            backup_regions = min(2, int(self.budget / 30))  # $30/region/month
            strategy = {
                'primary_region': 'us-east-1',
                'backup_regions': ['us-west-2', 'eu-west-1'][:backup_regions],
                'instances': self._calculate_instance_distribution(),
                'load_balancing': 'Multi-AZ Application Load Balancer',
                'auto_scaling': 'Dynamic scaling with budget limits',
                'availability': f'{min(99.99, target_availability + (self.budget / 100))}%'
            }
        
        return strategy
    
    def real_time_cost_control(self):
        """Real-time cost monitoring and control"""
        current_hour_cost = self._estimate_current_hour_cost()
        monthly_projection = current_hour_cost * 24 * 30
        
        actions = []
        
        if monthly_projection > self.budget:
            # Immediate cost reduction actions
            overage = monthly_projection - self.budget
            
            if overage > self.budget * 0.5:  # 50% over budget
                actions.extend([
                    {'action': 'EMERGENCY_SCALE_DOWN', 'priority': 1},
                    {'action': 'SWITCH_TO_SPOT_INSTANCES', 'priority': 2},
                    {'action': 'PAUSE_NON_CRITICAL', 'priority': 3}
                ])
            elif overage > self.budget * 0.2:  # 20% over budget
                actions.extend([
                    {'action': 'GRADUAL_SCALE_DOWN', 'priority': 1},
                    {'action': 'OPTIMIZE_INSTANCE_TYPES', 'priority': 2}
                ])
        
        return {
            'current_projection': monthly_projection,
            'budget_status': 'OVER' if monthly_projection > self.budget else 'OK',
            'actions_needed': actions,
            'recommended_scaling': self._get_scaling_recommendation(monthly_projection)
        }
    
    def generate_cost_optimized_config(self):
        """Generate infrastructure config optimized for cost"""
        if self.budget == 0:
            return {
                'compute': {
                    'lambda_functions': {
                        'memory': 128,  # Minimum
                        'timeout': 30,  # Reasonable
                        'concurrent_executions': 1000
                    },
                    'ec2_instances': {
                        'type': 't2.micro',
                        'count': 1,
                        'spot_instances': False  # Free tier doesn't support spot
                    }
                },
                'storage': {
                    's3_buckets': {
                        'storage_class': 'STANDARD',
                        'lifecycle_policy': 'Delete after 30 days'
                    }
                },
                'networking': {
                    'cloudfront': {
                        'caching_behavior': 'Aggressive',
                        'compression': True
                    }
                },
                'estimated_monthly_cost': 0
            }
        else:
            return {
                'compute': {
                    'lambda_functions': {
                        'memory': 256,
                        'timeout': 60,
                        'concurrent_executions': min(10000, self.budget * 100)
                    },
                    'ec2_instances': {
                        'type': 't3.small' if self.budget > 20 else 't2.micro',
                        'count': min(5, int(self.budget / 15)),
                        'spot_instances': self.budget > 10
                    },
                    'ecs_fargate': {
                        'cpu': 256,
                        'memory': 512,
                        'spot': True
                    } if self.budget > 30 else None
                },
                'storage': {
                    's3_buckets': {
                        'storage_class': 'INTELLIGENT_TIERING',
                        'lifecycle_policy': 'Transition to IA after 30 days'
                    }
                },
                'database': {
                    'dynamodb': {
                        'billing_mode': 'ON_DEMAND',
                        'backup': self.budget > 50
                    }
                },
                'estimated_monthly_cost': min(self.budget * 0.9, self.budget - 5)
            }
    
    def _calculate_instance_distribution(self):
        """Calculate optimal instance distribution"""
        if self.budget == 0:
            return [{'type': 't2.micro', 'count': 1, 'cost': 0}]
        
        instances = []
        remaining_budget = self.budget
        
        # Primary instances
        if remaining_budget >= 15:
            instances.append({'type': 't3.small', 'count': 1, 'cost': 15})
            remaining_budget -= 15
        
        # Additional instances based on remaining budget
        additional_instances = int(remaining_budget / 10)
        if additional_instances > 0:
            instances.append({
                'type': 't2.micro', 
                'count': additional_instances, 
                'cost': additional_instances * 10
            })
        
        return instances
    
    def _estimate_current_hour_cost(self):
        """Estimate current hourly cost"""
        # Simplified estimation - would integrate with AWS Cost Explorer
        return max(0.01, self.budget / (30 * 24))  # Spread budget over month
    
    def _get_scaling_recommendation(self, projected_cost):
        """Get scaling recommendation based on projection"""
        if projected_cost <= self.budget * 0.8:
            return 'SCALE_UP_AVAILABLE'
        elif projected_cost <= self.budget:
            return 'MAINTAIN_CURRENT'
        else:
            return 'SCALE_DOWN_REQUIRED'

def main():
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: python3 budget_balancer.py {distribute|availability|control|config} <budget>")
        return
    
    command = sys.argv[1]
    budget = float(sys.argv[2])
    
    balancer = BudgetBalancer(budget)
    
    if command == 'distribute':
        result = balancer.calculate_optimal_distribution({})
        print(f"⚖️ Optimal Distribution (Budget: ${budget}):")
        print(f"  Serverless: {result['serverless_percentage']}%")
        print(f"  Containers: {result['container_percentage']}%")
        print(f"  VMs: {result['vm_percentage']}%")
        print(f"  Estimated cost: ${result['estimated_cost']}")
        
    elif command == 'availability':
        strategy = balancer.implement_availability_strategy()
        print(f"🎯 Availability Strategy (Budget: ${budget}):")
        print(f"  Primary region: {strategy['primary_region']}")
        print(f"  Backup regions: {len(strategy['backup_regions'])}")
        print(f"  Load balancing: {strategy['load_balancing']}")
        print(f"  Target availability: {strategy['availability']}")
        
    elif command == 'control':
        control = balancer.real_time_cost_control()
        print(f"💰 Cost Control (Budget: ${budget}):")
        print(f"  Projected monthly: ${control['current_projection']:.2f}")
        print(f"  Status: {control['budget_status']}")
        print(f"  Scaling: {control['recommended_scaling']}")
        if control['actions_needed']:
            print("  Actions needed:")
            for action in control['actions_needed']:
                print(f"    {action['priority']}. {action['action']}")
                
    elif command == 'config':
        config = balancer.generate_cost_optimized_config()
        print(f"🔧 Optimized Config (Budget: ${budget}):")
        if 'lambda_functions' in config['compute']:
            print(f"  Lambda memory: {config['compute']['lambda_functions']['memory']}MB")
        if 'ec2_instances' in config['compute']:
            ec2 = config['compute']['ec2_instances']
            print(f"  EC2: {ec2['count']}x {ec2['type']}")
        print(f"  Estimated cost: ${config.get('estimated_monthly_cost', 0)}")

if __name__ == '__main__':
    main()