from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class BehaviorLogBase(BaseModel):
    child_id: str
    behavior_type: str
    mood_rating: Optional[int] = None
    incident_description: Optional[str] = None
    notes: Optional[str] = None

class BehaviorLogCreate(BehaviorLogBase):
    pass

class BehaviorLog(BehaviorLogBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
