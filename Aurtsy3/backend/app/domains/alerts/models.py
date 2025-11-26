from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, JSON, Boolean
from sqlalchemy.sql import func
from app.core.database import Base

class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    alert_type = Column(String(50), nullable=False)  # "pattern_detected", "threshold_exceeded"
    severity = Column(String(20), nullable=False)  # "LOW", "MEDIUM", "HIGH"
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    pattern_data = Column(JSON, nullable=True)  # Correlation details, LLM analysis
    is_acknowledged = Column(Boolean, default=False, nullable=False)
    acknowledged_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
