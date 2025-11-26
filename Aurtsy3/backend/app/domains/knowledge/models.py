from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, JSON
from sqlalchemy.sql import func
from app.core.database import Base

class Entity(Base):
    __tablename__ = "entities"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    entity_type = Column(String(50), nullable=False)  # "restaurant", "person", "activity"
    name = Column(String(200), nullable=False)  # "Dan"
    resolved_value = Column(Text, nullable=False)  # "Dan Modern Chinese"
    context = Column(JSON, nullable=True)  # {"order": "orange chicken", "location": "..."}
    frequency = Column(Integer, default=1)  # How often this entity is referenced
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
