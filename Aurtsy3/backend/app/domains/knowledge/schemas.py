from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime

class EntityBase(BaseModel):
    entity_type: str
    name: str
    resolved_value: str
    context: Optional[Dict[str, Any]] = None

class EntityCreate(EntityBase):
    child_id: str

class Entity(EntityBase):
    id: int
    child_id: str
    frequency: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class EntityResolveRequest(BaseModel):
    query: str
    child_id: str
    entity_type: Optional[str] = None

class EntityResolveResponse(BaseModel):
    entity: Optional[Entity] = None
    confidence: float  # 0.0 to 1.0
    alternatives: list[Entity] = []
