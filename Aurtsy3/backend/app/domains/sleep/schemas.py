from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class SleepLogBase(BaseModel):
    child_id: str
    start_time: datetime
    end_time: Optional[datetime] = None
    quality_rating: Optional[int] = None
    notes: Optional[str] = None

class SleepLogCreate(SleepLogBase):
    pass

class SleepLogUpdate(BaseModel):
    end_time: Optional[datetime] = None
    quality_rating: Optional[int] = None
    notes: Optional[str] = None

class SleepLog(SleepLogBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
