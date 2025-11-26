from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from . import models, schemas

router = APIRouter()

@router.post("/", response_model=schemas.HydrationLog)
def create_hydration_log(log: schemas.HydrationLogCreate, db: Session = Depends(get_db)):
    db_log = models.HydrationLog(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/child/{child_id}", response_model=List[schemas.HydrationLog])
def get_child_hydration_logs(child_id: str, db: Session = Depends(get_db)):
    return db.query(models.HydrationLog).filter(models.HydrationLog.child_id == child_id).order_by(models.HydrationLog.created_at.desc()).all()
