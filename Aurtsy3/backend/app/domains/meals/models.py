from sqlalchemy import Column, String, Integer, Text, Enum, ForeignKey, JSON, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.core.database import Base

class MealType(str, enum.Enum):
    PRE_MEAL = "PRE_MEAL"
    POST_MEAL = "POST_MEAL"
    SNACK = "SNACK"

class Meal(Base):
    __tablename__ = "meals"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    user_id = Column(String(50), ForeignKey("users.id"), nullable=False) # Who logged it
    
    meal_type = Column(Enum(MealType), nullable=False)
    photo_url = Column(String(500), nullable=True)
    notes = Column(Text, nullable=True)
    
    # AI Analysis Results
    analysis_status = Column(String(20), default="PENDING") # PENDING, COMPLETED, FAILED
    analysis_json = Column(JSON, nullable=True) # Store calories, food items detected
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    child = relationship("app.domains.children.models.Child", back_populates="meals")
    user = relationship("app.domains.users.models.User")
