from sqlalchemy import Column, String, DateTime, Integer, Text, ForeignKey, JSON
from sqlalchemy.sql import func
from app.core.database import Base

class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    activity_type = Column(String(100), nullable=False)
    details = Column(JSON, nullable=True) # e.g. {"duration_minutes": 30, "notes": "..."}
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
