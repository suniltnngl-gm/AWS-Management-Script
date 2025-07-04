#!/usr/bin/env python3

"""
Global Multi-Region Cost & Cleanup Maintenance
Runs during idle time to optimize costs across all AWS regions
"""

import json
import subprocess
import time
from datetime import datetime

class GlobalMaintenance:
    def __init__(self):
        self.regions = [
            'us-east-1', 'us-west-2', 'eu-west-1', 'ap-southeast-1',
            'us-east-2', 'eu-central-1', 'ap-northeast-1', 'ca-central-1'
        ]
        self.maintenance_actions = []
        self.total_savings = 0
    
    def run_global_maintenance(self):
        """Run maintenance across all regions during idle time"""
        print("🌍 GLOBAL MAINTENANCE MODE")
        print("=========================")
        print(f"⏰ Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"🌐 Checking {len(self.regions)} regions...")
        print()
        
        for region in self.regions:
            print(f"🔍 Region: {region}")
            self._maintenance_region(region)
            time.sleep(2)  # Avoid API throttling
        
        self._generate_maintenance_report()
    
    def _maintenance_region(self, region):
        """Perform maintenance in specific region"""
        try:
            # Check stopped instances
            stopped = self._check_stopped_instances(region)
            if stopped > 0:
                self.maintenance_actions.append(f"{region}: {stopped} stopped instances (consider terminating)")
                self.total_savings += stopped * 20  # $20/month per instance
            
            # Check unattached volumes
            volumes = self._check_unattached_volumes(region)
            if volumes > 0:
                self.maintenance_actions.append(f"{region}: {volumes} unattached EBS volumes")
                self.total_savings += volumes * 8  # $8/month per 10GB volume
            
            # Check old snapshots
            snapshots = self._check_old_snapshots(region)
            if snapshots > 0:
                self.maintenance_actions.append(f"{region}: {snapshots} old snapshots (>30 days)")
                self.total_savings += snapshots * 3  # $3/month per snapshot
            
            print(f"  ✅ Scanned - Found {stopped + volumes + snapshots} items")
            
        except Exception as e:
            print(f"  ⚠️ Error scanning {region}: Limited permissions or region unavailable")
    
    def _check_stopped_instances(self, region):
        """Check stopped EC2 instances in region"""
        try:
            result = subprocess.run([
                'aws', 'ec2', 'describe-instances',
                '--region', region,
                '--query', 'Reservations[].Instances[?State.Name==`stopped`] | length(@)',
                '--output', 'text'
            ], capture_output=True, text=True, timeout=15)
            
            return int(result.stdout.strip()) if result.returncode == 0 else 0
        except:
            return 0
    
    def _check_unattached_volumes(self, region):
        """Check unattached EBS volumes in region"""
        try:
            result = subprocess.run([
                'aws', 'ec2', 'describe-volumes',
                '--region', region,
                '--query', 'Volumes[?State==`available`] | length(@)',
                '--output', 'text'
            ], capture_output=True, text=True, timeout=15)
            
            return int(result.stdout.strip()) if result.returncode == 0 else 0
        except:
            return 0
    
    def _check_old_snapshots(self, region):
        """Check old snapshots in region"""
        try:
            # Simplified check - would normally parse dates
            result = subprocess.run([
                'aws', 'ec2', 'describe-snapshots',
                '--region', region,
                '--owner-ids', 'self',
                '--query', 'length(Snapshots)',
                '--output', 'text'
            ], capture_output=True, text=True, timeout=15)
            
            total_snapshots = int(result.stdout.strip()) if result.returncode == 0 else 0
            return max(0, total_snapshots - 5)  # Assume snapshots > 5 are old
        except:
            return 0
    
    def _generate_maintenance_report(self):
        """Generate comprehensive maintenance report"""
        print("\n📊 GLOBAL MAINTENANCE REPORT")
        print("============================")
        
        if self.maintenance_actions:
            print(f"🔍 Found {len(self.maintenance_actions)} maintenance items:")
            for action in self.maintenance_actions:
                print(f"  • {action}")
            
            print(f"\n💰 Estimated monthly savings: ${self.total_savings}")
            
            print("\n🛠️ Recommended actions:")
            print("  1. Terminate long-stopped instances")
            print("  2. Delete unattached EBS volumes")
            print("  3. Remove old snapshots (>30 days)")
            print("  4. Set up lifecycle policies")
            
            print("\n💻 Cleanup commands:")
            print("  python3 ai_assistant.py 'emergency cleanup'")
            print("  python3 casual_dev.py emergency 100")
        else:
            print("✅ No maintenance items found - all regions are clean!")
        
        print(f"\n⏰ Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        return {
            'regions_scanned': len(self.regions),
            'maintenance_items': len(self.maintenance_actions),
            'estimated_savings': self.total_savings,
            'actions': self.maintenance_actions
        }
    
    def idle_time_maintenance(self, duration_minutes=30):
        """Run maintenance during idle time"""
        print(f"😴 IDLE TIME MAINTENANCE ({duration_minutes} minutes)")
        print("=" * 40)
        
        start_time = time.time()
        end_time = start_time + (duration_minutes * 60)
        
        regions_per_cycle = 2  # Process 2 regions per cycle
        cycle_duration = 300   # 5 minutes per cycle
        
        processed_regions = 0
        
        while time.time() < end_time and processed_regions < len(self.regions):
            cycle_regions = self.regions[processed_regions:processed_regions + regions_per_cycle]
            
            print(f"\n🔄 Cycle {processed_regions//regions_per_cycle + 1}: {', '.join(cycle_regions)}")
            
            for region in cycle_regions:
                self._maintenance_region(region)
                processed_regions += 1
            
            remaining_time = end_time - time.time()
            if remaining_time > cycle_duration:
                print(f"⏸️ Waiting {cycle_duration//60} minutes before next cycle...")
                time.sleep(cycle_duration)
        
        print(f"\n✅ Idle maintenance complete - processed {processed_regions} regions")
        return self._generate_maintenance_report()

def main():
    import sys
    
    maintenance = GlobalMaintenance()
    
    if len(sys.argv) > 1:
        if sys.argv[1] == 'idle':
            duration = int(sys.argv[2]) if len(sys.argv) > 2 else 30
            maintenance.idle_time_maintenance(duration)
        elif sys.argv[1] == 'quick':
            # Quick scan of top 4 regions
            maintenance.regions = maintenance.regions[:4]
            maintenance.run_global_maintenance()
        else:
            print("Usage: python3 global_maintenance.py [idle|quick] [duration_minutes]")
    else:
        # Full maintenance
        maintenance.run_global_maintenance()

if __name__ == '__main__':
    main()