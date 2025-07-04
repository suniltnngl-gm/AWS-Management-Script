#!/usr/bin/env python3

"""
Small Business AWS Cost Manager
Simple, practical tools for small teams and startups
"""

import json
import subprocess
from datetime import datetime

class SmallBusinessManager:
    def __init__(self, monthly_budget=100):
        self.budget = monthly_budget
        self.team_size = 5  # Default small team
        
    def get_simple_cost_overview(self):
        """Simple cost overview for small business"""
        try:
            result = subprocess.run([
                'aws', 'ce', 'get-cost-and-usage',
                '--time-period', f'Start={self._get_date(-30)},End={self._get_date(0)}',
                '--granularity', 'MONTHLY', '--metrics', 'BlendedCost'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                data = json.loads(result.stdout)
                current_spend = float(data.get('ResultsByTime', [{}])[0]
                                    .get('Total', {}).get('BlendedCost', {}).get('Amount', '0'))
            else:
                current_spend = 0
        except:
            current_spend = 0
        
        return {
            'current_spend': current_spend,
            'budget': self.budget,
            'remaining': max(0, self.budget - current_spend),
            'status': '🔴 OVER BUDGET' if current_spend > self.budget else '🟢 ON TRACK',
            'per_team_member': current_spend / self.team_size if self.team_size > 0 else 0
        }
    
    def get_startup_recommendations(self):
        """Practical recommendations for startups"""
        cost_overview = self.get_simple_cost_overview()
        recommendations = []
        
        # Free tier maximization
        recommendations.append({
            'priority': 'HIGH',
            'action': 'Use AWS Free Tier',
            'details': 't2.micro (750 hours), 5GB S3, 1M Lambda requests',
            'savings': '$50-100/month'
        })
        
        # Development environment optimization
        recommendations.append({
            'priority': 'HIGH',
            'action': 'Stop dev instances after hours',
            'details': 'Auto-stop at 6PM, start at 8AM weekdays',
            'savings': '$30-60/month'
        })
        
        # Simple monitoring
        recommendations.append({
            'priority': 'MEDIUM',
            'action': 'Set up billing alerts',
            'details': f'Alert at ${self.budget * 0.8:.0f} (80% of budget)',
            'cost': '$0 (free)'
        })
        
        if cost_overview['current_spend'] > self.budget * 0.5:
            recommendations.append({
                'priority': 'HIGH',
                'action': 'Review and downsize resources',
                'details': 'Switch to smaller instance types, use spot instances',
                'savings': f'${cost_overview["current_spend"] * 0.3:.0f}/month'
            })
        
        return recommendations
    
    def create_simple_architecture(self):
        """Simple, cost-effective architecture for small business"""
        if self.budget <= 50:
            # Ultra-low budget
            return {
                'compute': 't2.micro (free tier)',
                'storage': 'S3 (5GB free)',
                'database': 'DynamoDB (25GB free)',
                'cdn': 'CloudFront (50GB free)',
                'monitoring': 'CloudWatch (basic free)',
                'estimated_cost': '$0-10/month',
                'suitable_for': 'MVP, prototype, small websites'
            }
        elif self.budget <= 100:
            # Small business budget
            return {
                'compute': '1x t3.small + Lambda',
                'storage': 'S3 + EBS (20GB)',
                'database': 'RDS t3.micro or DynamoDB',
                'cdn': 'CloudFront',
                'monitoring': 'CloudWatch + SNS alerts',
                'estimated_cost': '$40-80/month',
                'suitable_for': 'Small web apps, APIs, small databases'
            }
        else:
            # Growing business
            return {
                'compute': '2x t3.small + auto-scaling',
                'storage': 'S3 + EBS (50GB)',
                'database': 'RDS t3.small with backup',
                'cdn': 'CloudFront + Route53',
                'monitoring': 'Enhanced monitoring + alerts',
                'estimated_cost': '$80-150/month',
                'suitable_for': 'Production apps, multiple environments'
            }
    
    def generate_weekly_report(self):
        """Simple weekly report for small teams"""
        cost_overview = self.get_simple_cost_overview()
        recommendations = self.get_startup_recommendations()
        
        report = f"""
📊 WEEKLY AWS COST REPORT
========================
Date: {datetime.now().strftime('%Y-%m-%d')}
Team Budget: ${self.budget}/month

💰 SPENDING SUMMARY
Current Month: ${cost_overview['current_spend']:.2f}
Budget Remaining: ${cost_overview['remaining']:.2f}
Status: {cost_overview['status']}
Per Team Member: ${cost_overview['per_team_member']:.2f}

🎯 TOP RECOMMENDATIONS
"""
        
        for i, rec in enumerate(recommendations[:3], 1):
            report += f"{i}. {rec['action']} ({rec['priority']})\n"
            report += f"   {rec['details']}\n"
            if 'savings' in rec:
                report += f"   💰 Potential savings: {rec['savings']}\n"
            report += "\n"
        
        return report
    
    def emergency_cost_control(self):
        """Emergency actions for small business"""
        cost_overview = self.get_simple_cost_overview()
        
        if cost_overview['current_spend'] <= self.budget:
            return {'emergency': False, 'message': '✅ Spending within budget'}
        
        overage = cost_overview['current_spend'] - self.budget
        actions = []
        
        # Immediate actions
        actions.append('🚨 STOP all non-production EC2 instances')
        actions.append('🚨 PAUSE non-critical services')
        actions.append('🚨 SWITCH to spot instances where possible')
        
        if overage > self.budget * 0.5:  # 50% over budget
            actions.append('🚨 EMERGENCY: Contact AWS support for billing review')
        
        return {
            'emergency': True,
            'overage': overage,
            'actions': actions,
            'message': f'⚠️ ${overage:.2f} over budget - immediate action required'
        }
    
    def _get_date(self, days_offset):
        from datetime import timedelta
        return (datetime.now() + timedelta(days=days_offset)).strftime('%Y-%m-%d')

def main():
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 small_business.py {overview|recommendations|architecture|report|emergency} [budget]")
        return
    
    command = sys.argv[1]
    budget = float(sys.argv[2]) if len(sys.argv) > 2 else 100
    
    manager = SmallBusinessManager(budget)
    
    if command == 'overview':
        overview = manager.get_simple_cost_overview()
        print("💰 Cost Overview:")
        print(f"  Current spend: ${overview['current_spend']:.2f}")
        print(f"  Monthly budget: ${overview['budget']:.2f}")
        print(f"  Remaining: ${overview['remaining']:.2f}")
        print(f"  Status: {overview['status']}")
        print(f"  Per team member: ${overview['per_team_member']:.2f}")
        
    elif command == 'recommendations':
        recs = manager.get_startup_recommendations()
        print("🎯 Startup Recommendations:")
        for i, rec in enumerate(recs, 1):
            print(f"  {i}. {rec['action']} ({rec['priority']})")
            print(f"     {rec['details']}")
            if 'savings' in rec:
                print(f"     💰 Savings: {rec['savings']}")
            print()
            
    elif command == 'architecture':
        arch = manager.create_simple_architecture()
        print(f"🏗️ Simple Architecture (Budget: ${budget}):")
        print(f"  Compute: {arch['compute']}")
        print(f"  Storage: {arch['storage']}")
        print(f"  Database: {arch['database']}")
        print(f"  CDN: {arch['cdn']}")
        print(f"  Cost: {arch['estimated_cost']}")
        print(f"  Best for: {arch['suitable_for']}")
        
    elif command == 'report':
        report = manager.generate_weekly_report()
        print(report)
        
    elif command == 'emergency':
        emergency = manager.emergency_cost_control()
        if emergency['emergency']:
            print(emergency['message'])
            print("\n🚨 EMERGENCY ACTIONS:")
            for action in emergency['actions']:
                print(f"  {action}")
        else:
            print(emergency['message'])
    
    else:
        print(f"Unknown command: {command}")

if __name__ == '__main__':
    main()