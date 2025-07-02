#!/usr/bin/env python3

# @file backend/api/server.py
# @brief REST API server for AWS Management Scripts
# @description Flask-based API to expose shell script functionality

from flask import Flask, jsonify, request
import subprocess
import json
import os

app = Flask(__name__)

# @function run_script
# @brief Execute shell script and return JSON response
def run_script(script_name, args=[]):
    try:
        cmd = [f"../{script_name}"] + args
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return {
            "success": result.returncode == 0,
            "output": result.stdout,
            "error": result.stderr,
            "exit_code": result.returncode
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.route('/api/resources', methods=['GET'])
def get_resources():
    """Get AWS resource overview"""
    return jsonify(run_script("aws_manager.sh"))

@app.route('/api/billing', methods=['GET'])
def get_billing():
    """Get billing information"""
    return jsonify(run_script("billing.sh"))

@app.route('/api/audit/cloudfront', methods=['GET'])
def audit_cloudfront():
    """Run CloudFront security audit"""
    return jsonify(run_script("cloudfront_audit.sh"))

@app.route('/api/mfa', methods=['POST'])
def generate_mfa():
    """Generate MFA credentials"""
    data = request.json
    token = data.get('token')
    profile = data.get('profile', 'default')
    return jsonify(run_script("aws_mfa.sh", [token, profile]))

@app.route('/api/integrations', methods=['GET'])
def run_integrations():
    """Run all integrations"""
    return jsonify(run_script("integration_runner.sh"))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)