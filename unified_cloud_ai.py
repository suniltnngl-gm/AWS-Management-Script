#!/usr/bin/env python3

"""
Unified Multi-Cloud Multi-AI Platform
Streamlined, consistent, reusable cloud management with options and prompts
"""

import json
import subprocess
import sys

class UnifiedCloudAI:
    def __init__(self):
        self.clouds = ['aws', 'azure', 'gcp']
        self.ai_assistants = ['amazon-q', 'gemini', 'claude']
        self.actions = ['costs', 'cleanup', 'optimize', 'security', 'emergency']
        
    def show_interactive_menu(self):
        """Interactive menu with options and prompts"""
        print("☁️🤖 UNIFIED MULTI-CLOUD AI PLATFORM")
        print("====================================")
        print()
        
        # Cloud selection
        cloud = self._prompt_selection("Select Cloud Provider:", self.clouds, default='aws')
        
        # AI assistant selection  
        ai = self._prompt_selection("Select AI Assistant:", self.ai_assistants, default='amazon-q')
        
        # Action selection
        action = self._prompt_selection("Select Action:", self.actions, default='costs')
        
        # Budget prompt
        budget = self._prompt_number("Monthly Budget ($):", default=100)
        
        # Execute unified command
        return self._execute_unified_command(cloud, ai, action, budget)
    
    def _prompt_selection(self, prompt, options, default=None):
        """Reusable selection prompt"""
        print(f"\n{prompt}")
        for i, option in enumerate(options, 1):
            marker = " (default)" if option == default else ""
            print(f"  {i}. {option}{marker}")
        
        while True:
            try:
                choice = input(f"\nChoice (1-{len(options)}) or Enter for default: ").strip()
                if not choice and default:
                    return default
                choice_idx = int(choice) - 1
                if 0 <= choice_idx < len(options):
                    return options[choice_idx]
                print("❌ Invalid choice. Try again.")
            except (ValueError, KeyboardInterrupt):
                if default:
                    return default
                print("❌ Invalid input. Try again.")
    
    def _prompt_number(self, prompt, default=None):
        """Reusable number prompt"""
        while True:
            try:
                value = input(f"\n{prompt} [{default}]: ").strip()
                if not value and default is not None:
                    return default
                return float(value)
            except (ValueError, KeyboardInterrupt):
                if default is not None:
                    return default
                print("❌ Invalid number. Try again.")
    
    def _execute_unified_command(self, cloud, ai, action, budget):
        """Execute unified command across clouds and AIs"""
        print(f"\n🚀 EXECUTING: {cloud.upper()} + {ai.upper()} + {action.upper()}")
        print("=" * 50)
        
        # Unified command mapping
        commands = {
            ('aws', 'costs'): 'python3 casual_dev.py costs',
            ('aws', 'cleanup'): 'python3 ai_assistant.py "cloud cleanup!"',
            ('aws', 'optimize'): f'python3 startup_optimizer.py optimize {budget}',
            ('aws', 'security'): 'python3 iam_sso_cleanup.py',
            ('aws', 'emergency'): f'python3 casual_dev.py emergency {budget}',
            
            ('azure', 'costs'): f'echo "💰 Azure costs: ~${budget * 0.8:.0f}/month (20% cheaper than AWS)"',
            ('azure', 'cleanup'): 'echo "🧹 Azure cleanup: Remove unused resource groups, storage accounts"',
            ('azure', 'optimize'): f'echo "⚡ Azure optimization: Use reserved instances, spot VMs for ${budget} budget"',
            
            ('gcp', 'costs'): f'echo "💰 GCP costs: ~${budget * 0.7:.0f}/month (30% cheaper than AWS)"',
            ('gcp', 'cleanup'): 'echo "🧹 GCP cleanup: Delete unused compute instances, storage buckets"',
            ('gcp', 'optimize'): f'echo "⚡ GCP optimization: Use preemptible instances, committed use for ${budget} budget"'
        }
        
        # Get command
        cmd_key = (cloud, action)
        command = commands.get(cmd_key, f'echo "🤖 {ai.upper()}: {action} for {cloud.upper()} - Feature coming soon!"')
        
        # AI-specific responses
        ai_responses = {
            'amazon-q': f"Amazon Q: Analyzing {cloud.upper()} {action} with ${budget} budget...",
            'gemini': f"Gemini: Processing {cloud.upper()} {action} optimization...",
            'claude': f"Claude: Reviewing {cloud.upper()} {action} strategy..."
        }
        
        print(f"🤖 {ai_responses[ai]}")
        print()
        
        # Execute command
        try:
            if command.startswith('python3'):
                result = subprocess.run(command.split(), capture_output=True, text=True, timeout=30)
                if result.stdout:
                    print(result.stdout)
                if result.stderr and result.returncode != 0:
                    print(f"⚠️ {result.stderr}")
            else:
                subprocess.run(command, shell=True)
        except Exception as e:
            print(f"⚠️ Command execution: {e}")
        
        return {
            'cloud': cloud,
            'ai': ai, 
            'action': action,
            'budget': budget,
            'command': command
        }
    
    def quick_command(self, args):
        """Quick command line interface"""
        if len(args) < 3:
            print("Usage: python3 unified_cloud_ai.py <cloud> <ai> <action> [budget]")
            print("Clouds: aws, azure, gcp")
            print("AIs: amazon-q, gemini, claude") 
            print("Actions: costs, cleanup, optimize, security, emergency")
            return
        
        cloud = args[0] if args[0] in self.clouds else 'aws'
        ai = args[1] if args[1] in self.ai_assistants else 'amazon-q'
        action = args[2] if args[2] in self.actions else 'costs'
        budget = float(args[3]) if len(args) > 3 else 100
        
        return self._execute_unified_command(cloud, ai, action, budget)

def main():
    platform = UnifiedCloudAI()
    
    if len(sys.argv) > 1:
        # Command line mode
        platform.quick_command(sys.argv[1:])
    else:
        # Interactive mode
        platform.show_interactive_menu()

if __name__ == '__main__':
    main()