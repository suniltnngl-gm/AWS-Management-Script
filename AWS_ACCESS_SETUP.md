# 🔐 AWS Access Setup

## 🎯 Quick Decision

### **For Small Teams/Personal: IAM User**
```bash
# Create IAM user with minimal permissions
# Attach policy: ReadOnlyAccess + Billing
# Generate Access Keys
# Use: aws configure
```

### **For Companies: AWS SSO**
```bash
# Use existing company SSO
# More secure, centrally managed
# Use: aws sso configure
```

## ⚡ Recommended IAM Setup

### **1. Create IAM Group: "CostManagers"**
**Permissions needed:**
- `ViewOnlyAccess` (AWS managed policy)
- `Billing` read access
- `Cost Explorer` access

### **2. Create IAM User**
- Add to "CostManagers" group
- Generate Access Keys
- Use with `aws configure`

### **3. Minimal Permissions (JSON)**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ce:GetCostAndUsage",
                "ce:GetUsageReport",
                "ec2:DescribeInstances",
                "s3:ListAllMyBuckets",
                "rds:DescribeDBInstances"
            ],
            "Resource": "*"
        }
    ]
}
```

## 🚀 Quick Start
**Use IAM user for immediate testing, upgrade to SSO later!**