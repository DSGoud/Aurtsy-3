from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Child(Base):
    __tablename__ = "children"

    id = Column(String(50), primary_key=True)
    name = Column(String(200), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    meals = relationship("app.domains.meals.models.Meal", back_populates="child")
    # activities = relationship("Activity", back_populates="child") # TODO: Add Activity domain

class ChildGuardian(Base):
    __tablename__ = "child_guardians"
    
    user_id = Column(String(50), ForeignKey("users.id"), primary_key=True)
    child_id = Column(String(50), ForeignKey("children.id"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    user = relationship("app.domains.users.models.User", back_populates="guardianships")
    child = relationship("Child")
