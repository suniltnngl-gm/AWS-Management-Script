#!/usr/bin/env python3

# @file backend/models/response.py
# @brief Response models for API standardization
# @description Standardized response formats

from dataclasses import dataclass
from typing import Any, Optional
import json

@dataclass
class APIResponse:
    success: bool
    data: Optional[Any] = None
    error: Optional[str] = None
    timestamp: Optional[str] = None
    
    def to_dict(self):
        return {
            "success": self.success,
            "data": self.data,
            "error": self.error,
            "timestamp": self.timestamp
        }
    
    def to_json(self):
        return json.dumps(self.to_dict())

@dataclass
class ResourceSummary:
    ec2_count: int
    s3_count: int
    lambda_count: int
    iam_count: int
    
@dataclass
class CostData:
    amount: float
    currency: str
    period: str
    
@dataclass
class SecurityFinding:
    type: str
    resource: str
    severity: str
    description: Optional[str] = None