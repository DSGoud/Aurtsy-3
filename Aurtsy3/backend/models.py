from sqlalchemy import Column, String, Boolean, DateTime, Enum, ForeignKey, Integer, JSON, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from database import Base

class RoleEnum(str, enum.Enum):
    ADMIN = "ADMIN"
    PARENT = "PARENT"
    TEACHER = "TEACHER"
    CAREGIVER = "CAREGIVER"
    AIDE = "AIDE"
    CHILD = "CHILD"
    SCHOOL_ADMIN = "SCHOOL_ADMIN"

class User(Base):
    __tablename__ = "users"

    id = Column(String(50), primary_key=True) # e.g. 'u_123'
    email = Column(String(320), unique=True, nullable=False)
    role = Column(Enum(RoleEnum), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    # Relationships
    guardianships = relationship("ChildGuardian", back_populates="user")
    # Add other relationships as needed

class Child(Base):
    __tablename__ = "children"

    id = Column(String(50), primary_key=True)
    name = Column(String(200), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    meals = relationship("Meal", back_populates="child")
    activities = relationship("Activity", back_populates="child")

class ChildGuardian(Base):
    __tablename__ = "child_guardians"
    
    user_id = Column(String(50), ForeignKey("users.id"), primary_key=True)
    child_id = Column(String(50), ForeignKey("children.id"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    user = relationship("User", back_populates="guardianships")
    child = relationship("Child")

# --- New Models for Caregiver Support ---

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
    
    child = relationship("Child", back_populates="meals")
    user = relationship("User")

class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    user_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    
    activity_type = Column(String(50), nullable=False) # e.g. "SLEEP", "PLAY", "TANTRUM"
    details = Column(JSON, nullable=True)
    media_url = Column(String(500), nullable=True) # Optional video/audio
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    child = relationship("Child", back_populates="activities")
    user = relationship("User")

# --- New Models for Additional Features ---

class SleepLog(Base):
    __tablename__ = "sleep_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    user_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True), nullable=True)  # Null if sleep session is ongoing
    duration_minutes = Column(Integer, nullable=True)  # Calculated when end_time is set
    quality_rating = Column(Integer, nullable=True)  # 1-5 stars
    notes = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    child = relationship("Child")
    user = relationship("User")

class BehaviorType(str, enum.Enum):
    MOOD = "MOOD"
    INCIDENT = "INCIDENT"
    MILESTONE = "MILESTONE"
    TANTRUM = "TANTRUM"
    POSITIVE = "POSITIVE"

class BehaviorLog(Base):
    __tablename__ = "behavior_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    user_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    
    behavior_type = Column(Enum(BehaviorType), nullable=False)
    mood_rating = Column(Integer, nullable=True)  # 1-5 scale
    incident_description = Column(Text, nullable=True)
    severity = Column(Integer, nullable=True)  # 1-5 scale for incidents
    media_url = Column(String(500), nullable=True)  # Photo/video of incident
    notes = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    child = relationship("Child")
    user = relationship("User")

class FluidType(str, enum.Enum):
    WATER = "WATER"
    JUICE = "JUICE"
    MILK = "MILK"
    FORMULA = "FORMULA"
    OTHER = "OTHER"

class HydrationLog(Base):
    __tablename__ = "hydration_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    user_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    
    fluid_type = Column(Enum(FluidType), nullable=False)
    amount_ml = Column(Integer, nullable=False)  # Amount in milliliters
    notes = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    child = relationship("Child")
    user = relationship("User")

class LocationCheck(Base):
    __tablename__ = "location_checks"
    
    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    user_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    
    latitude = Column(String(50), nullable=False)
    longitude = Column(String(50), nullable=False)
    location_name = Column(String(200), nullable=True)  # e.g. "Home", "School", "Park"
    notes = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    child = relationship("Child")
    user = relationship("User")
