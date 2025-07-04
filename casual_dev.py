#!/usr/bin/env python3

"""
Casual Developer AWS Helper
Simple, friendly tool for developers who just want things to work
No jargon, no complexity - just practical help
"""

import json
import subprocess

class CasualDevHelper:
    def __init__(self):
        self.friendly_names = {
            'ec2': 'servers',
            'rds': 'databases', 
            's3': 'file storage',
            'lambda': 'functions',
            'cloudfront': 'fast delivery'
        }
    
    def whats_costing_me_money(self):
        """Show what's actually costing money in plain English"""
        print("💰 What's costing you money right now:")
        print("⏳ Checking your AWS costs...")
        print()
        
        # Try to get real data, fallback to examples
        try:
            result = subprocess.run(['aws', 'ce', 'get-cost-and-usage', 
                                   '--time-period', 'Start=2024-06-01,End=2024-07-01',
                                   '--granularity', 'MONTHLY', '--metrics', 'BlendedCost',
                                   '--group-by', 'Type=DIMENSION,Key=SERVICE'], 
                                  capture_output=True, text=True, timeout=10)
        except FileNotFoundError:
            print("💡 AWS CLI not found. Install with: pip install awscli")
            self._show_example_costs()
            return
        except Exception as e:
            print(f"⚠️ Couldn't fetch real costs: {str(e)}")
            self._show_example_costs()
            return
        
        try:
            if result.returncode == 0:
                data = json.loads(result.stdout)
                services = data.get('ResultsByTime', [{}])[0].get('Groups', [])
                for service in services[:5]:
                    service_name = service['Keys'][0]
                    cost = float(service['Metrics']['BlendedCost']['Amount'])
                    if cost > 0.01:
                        friendly_name = self.friendly_names.get(service_name.lower(), service_name)
                        print(f"  • {friendly_name}: ${cost:.2f}")
            else:
                self._show_example_costs()
        except:
            self._show_example_costs()
    
    def _show_example_costs(self):
        """Show example costs when real data isn't available"""
        print("  • Servers (EC2): $23.50")
        print("  • File storage (S3): $2.30") 
        print("  • Databases (RDS): $15.80")
        print("  • Functions (Lambda): $0.50")
        print()
        print("💡 Tip: Run 'aws configure' to see your actual costs")
    
    def how_to_save_money(self):
        """Simple money-saving tips"""
        print("💡 Easy ways to save money:")
        print()
        print("🔴 Stop stuff you're not using:")
        print("  • Turn off dev servers at night")
        print("  • Delete old files you don't need")
        print("  • Remove unused databases")
        print()
        print("🟡 Use free stuff:")
        print("  • t2.micro servers (750 hours free)")
        print("  • 5GB file storage free")
        print("  • 1 million function calls free")
        print()
        print("🟢 Smart choices:")
        print("  • Use 'spot instances' for testing (70% cheaper)")
        print("  • Set up auto-shutdown for dev environments")
        print("  • Move old files to cheaper storage")
    
    def fix_my_bill(self, budget=100):
        """Emergency bill reduction"""
        print(f"🚨 Emergency: Reduce your AWS bill to under ${budget}")
        print()
        print("Do these RIGHT NOW (in order):")
        print()
        print("1. Stop all servers you're not using:")
        print("   aws ec2 describe-instances")
        print("   aws ec2 stop-instances --instance-ids i-XXXXXXX")
        print()
        print("2. Delete unused storage:")
        print("   Check S3 buckets and delete old files")
        print("   Remove unused EBS volumes")
        print()
        print("3. Pause databases if possible:")
        print("   aws rds stop-db-instance --db-instance-identifier mydb")
        print()
        print("4. Set up billing alerts:")
        print(f"   Alert when you hit ${budget * 0.8:.0f}")
        print()
        print("💡 This should cut your bill by 50-80%")
    
    def setup_simple_monitoring(self):
        """Set up basic monitoring that actually works"""
        print("📊 Set up simple monitoring (5 minutes):")
        print()
        print("1. Go to AWS Console > Billing")
        print("2. Click 'Budgets' > 'Create budget'")
        print("3. Set amount to your monthly limit")
        print("4. Add your email for alerts")
        print("5. Set alert at 80% of budget")
        print()
        print("That's it! You'll get emails when you're spending too much.")
        print()
        print("🔧 For developers:")
        print("  • Check costs weekly (Friday afternoon)")
        print("  • Turn off dev stuff over weekends")
        print("  • Use free tier as much as possible")
    
    def simple_architecture(self, app_type="web app"):
        """Suggest simple, cheap architecture"""
        print(f"🏗️ Simple setup for your {app_type}:")
        print()
        
        if "web" in app_type.lower():
            print("For a web app:")
            print("  • 1 small server (t3.micro) - $9/month")
            print("  • File storage (S3) - $1-5/month") 
            print("  • Database (DynamoDB free tier) - $0")
            print("  • Fast delivery (CloudFront) - $0-2/month")
            print("  • Total: ~$10-15/month")
        elif "api" in app_type.lower():
            print("For an API:")
            print("  • Functions (Lambda) - $0-5/month")
            print("  • Database (DynamoDB) - $0-10/month")
            print("  • API Gateway - $0-5/month")
            print("  • Total: ~$0-20/month")
        else:
            print("General setup:")
            print("  • Start with 1 small server")
            print("  • Use free database tier")
            print("  • Add file storage as needed")
            print("  • Scale up only when necessary")
        
        print()
        print("💡 Start small, grow as needed!")
    
    def weekend_shutdown(self):
        """Set up weekend cost savings"""
        print("🏖️ Save money on weekends:")
        print()
        print("Auto-shutdown script (save as weekend_shutdown.sh):")
        print()
        print("#!/bin/bash")
        print("# Run this Friday evening")
        print("aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances \\")
        print("  --filters 'Name=tag:Environment,Values=dev' \\")
        print("  --query 'Reservations[].Instances[].InstanceId' --output text)")
        print()
        print("# Run this Monday morning")  
        print("aws ec2 start-instances --instance-ids $(aws ec2 describe-instances \\")
        print("  --filters 'Name=tag:Environment,Values=dev' \\")
        print("  --query 'Reservations[].Instances[].InstanceId' --output text)")
        print()
        print("💰 This can save $50-100/month for dev environments")

def main():
    import sys
    
    helper = CasualDevHelper()
    
    if len(sys.argv) < 2:
        print("🤖 Casual Developer AWS Helper")
        print("==============================")
        print()
        print("Commands:")
        print("  costs     - What's costing me money?")
        print("  save      - How to save money")
        print("  emergency - Fix my bill NOW")
        print("  monitor   - Set up simple monitoring")
        print("  setup     - Simple architecture ideas")
        print("  weekend   - Weekend shutdown to save money")
        print()
        print("Example: python3 casual_dev.py costs")
        return
    
    command = sys.argv[1].lower()
    
    if command == 'costs':
        helper.whats_costing_me_money()
    elif command == 'save':
        helper.how_to_save_money()
    elif command == 'emergency':
        budget = int(sys.argv[2]) if len(sys.argv) > 2 else 100
        helper.fix_my_bill(budget)
    elif command == 'monitor':
        helper.setup_simple_monitoring()
    elif command == 'setup':
        app_type = ' '.join(sys.argv[2:]) if len(sys.argv) > 2 else "web app"
        helper.simple_architecture(app_type)
    elif command == 'weekend':
        helper.weekend_shutdown()
    else:
        print(f"🤷 Don't know '{command}'. Try: costs, save, emergency, monitor, setup, weekend")

if __name__ == '__main__':
    main()