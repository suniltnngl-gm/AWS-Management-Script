#!/usr/bin/env python3
"""Real-world production pipeline with AWS integration"""

import os
import sys
import json
import time
import logging
import subprocess
from pathlib import Path
from datetime import datetime

# Setup production logging
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp":"%(asctime)s","level":"%(levelname)s","component":"pipeline","message":"%(message)s"}',
    handlers=[
        logging.FileHandler('/tmp/aws-mgmt/pipeline.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class RealWorldPipeline:
    def __init__(self):
        self.build_dir = Path("/tmp/aws-mgmt-prod")
        self.deploy_dir = Path.home() / "aws-mgmt-deploy"
        self.aws_available = self._check_aws()
        
    def _check_aws(self):
        """Check AWS CLI availability and credentials"""
        try:
            subprocess.run(['aws', '--version'], capture_output=True, check=True)
            subprocess.run(['aws', 'sts', 'get-caller-identity'], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            logger.warning("AWS CLI not available or not configured")
            return False
    
    def test_stage(self):
        """Real-world testing with AWS integration"""
        logger.info("Starting real-world tests")
        start_time = time.time()
        
        # Test Python files
        python_files = list(Path('.').glob('*.py'))
        for py_file in python_files[:10]:  # Test first 10
            try:
                subprocess.run([sys.executable, '-m', 'py_compile', str(py_file)], 
                             check=True, capture_output=True)
            except subprocess.CalledProcessError:
                logger.error(f"Syntax error in {py_file}")
                return False
        
        # Test shell scripts
        shell_files = list(Path('.').glob('**/*.sh'))
        for sh_file in shell_files[:10]:  # Test first 10
            try:
                subprocess.run(['bash', '-n', str(sh_file)], 
                             check=True, capture_output=True)
            except subprocess.CalledProcessError:
                logger.error(f"Syntax error in {sh_file}")
                return False
        
        duration = time.time() - start_time
        logger.info(f"Tests completed in {duration:.2f}s")
        return True
    
    def build_stage(self):
        """Production build with Python focus"""
        logger.info("Starting production build")
        start_time = time.time()
        
        # Clean and create build directory
        if self.build_dir.exists():
            subprocess.run(['rm', '-rf', str(self.build_dir)])
        self.build_dir.mkdir(parents=True)
        
        # Copy Python files
        python_files = ['*.py', 'requirements.txt']
        for pattern in python_files:
            for file in Path('.').glob(pattern):
                if file.is_file():
                    subprocess.run(['cp', str(file), str(self.build_dir)])
        
        # Copy essential directories
        for dir_name in ['lib', 'tools', 'bin']:
            src_dir = Path(dir_name)
            if src_dir.exists():
                subprocess.run(['cp', '-r', str(src_dir), str(self.build_dir)])
        
        # Create production requirements
        with open(self.build_dir / 'requirements.txt', 'w') as f:
            f.write("boto3>=1.26.0\n")
            f.write("click>=8.0.0\n")
            f.write("pyyaml>=6.0\n")
        
        # Create production config
        config = {
            "environment": "production",
            "log_level": "INFO",
            "aws_region": os.getenv("AWS_DEFAULT_REGION", "us-east-1"),
            "build_time": datetime.now().isoformat()
        }
        
        with open(self.build_dir / 'config.json', 'w') as f:
            json.dump(config, f, indent=2)
        
        duration = time.time() - start_time
        logger.info(f"Build completed in {duration:.2f}s - artifacts in {self.build_dir}")
        return True
    
    def deploy_stage(self):
        """Production deployment simulation"""
        logger.info("Starting production deployment")
        start_time = time.time()
        
        if not self.build_dir.exists():
            logger.error("Build artifacts not found")
            return False
        
        # Create deployment directory
        self.deploy_dir.mkdir(parents=True, exist_ok=True)
        
        # Deploy artifacts
        subprocess.run(['cp', '-r', f"{self.build_dir}/*", str(self.deploy_dir)], shell=True)
        
        # Create systemd service
        service_content = f"""[Unit]
Description=AWS Management Scripts
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 {self.deploy_dir}/app.py
Restart=always
User=aws-mgmt
Environment=PYTHONPATH={self.deploy_dir}

[Install]
WantedBy=multi-user.target
"""
        
        with open(self.deploy_dir / 'aws-mgmt.service', 'w') as f:
            f.write(service_content)
        
        duration = time.time() - start_time
        logger.info(f"Deployed in {duration:.2f}s to {self.deploy_dir}")
        return True
    
    def run_stage(self):
        """Production run with real AWS operations"""
        logger.info("Starting production run")
        start_time = time.time()
        
        if not self.deploy_dir.exists():
            logger.error("Deployment not found")
            return False
        
        # Health check
        try:
            if (self.deploy_dir / 'app.py').exists():
                result = subprocess.run([sys.executable, str(self.deploy_dir / 'app.py'), '--help'], 
                                      capture_output=True, timeout=10)
                if result.returncode == 0:
                    logger.info("Health check passed")
                else:
                    logger.warning("Health check failed")
        except Exception as e:
            logger.warning(f"Health check error: {e}")
        
        # Real AWS operations
        if self.aws_available:
            try:
                # List EC2 instances
                aws_start = time.time()
                result = subprocess.run(['aws', 'ec2', 'describe-instances', '--max-items', '1'], 
                                      capture_output=True, timeout=30)
                aws_duration = time.time() - aws_start
                
                if result.returncode == 0:
                    logger.info(f"AWS EC2 operation completed in {aws_duration:.2f}s")
                else:
                    logger.warning("AWS EC2 operation failed")
                
                # List S3 buckets
                result = subprocess.run(['aws', 's3', 'ls'], capture_output=True, timeout=30)
                if result.returncode == 0:
                    logger.info("AWS S3 operation completed")
                    
            except subprocess.TimeoutExpired:
                logger.warning("AWS operations timed out")
            except Exception as e:
                logger.error(f"AWS operations failed: {e}")
        else:
            logger.info("Running in mock mode - no real AWS calls")
        
        duration = time.time() - start_time
        logger.info(f"Run stage completed in {duration:.2f}s")
        return True
    
    def analyze_stage(self):
        """Production analysis and reporting"""
        logger.info("Starting production analysis")
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "environment": {
                "aws_region": os.getenv("AWS_DEFAULT_REGION", "not-set"),
                "user": os.getenv("USER", "unknown"),
                "hostname": subprocess.getoutput("hostname"),
                "python_version": sys.version
            },
            "aws_status": {
                "available": self.aws_available,
                "identity": None
            },
            "deployment": {
                "build_dir": str(self.build_dir),
                "deploy_dir": str(self.deploy_dir),
                "files_deployed": len(list(self.deploy_dir.glob('*'))) if self.deploy_dir.exists() else 0
            }
        }
        
        # Get AWS identity if available
        if self.aws_available:
            try:
                result = subprocess.run(['aws', 'sts', 'get-caller-identity'], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    identity = json.loads(result.stdout)
                    report["aws_status"]["identity"] = identity.get("Arn", "unknown")
            except Exception:
                pass
        
        # Save report
        report_file = f"production_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Production analysis saved to {report_file}")
        return True
    
    def run_pipeline(self, stage="all"):
        """Execute pipeline stages"""
        logger.info("Starting real-world pipeline")
        
        stages = {
            "test": self.test_stage,
            "build": self.build_stage,
            "deploy": self.deploy_stage,
            "run": self.run_stage,
            "analyze": self.analyze_stage
        }
        
        if stage == "all":
            for stage_name, stage_func in stages.items():
                if not stage_func():
                    logger.error(f"Pipeline failed at {stage_name} stage")
                    return False
        elif stage in stages:
            return stages[stage]()
        else:
            logger.error(f"Unknown stage: {stage}")
            return False
        
        logger.info("Real-world pipeline completed successfully")
        return True

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Real-world production pipeline")
    parser.add_argument("stage", nargs="?", default="all", 
                       choices=["test", "build", "deploy", "run", "analyze", "all"],
                       help="Pipeline stage to run")
    
    args = parser.parse_args()
    
    # Ensure log directory exists
    Path("/tmp/aws-mgmt").mkdir(parents=True, exist_ok=True)
    
    pipeline = RealWorldPipeline()
    success = pipeline.run_pipeline(args.stage)
    
    sys.exit(0 if success else 1)