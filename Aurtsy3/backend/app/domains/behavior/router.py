from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from . import models, schemas

router = APIRouter()

@router.post("/", response_model=schemas.BehaviorLog)
def create_behavior_log(log: schemas.BehaviorLogCreate, db: Session = Depends(get_db)):
    db_log = models.BehaviorLog(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/child/{child_id}", response_model=List[schemas.BehaviorLog])
def get_child_behavior_logs(child_id: str, db: Session = Depends(get_db)):
    return db.query(models.BehaviorLog).filter(models.BehaviorLog.child_id == child_id).order_by(models.BehaviorLog.created_at.desc()).all()
