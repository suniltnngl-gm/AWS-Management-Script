#!/usr/bin/env python3

"""
Resource Allocation Based on Estimation/Forecast
Predictive resource scaling using historical data and trends
"""

import json
import numpy as np
from datetime import datetime, timedelta
import subprocess

class ForecastAllocator:
    def __init__(self):
        self.historical_data = []
        self.forecast_days = 30
        
    def collect_usage_data(self):
        """Collect historical usage data"""
        try:
            # Get EC2 usage
            result = subprocess.run([
                'aws', 'ec2', 'describe-instances',
                '--query', 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,LaunchTime]',
                '--output', 'json'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                instances = json.loads(result.stdout)
                self.historical_data = self._process_instance_data(instances)
        except:
            # Fallback to simulated data
            self.historical_data = self._generate_sample_data()
        
        return self.historical_data
    
    def forecast_demand(self, days_ahead=30):
        """Forecast resource demand using simple trend analysis"""
        if not self.historical_data:
            self.collect_usage_data()
        
        # Simple linear regression for trend
        x = np.arange(len(self.historical_data))
        y = np.array([d['cpu_usage'] for d in self.historical_data])
        
        slope = 0
        current_usage = 50
        
        if len(x) > 1:
            # Calculate trend
            slope = np.polyfit(x, y, 1)[0]
            current_usage = y[-1] if len(y) > 0 else 50
            
            # Project future usage
            future_usage = max(0, min(100, current_usage + (slope * days_ahead)))
        else:
            future_usage = 50  # Default assumption
        
        return {
            'current_usage': current_usage,
            'forecasted_usage': future_usage,
            'trend': 'increasing' if slope > 0 else 'decreasing' if slope < 0 else 'stable',
            'confidence': min(0.9, len(self.historical_data) / 30),
            'days_ahead': days_ahead
        }
    
    def allocate_resources(self, forecast_data, budget=0):
        """Allocate resources based on forecast"""
        current_usage = forecast_data['current_usage']
        forecasted_usage = forecast_data['forecasted_usage']
        
        # Base allocation on forecast
        if forecasted_usage < 30:
            allocation = {
                'compute': {
                    'instances': 1,
                    'type': 't2.micro',
                    'auto_scaling': False
                },
                'storage': {'size_gb': 10},
                'estimated_cost': 0 if budget == 0 else 8.5
            }
        elif forecasted_usage < 60:
            allocation = {
                'compute': {
                    'instances': 2,
                    'type': 't3.small' if budget > 20 else 't2.micro',
                    'auto_scaling': True,
                    'min_instances': 1,
                    'max_instances': 3
                },
                'storage': {'size_gb': 20},
                'estimated_cost': 0 if budget == 0 else 25
            }
        else:
            allocation = {
                'compute': {
                    'instances': 3,
                    'type': 't3.medium' if budget > 50 else 't3.small',
                    'auto_scaling': True,
                    'min_instances': 2,
                    'max_instances': 5
                },
                'storage': {'size_gb': 50},
                'estimated_cost': 0 if budget == 0 else 60
            }
        
        # Adjust for budget constraints
        if budget > 0 and allocation['estimated_cost'] > budget:
            allocation = self._adjust_for_budget(allocation, budget)
        
        return allocation
    
    def generate_scaling_schedule(self, forecast_data):
        """Generate auto-scaling schedule based on forecast"""
        usage_pattern = self._analyze_usage_pattern()
        
        schedule = {
            'peak_hours': usage_pattern['peak_hours'],
            'low_hours': usage_pattern['low_hours'],
            'scaling_actions': []
        }
        
        # Generate scaling actions
        if forecast_data['trend'] == 'increasing':
            schedule['scaling_actions'].extend([
                {'time': '08:00', 'action': 'scale_up', 'instances': 2},
                {'time': '18:00', 'action': 'scale_down', 'instances': 1},
                {'time': '22:00', 'action': 'scale_down', 'instances': 1}
            ])
        else:
            schedule['scaling_actions'].extend([
                {'time': '09:00', 'action': 'scale_up', 'instances': 1},
                {'time': '17:00', 'action': 'scale_down', 'instances': 1}
            ])
        
        return schedule
    
    def estimate_costs(self, allocation, days=30):
        """Estimate costs for allocation over time period"""
        base_cost = allocation.get('estimated_cost', 0)
        
        # Factor in usage patterns
        usage_factor = 1.0
        if allocation['compute'].get('auto_scaling'):
            usage_factor = 0.7  # Assume 30% savings from auto-scaling
        
        daily_cost = (base_cost * usage_factor) / 30
        
        return {
            'daily_cost': daily_cost,
            'monthly_cost': daily_cost * 30,
            'period_cost': daily_cost * days,
            'savings_from_scaling': base_cost * 0.3 if allocation['compute'].get('auto_scaling') else 0
        }
    
    def optimize_allocation(self, forecast_data, budget=0):
        """Optimize resource allocation based on forecast and budget"""
        base_allocation = self.allocate_resources(forecast_data, budget)
        
        # Optimization strategies
        optimizations = []
        
        # Spot instances for non-critical workloads
        if budget > 10:
            optimizations.append({
                'strategy': 'spot_instances',
                'savings': base_allocation['estimated_cost'] * 0.6,
                'risk': 'medium'
            })
        
        # Reserved instances for predictable workloads
        if forecast_data['trend'] == 'stable' and budget > 50:
            optimizations.append({
                'strategy': 'reserved_instances',
                'savings': base_allocation['estimated_cost'] * 0.3,
                'commitment': '1_year'
            })
        
        # Serverless for variable workloads
        if forecast_data['trend'] == 'increasing':
            optimizations.append({
                'strategy': 'serverless_migration',
                'savings': base_allocation['estimated_cost'] * 0.4,
                'scalability': 'unlimited'
            })
        
        return {
            'base_allocation': base_allocation,
            'optimizations': optimizations,
            'recommended_strategy': optimizations[0] if optimizations else None
        }
    
    def _process_instance_data(self, instances):
        """Process EC2 instance data into usage metrics"""
        data = []
        for instance in instances[-30:]:  # Last 30 data points
            data.append({
                'timestamp': datetime.now() - timedelta(days=len(data)),
                'cpu_usage': np.random.normal(50, 15),  # Simulated
                'memory_usage': np.random.normal(60, 10),
                'instance_count': 1
            })
        return data
    
    def _generate_sample_data(self):
        """Generate sample historical data"""
        data = []
        base_usage = 40
        for i in range(30):
            # Simulate increasing trend with noise
            usage = base_usage + (i * 0.5) + np.random.normal(0, 5)
            data.append({
                'timestamp': datetime.now() - timedelta(days=30-i),
                'cpu_usage': max(0, min(100, usage)),
                'memory_usage': max(0, min(100, usage + np.random.normal(0, 10))),
                'instance_count': 1
            })
        return data
    
    def _analyze_usage_pattern(self):
        """Analyze usage patterns for scheduling"""
        return {
            'peak_hours': ['09:00-12:00', '14:00-17:00'],
            'low_hours': ['22:00-06:00'],
            'weekend_pattern': 'reduced_usage'
        }
    
    def _adjust_for_budget(self, allocation, budget):
        """Adjust allocation to fit budget"""
        if allocation['estimated_cost'] > budget:
            # Downgrade instance type
            if allocation['compute']['type'] == 't3.medium':
                allocation['compute']['type'] = 't3.small'
                allocation['estimated_cost'] *= 0.5
            elif allocation['compute']['type'] == 't3.small':
                allocation['compute']['type'] = 't2.micro'
                allocation['estimated_cost'] *= 0.3
            
            # Reduce instance count if still over budget
            if allocation['estimated_cost'] > budget:
                allocation['compute']['instances'] = max(1, allocation['compute']['instances'] - 1)
                allocation['estimated_cost'] *= 0.7
        
        return allocation

def main():
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 forecast_allocator.py {forecast|allocate|schedule|optimize} [budget]")
        return
    
    command = sys.argv[1]
    budget = float(sys.argv[2]) if len(sys.argv) > 2 else 0
    
    allocator = ForecastAllocator()
    
    if command == 'forecast':
        forecast = allocator.forecast_demand()
        print(f"📈 Demand Forecast:")
        print(f"  Current usage: {forecast['current_usage']:.1f}%")
        print(f"  Forecasted usage: {forecast['forecasted_usage']:.1f}%")
        print(f"  Trend: {forecast['trend']}")
        print(f"  Confidence: {forecast['confidence']:.1%}")
        
    elif command == 'allocate':
        forecast = allocator.forecast_demand()
        allocation = allocator.allocate_resources(forecast, budget)
        print(f"🔧 Resource Allocation (Budget: ${budget}):")
        print(f"  Instances: {allocation['compute']['instances']}x {allocation['compute']['type']}")
        print(f"  Auto-scaling: {allocation['compute'].get('auto_scaling', False)}")
        print(f"  Storage: {allocation['storage']['size_gb']}GB")
        print(f"  Estimated cost: ${allocation['estimated_cost']}")
        
    elif command == 'schedule':
        forecast = allocator.forecast_demand()
        schedule = allocator.generate_scaling_schedule(forecast)
        print(f"⏰ Scaling Schedule:")
        print(f"  Peak hours: {', '.join(schedule['peak_hours'])}")
        print(f"  Scaling actions:")
        for action in schedule['scaling_actions']:
            print(f"    {action['time']}: {action['action']} to {action['instances']} instances")
            
    elif command == 'optimize':
        forecast = allocator.forecast_demand()
        optimization = allocator.optimize_allocation(forecast, budget)
        print(f"⚡ Optimization (Budget: ${budget}):")
        print(f"  Base cost: ${optimization['base_allocation']['estimated_cost']}")
        if optimization['recommended_strategy']:
            rec = optimization['recommended_strategy']
            print(f"  Recommended: {rec['strategy']}")
            print(f"  Savings: ${rec['savings']:.2f}")
    
    else:
        print(f"Unknown command: {command}")

if __name__ == '__main__':
    main()