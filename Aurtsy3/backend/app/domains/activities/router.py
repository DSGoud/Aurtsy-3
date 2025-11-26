from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from . import models, schemas

router = APIRouter()

@router.post("/", response_model=schemas.Activity)
def create_activity(log: schemas.ActivityCreate, db: Session = Depends(get_db)):
    db_log = models.Activity(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/child/{child_id}", response_model=List[schemas.Activity])
def get_child_activities(child_id: str, db: Session = Depends(get_db)):
    return db.query(models.Activity).filter(models.Activity.child_id == child_id).order_by(models.Activity.created_at.desc()).all()
