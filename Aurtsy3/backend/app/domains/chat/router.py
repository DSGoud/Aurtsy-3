from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.domains.chat import schemas, service

router = APIRouter()

@router.post("/send", response_model=schemas.SendMessageResponse)
def send_message(request: schemas.SendMessageRequest, db: Session = Depends(get_db)):
    """
    Send a message to the AI assistant.
    Auto-creates a session if needed.
    Returns the User message (saved) and the AI response.
    """
    return service.chat_service.process_message(db, request.child_id, request.user_id, request.content)

@router.get("/history/{child_id}", response_model=schemas.ChatSession)
def get_chat_history(child_id: str, db: Session = Depends(get_db)):
    """
    Get the active chat session and its history.
    """
    return service.chat_service.get_session_history(db, child_id)
