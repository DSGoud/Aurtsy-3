from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from models import RoleEnum, MealType, BehaviorType, FluidType

class ActivityFeed(BaseModel):
    child_id: str
    sleep_logs: List[dict] = []
    behavior_logs: List[dict] = []
    hydration_logs: List[dict] = []
    location_checks: List[dict] = []
    activities: List[dict] = []
    
    class Config:
        orm_mode = True

# User Schemas
class UserBase(BaseModel):
    email: str
    role: RoleEnum
    is_active: Optional[bool] = True

class UserCreate(UserBase):
    id: str # We might use Auth0 or similar ID
    
class User(UserBase):
    id: str
    created_at: datetime
    class Config:
        orm_mode = True

# Child Schemas
class ChildBase(BaseModel):
    name: str

class ChildCreate(ChildBase):
    id: str

class Child(ChildBase):
    id: str
    created_at: datetime
    class Config:
        orm_mode = True

# Meal Schemas
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

# Activity Schemas
class ActivityBase(BaseModel):
    child_id: str
    activity_type: str
    details: Optional[dict] = None
    media_url: Optional[str] = None

class ActivityCreate(ActivityBase):
    pass

class Activity(ActivityBase):
    id: int
    user_id: str
    created_at: datetime
    class Config:
        orm_mode = True

# Sleep Log Schemas
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
    user_id: str
    duration_minutes: Optional[int] = None
    created_at: datetime
    class Config:
        orm_mode = True

# Behavior Log Schemas
class BehaviorLogBase(BaseModel):
    child_id: str
    behavior_type: BehaviorType
    mood_rating: Optional[int] = None
    incident_description: Optional[str] = None
    severity: Optional[int] = None
    media_url: Optional[str] = None
    notes: Optional[str] = None

class BehaviorLogCreate(BehaviorLogBase):
    pass

class BehaviorLog(BehaviorLogBase):
    id: int
    user_id: str
    created_at: datetime
    class Config:
        orm_mode = True

# Hydration Log Schemas
class HydrationLogBase(BaseModel):
    child_id: str
    fluid_type: FluidType
    amount_ml: int
    notes: Optional[str] = None

class HydrationLogCreate(HydrationLogBase):
    pass

class HydrationLog(HydrationLogBase):
    id: int
    user_id: str
    created_at: datetime
    class Config:
        orm_mode = True

class DailyHydrationTotal(BaseModel):
    child_id: str
    date: str
    total_ml: int

# Location Check Schemas
class LocationCheckBase(BaseModel):
    child_id: str
    latitude: str
    longitude: str
    location_name: Optional[str] = None
    notes: Optional[str] = None

class LocationCheckCreate(LocationCheckBase):
    pass

class LocationCheck(LocationCheckBase):
    id: int
    user_id: str
    created_at: datetime
    class Config:
        orm_mode = True
