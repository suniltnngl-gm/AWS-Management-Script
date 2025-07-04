#!/usr/bin/env python3

"""
Amazon Q Integration for AWS Cost Management
Natural language interface for cost optimization
"""

import json
import subprocess

class AmazonQCostHelper:
    def __init__(self):
        self.context = {
            'tools_available': [
                'casual_dev.py - Friendly cost management',
                'small_business.py - Small team optimization',
                'startup_optimizer.py - Quick wins',
                'zero_spend.py - Free tier maximization'
            ]
        }
    
    def process_natural_query(self, query):
        """Process natural language cost queries"""
        query_lower = query.lower()
        
        # Cost checking queries
        if any(word in query_lower for word in ['cost', 'spend', 'bill', 'money']):
            if 'emergency' in query_lower or 'high' in query_lower or 'too much' in query_lower:
                return self._emergency_response()
            else:
                return self._cost_check_response()
        
        # Optimization queries
        elif any(word in query_lower for word in ['save', 'optimize', 'reduce', 'cheaper']):
            return self._optimization_response()
        
        # Setup queries
        elif any(word in query_lower for word in ['setup', 'start', 'begin', 'configure']):
            return self._setup_response()
        
        # Free tier queries
        elif 'free' in query_lower:
            return self._free_tier_response()
        
        else:
            return self._general_help_response()
    
    def _cost_check_response(self):
        """Response for cost checking queries"""
        return {
            'answer': "I'll help you check your AWS costs right now.",
            'command': 'python3 casual_dev.py costs',
            'explanation': 'This shows your current AWS spending in plain English',
            'next_steps': [
                'Review the cost breakdown',
                'Identify highest spending services',
                'Ask me for optimization suggestions'
            ]
        }
    
    def _emergency_response(self):
        """Response for emergency cost situations"""
        return {
            'answer': "Let me help you reduce your AWS bill immediately!",
            'command': 'python3 casual_dev.py emergency 100',
            'explanation': 'Emergency cost reduction steps to cut your bill by 50-80%',
            'urgent_actions': [
                'Stop unused EC2 instances',
                'Delete unnecessary storage',
                'Pause non-critical services',
                'Set up billing alerts'
            ]
        }
    
    def _optimization_response(self):
        """Response for optimization queries"""
        return {
            'answer': "Here are quick ways to save money on AWS:",
            'command': 'python3 startup_optimizer.py wins 50',
            'explanation': 'Actionable cost-saving recommendations',
            'quick_wins': [
                '5-minute tasks that save $20-50/month',
                'Free tier maximization strategies',
                'Auto-shutdown for dev environments',
                'Spot instance recommendations'
            ]
        }
    
    def _setup_response(self):
        """Response for setup queries"""
        return {
            'answer': "I'll guide you through setting up cost management:",
            'steps': [
                '1. Open AWS CloudShell (recommended)',
                '2. Run: git clone https://github.com/suniltnngl-gm/AWS-Management-Script.git',
                '3. Run: cd AWS-Management-Script',
                '4. Run: python3 casual_dev.py costs'
            ],
            'explanation': 'CloudShell has built-in AWS access - no credential setup needed!'
        }
    
    def _free_tier_response(self):
        """Response for free tier queries"""
        return {
            'answer': "Here's how to maximize AWS free tier:",
            'command': 'python3 zero_spend.py architecture 0',
            'free_resources': [
                't2.micro EC2: 750 hours/month',
                'S3 storage: 5GB free',
                'Lambda: 1M requests free',
                'DynamoDB: 25GB free',
                'CloudFront: 50GB transfer free'
            ],
            'architecture': 'Complete $0/month setup using only free tier'
        }
    
    def _general_help_response(self):
        """General help response"""
        return {
            'answer': "I can help you manage AWS costs! Ask me about:",
            'topics': [
                '"What are my AWS costs?" - Check current spending',
                '"How to save money?" - Get optimization tips',
                '"Emergency help!" - Reduce high bills immediately',
                '"Free tier setup" - Use AWS for $0/month',
                '"Setup guide" - Get started with cost management'
            ],
            'tools': self.context['tools_available']
        }

def amazon_q_chat():
    """Simple Amazon Q-style chat interface"""
    helper = AmazonQCostHelper()
    
    print("🤖 Amazon Q - AWS Cost Management Assistant")
    print("==========================================")
    print("Ask me anything about AWS costs in natural language!")
    print("Examples: 'What are my costs?', 'Help me save money', 'Emergency - bill too high!'")
    print("Type 'quit' to exit\n")
    
    while True:
        try:
            query = input("💬 You: ").strip()
            
            if query.lower() in ['quit', 'exit', 'bye']:
                print("👋 Goodbye! Keep saving money on AWS!")
                break
            
            if not query:
                continue
            
            # Process the query
            response = helper.process_natural_query(query)
            
            print(f"\n🤖 Amazon Q: {response['answer']}")
            
            if 'command' in response:
                print(f"💻 Run this: {response['command']}")
                print(f"📝 What it does: {response['explanation']}")
            
            if 'steps' in response:
                print("📋 Steps:")
                for step in response['steps']:
                    print(f"   {step}")
            
            if 'quick_wins' in response:
                print("⚡ Quick wins:")
                for win in response['quick_wins']:
                    print(f"   • {win}")
            
            if 'urgent_actions' in response:
                print("🚨 Urgent actions:")
                for action in response['urgent_actions']:
                    print(f"   • {action}")
            
            print()
            
        except KeyboardInterrupt:
            print("\n👋 Goodbye! Keep saving money on AWS!")
            break
        except Exception as e:
            print(f"⚠️ Error: {e}")

def main():
    import sys
    
    if len(sys.argv) > 1:
        # Process single query
        query = ' '.join(sys.argv[1:])
        helper = AmazonQCostHelper()
        response = helper.process_natural_query(query)
        
        print(f"🤖 {response['answer']}")
        if 'command' in response:
            print(f"💻 {response['command']}")
    else:
        # Interactive chat
        amazon_q_chat()

if __name__ == '__main__':
    main()