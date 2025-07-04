# 🔐 AWS Credentials Setup

## 🎯 Choose Your Method

### **Local Development (Quick Start)**
```bash
aws configure
# Enter your credentials directly
# Good for: Testing, personal use, development
```

### **Production/Team (Secure)**
```bash
# GitHub Secrets (recommended for teams)
# Set in GitHub repo: Settings > Secrets and variables > Actions
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1
```

## 🚀 Quick Decision

**Use `aws configure` if:**
- ✅ Personal project
- ✅ Local testing only
- ✅ Want to start immediately

**Use GitHub Secrets if:**
- ✅ Team project
- ✅ Production deployment
- ✅ CI/CD automation
- ✅ Better security

## ⚡ Start Now
```bash
# Quick start (5 seconds)
aws configure

# Test immediately
python3 casual_dev.py costs
```

**Both work with our tools!** 🎯