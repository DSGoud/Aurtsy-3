from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.domains.analytics import schemas, service

router = APIRouter()

@router.get("/weekly-summary/{child_id}", response_model=schemas.WeeklySummary)
def get_weekly_summary(
    child_id: str,
    db: Session = Depends(get_db)
):
    """
    Get comprehensive weekly analytics including:
    - Regulation Battery (Current resilience)
    - Open Loops (Unresolved requests)
    - ABC Analysis (Triggers & Interventions)
    - Insights (Correlations)
    """
    return service.analytics_service.get_weekly_summary(db, child_id)
