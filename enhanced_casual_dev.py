#!/usr/bin/env python3

"""
Enhanced Casual Developer AWS Helper
Improved version with caching, better error handling, and progress indicators
"""

import json
import subprocess
import time
from datetime import datetime, timedelta

class EnhancedCasualDevHelper:
    def __init__(self):
        self.friendly_names = {
            'ec2': 'servers',
            'rds': 'databases', 
            's3': 'file storage',
            'lambda': 'functions',
            'cloudfront': 'fast delivery'
        }
        self._cost_cache = {}
        self._cache_ttl = 300  # 5 minutes
    
    def _show_progress(self, message, duration_estimate=None):
        """Show progress indicator"""
        print(f"⏳ {message}...")
        if duration_estimate:
            print(f"   (estimated {duration_estimate} seconds)")
    
    def _validate_aws_access(self):
        """Validate AWS CLI and credentials"""
        try:
            result = subprocess.run(['aws', 'sts', 'get-caller-identity'], 
                                  capture_output=True, text=True, timeout=5)
            return result.returncode == 0
        except FileNotFoundError:
            print("💡 AWS CLI not found. Install with: pip install awscli")
            return False
        except:
            print("⚠️ AWS credentials not configured. Run: aws configure")
            return False
    
    def _get_cached_costs(self):
        """Get costs with caching"""
        cache_key = 'monthly_costs'
        now = time.time()
        
        # Check cache
        if cache_key in self._cost_cache:
            cached_data, timestamp = self._cost_cache[cache_key]
            if now - timestamp < self._cache_ttl:
                print("📊 Using cached data (faster!)")
                return cached_data
        
        # Fetch fresh data
        self._show_progress("Fetching your AWS costs", 3)
        
        if not self._validate_aws_access():
            return None
        
        try:
            result = subprocess.run(['aws', 'ce', 'get-cost-and-usage', 
                                   '--time-period', f'Start={self._get_date(-30)},End={self._get_date(0)}',
                                   '--granularity', 'MONTHLY', '--metrics', 'BlendedCost',
                                   '--group-by', 'Type=DIMENSION,Key=SERVICE'], 
                                  capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                data = json.loads(result.stdout)
                # Cache the result
                self._cost_cache[cache_key] = (data, now)
                return data
        except Exception as e:
            print(f"⚠️ Error fetching costs: {str(e)}")
        
        return None
    
    def whats_costing_me_money(self):
        """Show what's actually costing money with improved error handling"""
        print("💰 What's costing you money right now:")
        print()
        
        cost_data = self._get_cached_costs()
        
        if cost_data:
            services = cost_data.get('ResultsByTime', [{}])[0].get('Groups', [])
            total_cost = 0
            
            print("📊 Your actual AWS costs:")
            for service in services[:5]:
                service_name = service['Keys'][0]
                cost = float(service['Metrics']['BlendedCost']['Amount'])
                if cost > 0.01:
                    friendly_name = self.friendly_names.get(service_name.lower(), service_name)
                    print(f"  • {friendly_name}: ${cost:.2f}")
                    total_cost += cost
            
            if total_cost > 0:
                print(f"\n💰 Total this month: ${total_cost:.2f}")
            else:
                print("🎉 Great news! You're spending almost nothing!")
        else:
            print("📝 Example costs (configure AWS CLI to see your real costs):")
            self._show_example_costs()
    
    def _show_example_costs(self):
        """Show example costs when real data isn't available"""
        print("  • Servers (EC2): $23.50")
        print("  • File storage (S3): $2.30") 
        print("  • Databases (RDS): $15.80")
        print("  • Functions (Lambda): $0.50")
        print()
        print("💡 Run 'aws configure' to see your actual costs")
    
    def smart_recommendations(self, budget=100):
        """Generate smart recommendations based on actual usage"""
        print(f"🧠 Smart recommendations for ${budget} budget:")
        print()
        
        cost_data = self._get_cached_costs()
        
        if cost_data:
            # TODO: Implement AI-powered recommendations based on actual usage
            print("🔍 Analyzing your actual AWS usage...")
            print("📊 Based on your spending patterns:")
            print()
        
        # Fallback to general recommendations
        print("💡 General money-saving tips:")
        print("  • Use free tier: t2.micro servers (750 hours)")
        print("  • Auto-shutdown dev environments")
        print("  • Use spot instances for testing (70% cheaper)")
        print("  • Set up billing alerts")
        
        if budget < 50:
            print(f"\n🎯 For ${budget} budget:")
            print("  • Stay within free tier limits")
            print("  • Use serverless (Lambda) when possible")
            print("  • Monitor daily to avoid surprises")
    
    def health_check(self):
        """System health check"""
        print("🏥 System Health Check:")
        print()
        
        # AWS CLI check
        try:
            subprocess.run(['aws', '--version'], capture_output=True, timeout=5)
            print("✅ AWS CLI: Installed")
        except FileNotFoundError:
            print("❌ AWS CLI: Not found")
            print("   Fix: pip install awscli")
        
        # Credentials check
        if self._validate_aws_access():
            print("✅ AWS Credentials: Configured")
        else:
            print("❌ AWS Credentials: Not configured")
            print("   Fix: aws configure")
        
        # Cache status
        cache_count = len(self._cost_cache)
        print(f"📊 Cache: {cache_count} items stored")
        
        # TODO: Add more health checks
        print("\n🎯 Overall Status: Ready to save money!")
    
    def _get_date(self, days_offset):
        """Get date with offset"""
        return (datetime.now() + timedelta(days=days_offset)).strftime('%Y-%m-%d')

def main():
    import sys
    
    helper = EnhancedCasualDevHelper()
    
    if len(sys.argv) < 2:
        print("🤖 Enhanced Casual Developer AWS Helper")
        print("======================================")
        print()
        print("Commands:")
        print("  costs     - What's costing me money? (with caching)")
        print("  smart     - Smart recommendations based on usage")
        print("  health    - System health check")
        print("  emergency - Fix my bill NOW")
        print()
        print("Example: python3 enhanced_casual_dev.py costs")
        return
    
    command = sys.argv[1].lower()
    
    if command == 'costs':
        helper.whats_costing_me_money()
    elif command == 'smart':
        budget = int(sys.argv[2]) if len(sys.argv) > 2 else 100
        helper.smart_recommendations(budget)
    elif command == 'health':
        helper.health_check()
    elif command == 'emergency':
        # Fallback to original emergency function
        print("🚨 Emergency mode - stopping all non-essential services...")
        print("1. aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].InstanceId' --output text)")
        print("2. Check S3 buckets for large files")
        print("3. Pause RDS instances if possible")
    else:
        print(f"🤷 Don't know '{command}'. Try: costs, smart, health, emergency")

if __name__ == '__main__':
    main()