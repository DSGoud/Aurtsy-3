from pydantic import BaseModel
from datetime import datetime

class ChildBase(BaseModel):
    name: str

class ChildCreate(ChildBase):
    id: str

class Child(ChildBase):
    id: str
    created_at: datetime
    class Config:
        orm_mode = True
