from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.domains.ai import schemas, service

router = APIRouter()

@router.get("/handoff/{child_id}", response_model=schemas.HandoffSummary)
def get_handoff_summary(child_id: str, db: Session = Depends(get_db)):
    """
    Generates a 'Magic Handoff' summary for the specified child based on recent data.
    """
    return service.ai_service.generate_handoff_summary(db, child_id)

@router.post("/process_log", response_model=schemas.VoiceProcessResponse)
def process_voice_log(request: schemas.VoiceProcessRequest, db: Session = Depends(get_db)):
    """
    Process a natural language voice log using AI to categorize and save it.
    """
    return service.ai_service.process_voice_log(db, request.child_id, request.user_id, request.text)
@router.post("/question", response_model=schemas.ContextualQuestionResponse)
def generate_contextual_question(request: schemas.ContextualQuestionRequest, db: Session = Depends(get_db)):
    """
    Generate a smart follow-up question based on context to fill knowledge gaps.
    """
    return service.ai_service.generate_contextual_question(db, request.child_id, request.context)
