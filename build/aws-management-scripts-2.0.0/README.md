# AWS Management Scripts

⚙️ Streamlined AWS resource monitoring and management with improved bash scripts! ⚡️

## Scripts Overview

### 🚀 **aws_manager.sh** (Recommended)
Unified script providing comprehensive AWS resource overview:
- EC2 instances with names and states
- S3 buckets
- Lambda functions
- SNS topics
- IAM users
- Billing information (last 30 days)

### 🔐 **aws_mfa.sh**
Generate temporary AWS credentials using MFA:
- Secure session token generation
- Configurable duration
- Multiple profile support

### 💰 **billing.sh**
Detailed AWS cost analysis:
- Monthly cost breakdown
- Service-wise cost distribution
- Customizable date ranges

### 🛡️ **cloudfront_audit.sh**
Security audit for CloudFront distributions:
- WAF integration check
- Logging status verification
- SSL/TLS protocol validation
- HTTP-only origin detection

### 📊 **aws_usage.sh** (Legacy)
Basic resource counting (use aws_manager.sh instead)

## Usage

### Quick Start
```bash
# Interactive menu (recommended)
./aws-cli.sh
```

### Direct Commands
```bash
# Main resource overview
./aws_manager.sh

# MFA authentication
./aws_mfa.sh <token_code> [profile]

# Billing information
./billing.sh

# CloudFront security audit
./cloudfront_audit.sh

# Run all integrations
./integration_runner.sh
```

## Prerequisites

- AWS CLI installed and configured
- Appropriate IAM permissions
- For MFA: Create `mfa.cfg` with format: `profile_name=arn:aws:iam::account:mfa/username`

## Features

✅ Error handling and validation  
✅ Clean, formatted output  
✅ Modular design  
✅ Security best practices  
✅ Cross-platform compatibility  

_Contributions welcome!_ 😊
