from sqlalchemy import Column, String, Boolean, DateTime, Enum, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.core.database import Base

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
    guardianships = relationship("app.domains.children.models.ChildGuardian", back_populates="user")
