from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Dict, Any

class ActivityBase(BaseModel):
    child_id: str
    activity_type: str
    details: Optional[Dict[str, Any]] = None

class ActivityCreate(ActivityBase):
    pass

class Activity(ActivityBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
