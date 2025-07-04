#!/usr/bin/env python3

"""
Startup Cost Optimizer
Practical cost optimization for small teams with limited budgets
"""

import json
from datetime import datetime

class StartupOptimizer:
    def __init__(self, budget=50):
        self.budget = budget
        self.free_tier_resources = {
            'ec2': {'t2.micro': 750, 't3.micro': 750},  # hours/month
            'lambda': {'requests': 1000000, 'compute_seconds': 400000},
            's3': {'storage_gb': 5, 'requests': 20000},
            'dynamodb': {'storage_gb': 25, 'read_units': 25, 'write_units': 25},
            'cloudfront': {'data_transfer_gb': 50, 'requests': 2000000}
        }
    
    def optimize_for_startup(self):
        """Optimize AWS usage for startup/small business"""
        optimizations = []
        
        # Free tier maximization
        optimizations.append({
            'category': 'Free Tier',
            'action': 'Maximize free tier usage',
            'steps': [
                'Use t2.micro/t3.micro instances (750 hours free)',
                'Store files in S3 (5GB free)',
                'Use DynamoDB for database (25GB free)',
                'Implement Lambda functions (1M requests free)',
                'Use CloudFront CDN (50GB transfer free)'
            ],
            'monthly_savings': '$50-100'
        })
        
        # Development environment optimization
        optimizations.append({
            'category': 'Dev Environment',
            'action': 'Optimize development costs',
            'steps': [
                'Auto-stop dev instances at 6PM weekdays',
                'Use spot instances for testing (70% cheaper)',
                'Share dev environments among team',
                'Use local development when possible'
            ],
            'monthly_savings': '$30-60'
        })
        
        # Simple monitoring
        optimizations.append({
            'category': 'Monitoring',
            'action': 'Set up cost alerts',
            'steps': [
                f'Create billing alert at ${self.budget * 0.8:.0f}',
                'Use CloudWatch free tier (10 metrics)',
                'Set up SNS notifications (1000 free)',
                'Monitor top 3 services only'
            ],
            'monthly_cost': '$0-5'
        })
        
        return optimizations
    
    def create_startup_budget_plan(self):
        """Create realistic budget plan for startups"""
        if self.budget <= 25:
            return {
                'tier': 'Bootstrap',
                'allocation': {
                    'compute': '$0 (free tier only)',
                    'storage': '$0-5 (mostly free)',
                    'database': '$0 (DynamoDB free)',
                    'networking': '$0 (CloudFront free)',
                    'monitoring': '$0 (basic free)'
                },
                'recommendations': [
                    'Stay within free tier limits',
                    'Use serverless architecture',
                    'Minimize data transfer',
                    'Monitor usage daily'
                ]
            }
        elif self.budget <= 100:
            return {
                'tier': 'Small Business',
                'allocation': {
                    'compute': f'${self.budget * 0.4:.0f} (40%)',
                    'storage': f'${self.budget * 0.2:.0f} (20%)',
                    'database': f'${self.budget * 0.2:.0f} (20%)',
                    'networking': f'${self.budget * 0.1:.0f} (10%)',
                    'monitoring': f'${self.budget * 0.1:.0f} (10%)'
                },
                'recommendations': [
                    'Mix free tier with paid services',
                    'Use reserved instances for predictable workloads',
                    'Implement auto-scaling',
                    'Regular cost reviews'
                ]
            }
        else:
            return {
                'tier': 'Growing Startup',
                'allocation': {
                    'compute': f'${self.budget * 0.5:.0f} (50%)',
                    'storage': f'${self.budget * 0.15:.0f} (15%)',
                    'database': f'${self.budget * 0.15:.0f} (15%)',
                    'networking': f'${self.budget * 0.1:.0f} (10%)',
                    'monitoring': f'${self.budget * 0.1:.0f} (10%)'
                },
                'recommendations': [
                    'Invest in reserved instances',
                    'Use multiple availability zones',
                    'Implement comprehensive monitoring',
                    'Plan for scaling'
                ]
            }
    
    def generate_quick_wins(self):
        """Generate immediate cost-saving actions"""
        quick_wins = [
            {
                'action': 'Stop unused EC2 instances',
                'time': '5 minutes',
                'savings': '$20-50/month',
                'command': 'aws ec2 stop-instances --instance-ids i-1234567890abcdef0'
            },
            {
                'action': 'Delete unused EBS volumes',
                'time': '10 minutes', 
                'savings': '$5-20/month',
                'command': 'aws ec2 describe-volumes --filters Name=status,Values=available'
            },
            {
                'action': 'Set up S3 lifecycle policies',
                'time': '15 minutes',
                'savings': '$10-30/month',
                'command': 'Transition old files to cheaper storage classes'
            },
            {
                'action': 'Enable detailed billing',
                'time': '5 minutes',
                'savings': 'Better visibility',
                'command': 'Enable in AWS Console > Billing > Preferences'
            }
        ]
        return quick_wins
    
    def create_simple_dashboard(self):
        """Create simple cost tracking dashboard"""
        return {
            'daily_checks': [
                'Check current month spend',
                'Review top 3 services by cost',
                'Verify no unexpected charges'
            ],
            'weekly_tasks': [
                'Review and stop unused resources',
                'Check free tier usage limits',
                'Update cost forecasts'
            ],
            'monthly_reviews': [
                'Analyze cost trends',
                'Optimize resource allocation',
                'Plan next month budget'
            ],
            'tools': [
                'AWS Cost Explorer (free)',
                'AWS Budgets (first 2 free)',
                'CloudWatch billing metrics (free)'
            ]
        }
    
    def emergency_shutdown_plan(self):
        """Emergency plan to minimize costs immediately"""
        return {
            'immediate_actions': [
                '🚨 Stop all non-production EC2 instances',
                '🚨 Pause auto-scaling groups',
                '🚨 Stop RDS instances (if not needed)',
                '🚨 Disable non-critical Lambda functions'
            ],
            'within_1_hour': [
                'Review and delete unused resources',
                'Switch to smaller instance types',
                'Enable spot instances where possible',
                'Contact AWS support if needed'
            ],
            'recovery_plan': [
                'Restart critical services only',
                'Implement stricter cost controls',
                'Set up real-time alerts',
                'Review architecture for cost optimization'
            ]
        }

