from pydantic import BaseModel
from typing import List, Optional
from enum import Enum

class AlertLevel(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"

class HandoffSummary(BaseModel):
    summary: List[str]
    alert_level: AlertLevel
    recommendations: List[str]

class VoiceProcessRequest(BaseModel):
    child_id: str
    user_id: str
    text: str

class VoiceProcessResponse(BaseModel):
    success: bool
    processed_types: List[str] # "meal", "behavior", "sleep", "activity", "hydration"
    message: str
