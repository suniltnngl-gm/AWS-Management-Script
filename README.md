# AWS Management Scripts

## Notice: Internal Documentation & Security

All internal documentation and sensitive scripts are now located in the `private_docs/` folder and are not tracked in the repository. To move or access private docs between workspaces, use the encrypted ZIP workflow:

  ./tools/private_docs_zip.sh zip   # Archive and encrypt private_docs to private_docs.zip
  ./tools/private_docs_zip.sh unzip # Decrypt and extract private_docs.zip to private_docs/

You will be prompted for a password when zipping/unzipping. Do not commit the ZIP or extracted files to the repository. Only `README.md` and public wiki (if available) are intended for public consumption.

**Do not share or expose files from `private_docs/` or `private_docs.zip` unless explicitly authorized.**

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

### Quick Start (Interactive)
```bash
# Interactive menu (recommended)
./aws-cli.sh
```

### Non-Interactive / Automation
All major scripts now support CLI arguments for automation and CI/CD. Example usage:

```bash
# Launch a tool directly (non-interactive)
./aws-cli.sh --select 1         # Tools Menu
./aws-cli.sh --select 2         # Automation Client

# Run resource setup non-interactively
./client/aws_client.sh --resource-setup ec2 create t2.micro my-key

# Run MFA authentication non-interactively
./tools.sh --mfa 123456 default

# Save chat history non-interactively
./tools.sh --save-chat "My summary"

# Run Hub Logic recommend non-interactively
./tools.sh --budget 1000
```

### Direct Commands (Legacy)
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
✅ Fully scriptable and CI/CD ready (non-interactive modes)

_Contributions welcome!_ 😊

## 🚦 Master Automation Script

All automation steps (build, test, deploy, evaluate) are orchestrated via:

```bash
./scripts/manage.sh [build|test|deploy|evaluate|all] [--env ENV] [--dry-run] [--verbose]
```

- `build`: Build the project
- `test`: Run integration tests
- `deploy`: Deploy to AWS
- `evaluate`: Analyze AWS usage
- `all`: Run all steps in sequence

## 🤖 CI/CD Pipeline

- Automated build, test, deploy (dry run), and shell script linting via GitHub Actions.
- See `.github/workflows/ci-cd.yml` for details.

## 🛠️ Streamlined Workflow

- Use VS Code for editing and development.
- Use AWS CloudShell for building and deploying.
- All automation is managed via `scripts/manage.sh`.
- See `CONTRIBUTING.md` for contribution guidelines.