def main():
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 startup_optimizer.py {optimize|budget|wins|dashboard|emergency} [budget]")
        return
    
    command = sys.argv[1]
    budget = float(sys.argv[2]) if len(sys.argv) > 2 else 50
    
    optimizer = StartupOptimizer(budget)
    
    if command == 'optimize':
        optimizations = optimizer.optimize_for_startup()
        print(f"🚀 Startup Optimizations (Budget: ${budget}):")
        for opt in optimizations:
            print(f"\n📂 {opt['category']}: {opt['action']}")
            for step in opt['steps']:
                print(f"  • {step}")
            if 'monthly_savings' in opt:
                print(f"  💰 Savings: {opt['monthly_savings']}")
                
    elif command == 'budget':
        plan = optimizer.create_startup_budget_plan()
        print(f"💰 Budget Plan: {plan['tier']} (${budget}/month)")
        print("\n📊 Allocation:")
        for category, amount in plan['allocation'].items():
            print(f"  {category.title()}: {amount}")
        print("\n🎯 Recommendations:")
        for rec in plan['recommendations']:
            print(f"  • {rec}")
            
    elif command == 'wins':
        wins = optimizer.generate_quick_wins()
        print("⚡ Quick Wins:")
        for i, win in enumerate(wins, 1):
            print(f"\n{i}. {win['action']}")
            print(f"   Time: {win['time']}")
            print(f"   Savings: {win['savings']}")
            print(f"   Action: {win['command']}")
            
    elif command == 'dashboard':
        dashboard = optimizer.create_simple_dashboard()
        print("📊 Simple Cost Dashboard:")
        print("\n📅 Daily (2 minutes):")
        for task in dashboard['daily_checks']:
            print(f"  • {task}")
        print("\n📅 Weekly (15 minutes):")
        for task in dashboard['weekly_tasks']:
            print(f"  • {task}")
        print("\n📅 Monthly (30 minutes):")
        for task in dashboard['monthly_reviews']:
            print(f"  • {task}")
            
    elif command == 'emergency':
        plan = optimizer.emergency_shutdown_plan()
        print("🚨 EMERGENCY COST CONTROL PLAN")
        print("\n⚡ Immediate (0-15 minutes):")
        for action in plan['immediate_actions']:
            print(f"  {action}")
        print("\n🔧 Within 1 Hour:")
        for action in plan['within_1_hour']:
            print(f"  • {action}")
        print("\n🔄 Recovery Plan:")
        for action in plan['recovery_plan']:
            print(f"  • {action}")
    
    else:
        print(f"Unknown command: {command}")

if __name__ == '__main__':
    main()