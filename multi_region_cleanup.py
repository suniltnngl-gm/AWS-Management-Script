#!/usr/bin/env python3
"""Multi-region AWS cost analysis and cleanup"""

import boto3
import json
import logging
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO, format='{"time":"%(asctime)s","level":"%(levelname)s","msg":"%(message)s"}')
logger = logging.getLogger(__name__)

class MultiRegionCleanup:
    def __init__(self):
        self.session = boto3.Session()
        self.regions = ['us-east-1', 'us-west-2', 'eu-west-1', 'ap-southeast-1']
        self.total_savings = 0.0
        
    def analyze_region_costs(self, region):
        """Analyze costs and identify cleanup opportunities in a region"""
        try:
            ec2 = self.session.client('ec2', region_name=region)
            
            # Find stopped instances (cost savings opportunity)
            instances = ec2.describe_instances(
                Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}]
            )
            
            stopped_instances = []
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    # Calculate potential savings (stopped instances still cost for EBS)
                    instance_type = instance['InstanceType']
                    # Rough EBS cost estimation
                    ebs_cost = 0.10 * len(instance.get('BlockDeviceMappings', []))  # $0.10/GB/month
                    
                    stopped_instances.append({
                        'id': instance['InstanceId'],
                        'type': instance_type,
                        'launch_time': instance.get('LaunchTime', '').isoformat() if instance.get('LaunchTime') else None,
                        'monthly_ebs_cost': ebs_cost
                    })
            
            # Find unused EBS volumes
            volumes = ec2.describe_volumes(
                Filters=[{'Name': 'status', 'Values': ['available']}]
            )
            
            unused_volumes = []
            for volume in volumes['Volumes']:
                monthly_cost = volume['Size'] * 0.10  # $0.10/GB/month
                unused_volumes.append({
                    'id': volume['VolumeId'],
                    'size_gb': volume['Size'],
                    'monthly_cost': monthly_cost
                })
            
            # Find old snapshots (>30 days)
            snapshots = ec2.describe_snapshots(OwnerIds=['self'])
            old_snapshots = []
            cutoff_date = datetime.now() - timedelta(days=30)
            
            for snapshot in snapshots['Snapshots']:
                if snapshot['StartTime'].replace(tzinfo=None) < cutoff_date:
                    monthly_cost = snapshot.get('VolumeSize', 0) * 0.05  # $0.05/GB/month
                    old_snapshots.append({
                        'id': snapshot['SnapshotId'],
                        'size_gb': snapshot.get('VolumeSize', 0),
                        'age_days': (datetime.now() - snapshot['StartTime'].replace(tzinfo=None)).days,
                        'monthly_cost': monthly_cost
                    })
            
            region_savings = (
                sum(i['monthly_ebs_cost'] for i in stopped_instances) +
                sum(v['monthly_cost'] for v in unused_volumes) +
                sum(s['monthly_cost'] for s in old_snapshots)
            )
            
            logger.info(json.dumps({
                'region': region,
                'stopped_instances': len(stopped_instances),
                'unused_volumes': len(unused_volumes),
                'old_snapshots': len(old_snapshots),
                'potential_monthly_savings': round(region_savings, 2)
            }))
            
            return {
                'region': region,
                'stopped_instances': stopped_instances,
                'unused_volumes': unused_volumes,
                'old_snapshots': old_snapshots,
                'potential_savings': region_savings
            }
            
        except Exception as e:
            logger.error(f"Failed to analyze {region}: {e}")
            return {'region': region, 'error': str(e), 'potential_savings': 0}
    
    def cleanup_region(self, region, dry_run=True):
        """Perform cleanup in a region"""
        try:
            ec2 = self.session.client('ec2', region_name=region)
            cleanup_actions = []
            
            # Cleanup unused volumes
            volumes = ec2.describe_volumes(
                Filters=[{'Name': 'status', 'Values': ['available']}]
            )
            
            for volume in volumes['Volumes']:
                if not dry_run:
                    ec2.delete_volume(VolumeId=volume['VolumeId'])
                    
                cleanup_actions.append({
                    'action': 'delete_volume',
                    'resource_id': volume['VolumeId'],
                    'savings': volume['Size'] * 0.10,
                    'executed': not dry_run
                })
            
            # Cleanup old snapshots (>90 days for safety)
            snapshots = ec2.describe_snapshots(OwnerIds=['self'])
            cutoff_date = datetime.now() - timedelta(days=90)
            
            for snapshot in snapshots['Snapshots']:
                if snapshot['StartTime'].replace(tzinfo=None) < cutoff_date:
                    if not dry_run:
                        ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
                        
                    cleanup_actions.append({
                        'action': 'delete_snapshot',
                        'resource_id': snapshot['SnapshotId'],
                        'savings': snapshot.get('VolumeSize', 0) * 0.05,
                        'executed': not dry_run
                    })
            
            total_savings = sum(action['savings'] for action in cleanup_actions)
            
            logger.info(json.dumps({
                'region': region,
                'cleanup_actions': len(cleanup_actions),
                'total_monthly_savings': round(total_savings, 2),
                'dry_run': dry_run
            }))
            
            return {
                'region': region,
                'actions': cleanup_actions,
                'savings': total_savings
            }
            
        except Exception as e:
            logger.error(f"Cleanup failed in {region}: {e}")
            return {'region': region, 'error': str(e), 'savings': 0}
    
    def run_analysis(self):
        """Run multi-region cost analysis"""
        logger.info("Starting multi-region cost analysis")
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            results = list(executor.map(self.analyze_region_costs, self.regions))
        
        # Aggregate results
        total_savings = sum(r.get('potential_savings', 0) for r in results)
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'regions_analyzed': len(self.regions),
            'total_potential_monthly_savings': round(total_savings, 2),
            'total_annual_savings': round(total_savings * 12, 2),
            'regional_breakdown': results
        }
        
        # Save report
        report_file = f"multi_region_cost_analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        
        logger.info(json.dumps({
            'analysis_complete': True,
            'potential_monthly_savings': round(total_savings, 2),
            'report_file': report_file
        }))
        
        return report
    
    def run_cleanup(self, dry_run=True):
        """Run multi-region cleanup"""
        logger.info(f"Starting multi-region cleanup (dry_run={dry_run})")
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            cleanup_results = list(executor.map(
                lambda r: self.cleanup_region(r, dry_run), 
                self.regions
            ))
        
        total_savings = sum(r.get('savings', 0) for r in cleanup_results)
        
        cleanup_report = {
            'timestamp': datetime.now().isoformat(),
            'dry_run': dry_run,
            'regions_cleaned': len(self.regions),
            'total_monthly_savings': round(total_savings, 2),
            'cleanup_results': cleanup_results
        }
        
        report_file = f"multi_region_cleanup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(cleanup_report, f, indent=2, default=str)
        
        logger.info(json.dumps({
            'cleanup_complete': True,
            'monthly_savings': round(total_savings, 2),
            'dry_run': dry_run,
            'report_file': report_file
        }))
        
        return cleanup_report

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Multi-region AWS cost analysis and cleanup")
    parser.add_argument("--action", choices=["analyze", "cleanup"], default="analyze")
    parser.add_argument("--execute", action="store_true", help="Execute cleanup (not dry run)")
    
    args = parser.parse_args()
    
    cleaner = MultiRegionCleanup()
    
    if args.action == "analyze":
        report = cleaner.run_analysis()
        print(f"💰 Potential monthly savings: ${report['total_potential_monthly_savings']}")
    else:
        report = cleaner.run_cleanup(dry_run=not args.execute)
        print(f"🧹 Cleanup {'executed' if args.execute else 'simulated'}: ${report['total_monthly_savings']}/month")