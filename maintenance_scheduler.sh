#!/bin/bash

# Maintenance Scheduler for CloudShell
# Runs global maintenance during idle periods

echo "⏰ MAINTENANCE SCHEDULER"
echo "======================="

# Check if it's idle time (weekends or after hours)
current_hour=$(date +%H)
current_day=$(date +%u)  # 1=Monday, 7=Sunday

# Define idle periods
is_idle=false

# Weekend (Saturday=6, Sunday=7)
if [[ $current_day -eq 6 || $current_day -eq 7 ]]; then
    is_idle=true
    echo "📅 Weekend detected - idle time"
fi

# After hours (before 8 AM or after 6 PM)
if [[ $current_hour -lt 8 || $current_hour -gt 18 ]]; then
    is_idle=true
    echo "🌙 After hours detected - idle time"
fi

if [[ $is_idle == true ]]; then
    echo "😴 Starting idle time maintenance..."
    
    # Run global maintenance
    python3 global_maintenance.py idle 20
    
    # Run CloudShell cleanup
    echo "🧹 Running CloudShell cleanup..."
    bash cloudshell_cleanup.sh
    
    # Quick cost check
    echo "💰 Quick cost check..."
    python3 casual_dev.py costs
    
    echo "✅ Idle maintenance complete!"
else
    echo "⚡ Active hours - skipping maintenance"
    echo "💡 Maintenance runs during:"
    echo "  • Weekends (Saturday/Sunday)"
    echo "  • After hours (before 8 AM or after 6 PM)"
fi

echo "📊 Next maintenance check in 4 hours"