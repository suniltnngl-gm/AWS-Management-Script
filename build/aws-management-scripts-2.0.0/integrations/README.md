# AWS Tool Integrations

## Available Integrations

### 🔔 **slack_notify.sh**
Send AWS alerts to Slack
```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/..."
./slack_notify.sh "Alert message" "danger"
```

### 📊 **cloudwatch_metrics.sh**
Get CloudWatch metrics
```bash
./cloudwatch_metrics.sh i-1234567890abcdef0  # EC2 CPU usage
```

### 🏗️ **terraform_sync.sh**
Compare Terraform state with AWS
```bash
./terraform_sync.sh compare
```

### ⚙️ **aws_config.sh**
AWS Config compliance checking
```bash
./aws_config.sh summary
./aws_config.sh check "required-tags"
```

### 💸 **cost_anomaly.sh**
Cost anomaly detection
```bash
./cost_anomaly.sh monitor  # Check and alert
./cost_anomaly.sh list 30  # List last 30 days
```

### 🤖 **github_actions.yml**
Automated monitoring workflow
- Daily AWS audits
- Failure notifications
- Scheduled reports

## Quick Start

```bash
# Run all integrations
./integration_runner.sh

# Setup Slack notifications
export SLACK_WEBHOOK_URL="your_webhook_url"

# Setup GitHub Actions
# Copy github_actions.yml to .github/workflows/
```

## Environment Variables

- `SLACK_WEBHOOK_URL` - Slack webhook for notifications
- `AWS_ACCESS_KEY_ID` - AWS credentials
- `AWS_SECRET_ACCESS_KEY` - AWS credentials