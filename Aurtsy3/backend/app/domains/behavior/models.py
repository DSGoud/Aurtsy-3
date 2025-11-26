from sqlalchemy import Column, String, DateTime, Integer, Text, ForeignKey, JSON
from sqlalchemy.sql import func
from app.core.database import Base

class BehaviorLog(Base):
    __tablename__ = "behavior_logs"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    behavior_type = Column(String(50), nullable=False) # meltdown, positive, anxiety, etc.
    mood_rating = Column(Integer, nullable=True) # 1-5
    incident_description = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    analysis_data = Column(JSON, nullable=True) # Structured ABC data, request status, etc.
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
