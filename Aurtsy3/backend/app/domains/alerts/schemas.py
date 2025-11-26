from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime

class AlertBase(BaseModel):
    alert_type: str
    severity: str
    title: str
    description: str
    pattern_data: Optional[Dict[str, Any]] = None

class AlertCreate(AlertBase):
    child_id: str

class Alert(AlertBase):
    id: int
    child_id: str
    is_acknowledged: bool
    acknowledged_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class AlertAcknowledge(BaseModel):
    acknowledged: bool = True
