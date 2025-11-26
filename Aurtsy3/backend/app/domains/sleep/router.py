from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from . import models, schemas

router = APIRouter()

@router.post("/", response_model=schemas.SleepLog)
def create_sleep_log(log: schemas.SleepLogCreate, db: Session = Depends(get_db)):
    db_log = models.SleepLog(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/{log_id}", response_model=schemas.SleepLog)
def get_sleep_log(log_id: int, db: Session = Depends(get_db)):
    log = db.query(models.SleepLog).filter(models.SleepLog.id == log_id).first()
    if log is None:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    return log

@router.put("/{log_id}", response_model=schemas.SleepLog)
def update_sleep_log(log_id: int, log_update: schemas.SleepLogUpdate, db: Session = Depends(get_db)):
    db_log = db.query(models.SleepLog).filter(models.SleepLog.id == log_id).first()
    if db_log is None:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    
    for key, value in log_update.dict(exclude_unset=True).items():
        setattr(db_log, key, value)
    
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/child/{child_id}", response_model=List[schemas.SleepLog])
def get_child_sleep_logs(child_id: str, db: Session = Depends(get_db)):
    return db.query(models.SleepLog).filter(models.SleepLog.child_id == child_id).order_by(models.SleepLog.start_time.desc()).all()
