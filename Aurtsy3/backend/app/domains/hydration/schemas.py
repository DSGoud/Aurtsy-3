from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class HydrationLogBase(BaseModel):
    child_id: str
    fluid_type: str
    amount_ml: int
    notes: Optional[str] = None

class HydrationLogCreate(HydrationLogBase):
    pass

class HydrationLog(HydrationLogBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
