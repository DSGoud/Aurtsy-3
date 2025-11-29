from sqlalchemy import Column, String, DateTime, Integer, Text, ForeignKey, Boolean, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.core.database import Base

class MessageRole(str, enum.Enum):
    USER = "USER"
    AI = "AI"
    SYSTEM = "SYSTEM"

class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(String(50), ForeignKey("children.id"), nullable=False)
    
    # Session management
    is_active = Column(Boolean, default=True)
    last_activity_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    # Relationships
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")
    child = relationship("Child")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("chat_sessions.id"), nullable=False)
    
    role = Column(Enum(MessageRole), nullable=False)
    content = Column(Text, nullable=False)
    
    # Optional metadata (e.g., if this message resulted in a DB entry)
    meta_data = Column(Text, nullable=True) # JSON string
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    session = relationship("ChatSession", back_populates="messages")
