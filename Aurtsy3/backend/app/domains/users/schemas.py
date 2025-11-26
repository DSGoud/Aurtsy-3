from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from .models import RoleEnum

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
