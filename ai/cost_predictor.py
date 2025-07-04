#!/usr/bin/env python3

"""
AI-powered cost prediction and optimization
Uses simple ML models to avoid expensive cloud ML services
"""

import json
import sys
from datetime import datetime, timedelta
import numpy as np
from sklearn.linear_model import LinearRegression
import logging

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class CostPredictor:
    def __init__(self):
        self.model = LinearRegression()
        self.is_trained = False
        self.regions = ['us-east-1', 'us-west-2', 'eu-west-1', 'ap-southeast-1']
    
    def predict_costs(self, historical_data, days_ahead=30):
        """Predict future costs based on historical data"""
        try:
            if not historical_data:
                return {"error": "No historical data provided"}
            
            # Prepare data
            X, y = self._prepare_data(historical_data)
            
            if len(X) < 2:
                return {"error": "Insufficient data for prediction"}
            
            # Train model
            self.model.fit(X, y)
            self.is_trained = True
            
            # Predict future costs
            future_X = np.array([[len(X) + i] for i in range(1, days_ahead + 1)])
            predictions = self.model.predict(future_X)
            
            # Generate recommendations
            recommendations = self._generate_recommendations(y, predictions)
            
            return {
                "predictions": predictions.tolist(),
                "trend": "increasing" if predictions[-1] > predictions[0] else "decreasing",
                "confidence": min(0.95, len(X) / 30),  # Higher confidence with more data
                "recommendations": recommendations,
                "model_accuracy": self._calculate_accuracy(X, y)
            }
            
        except Exception as e:
            logger.error(f"Prediction error: {e}")
            return {"error": str(e)}
    
    def _prepare_data(self, historical_data):
        """Prepare data for ML model"""
        X = []
        y = []
        
        for i, cost in enumerate(historical_data):
            X.append([i])  # Simple time series
            y.append(float(cost))
        
        return np.array(X), np.array(y)
    
    def _generate_recommendations(self, historical, predicted):
        """Generate cost optimization recommendations"""
        recommendations = []
        
        avg_historical = np.mean(historical)
        avg_predicted = np.mean(predicted)
        
        if avg_predicted > avg_historical * 1.2:
            recommendations.append({
                "type": "cost_alert",
                "message": "Costs projected to increase by 20%+",
                "action": "Review resource usage and implement cost controls"
            })
        
        if avg_predicted > 1000:
            recommendations.append({
                "type": "optimization",
                "message": "High cost projection detected",
                "action": "Consider reserved instances or spot instances"
            })
        
        return recommendations
    
    def _calculate_accuracy(self, X, y):
        """Calculate model accuracy"""
        if len(X) < 3:
            return 0.5
        
        # Simple R-squared calculation
        y_pred = self.model.predict(X)
        ss_res = np.sum((y - y_pred) ** 2)
        ss_tot = np.sum((y - np.mean(y)) ** 2)
        
        if ss_tot == 0:
            return 1.0
        
        r_squared = 1 - (ss_res / ss_tot)
        return max(0, min(1, r_squared))
    
    def analyze_cleanup_opportunities(self):
        """Multi-region cleanup analysis"""
        import boto3
        from concurrent.futures import ThreadPoolExecutor
        
        def check_region(region):
            try:
                ec2 = boto3.client('ec2', region_name=region)
                
                # Unused volumes
                volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
                unused_cost = sum(v['Size'] * 0.10 for v in volumes['Volumes'])
                
                # Old snapshots
                snapshots = ec2.describe_snapshots(OwnerIds=['self'])
                old_cost = sum(s.get('VolumeSize', 0) * 0.05 for s in snapshots['Snapshots'])
                
                return {'region': region, 'savings': unused_cost + old_cost}
            except:
                return {'region': region, 'savings': 0}
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            results = list(executor.map(check_region, self.regions))
        
        total_savings = sum(r['savings'] for r in results)
        return {'total_monthly_savings': total_savings, 'regions': results}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: python3 cost_predictor.py <historical_costs_json|cleanup>"}))
        sys.exit(1)
    
    if sys.argv[1] == "cleanup":
        predictor = CostPredictor()
        result = predictor.analyze_cleanup_opportunities()
        print(json.dumps(result, indent=2))
        return
    
    try:
        # Parse input
        historical_data = json.loads(sys.argv[1])
        
        # Create predictor and run analysis
        predictor = CostPredictor()
        result = predictor.predict_costs(historical_data)
        
        # Output results
        print(json.dumps(result, indent=2))
        
    except json.JSONDecodeError:
        print(json.dumps({"error": "Invalid JSON input"}))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

if __name__ == "__main__":
    main()