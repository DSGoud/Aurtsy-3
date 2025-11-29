from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum

class MessageRole(str, Enum):
    USER = "USER"
    AI = "AI"
    SYSTEM = "SYSTEM"

class ChatMessageBase(BaseModel):
    role: str
    content: str
    meta_data: Optional[str] = None

class ChatMessageCreate(ChatMessageBase):
    pass

class ChatMessage(ChatMessageBase):
    id: int
    session_id: int
    created_at: datetime

    class Config:
        orm_mode = True

class ChatSessionBase(BaseModel):
    child_id: str
    is_active: bool

class ChatSession(ChatSessionBase):
    id: int
    last_activity_at: datetime
    created_at: datetime
    messages: List[ChatMessage] = []

    class Config:
        orm_mode = True

# Request/Response for the Chat API
class SendMessageRequest(BaseModel):
    child_id: str
    content: str
    user_id: Optional[str] = "unknown"

class SendMessageResponse(BaseModel):
    user_message: ChatMessage
    ai_message: ChatMessage
    processed_data: Optional[Dict[str, Any]] = None # Summary of what was saved (e.g. "Saved Meal")

    class Config:
        orm_mode = True
