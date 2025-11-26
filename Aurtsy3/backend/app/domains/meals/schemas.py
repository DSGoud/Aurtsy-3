from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from .models import MealType

class MealBase(BaseModel):
    child_id: str
    meal_type: MealType
    photo_url: Optional[str] = None
    notes: Optional[str] = None

class MealCreate(MealBase):
    pass

class Meal(MealBase):
    id: int
    user_id: str
    analysis_status: str
    analysis_json: Optional[dict] = None
    created_at: datetime
    class Config:
        orm_mode = True
