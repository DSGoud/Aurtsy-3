from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from . import schemas, service

router = APIRouter()

@router.post("/", response_model=schemas.Child)
def create_child(child: schemas.ChildCreate, db: Session = Depends(get_db)):
    return service.create_child(db=db, child=child)

@router.get("/", response_model=List[schemas.Child])
def read_children(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return service.get_children(db, skip=skip, limit=limit)

@router.get("/{child_id}", response_model=schemas.Child)
def read_child(child_id: str, db: Session = Depends(get_db)):
    db_child = service.get_child(db, child_id=child_id)
    if db_child is None:
        raise HTTPException(status_code=404, detail="Child not found")
    return db_child

@router.delete("/{child_id}")
async def delete_child(child_id: str, db: Session = Depends(get_db)):
    db_child = db.query(models.Child).filter(models.Child.id == child_id).first()
    if not db_child:
        raise HTTPException(status_code=404, detail="Child not found")
    db.delete(db_child)
    db.commit()
    return {"ok": True}

# Child-specific resource endpoints
@router.get("/{child_id}/meals/")
async def get_child_meals(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all meals for a specific child"""
    from app.domains.meals import models as meal_models
    meals = db.query(meal_models.Meal).filter(
        meal_models.Meal.child_id == child_id
    ).order_by(meal_models.Meal.created_at.desc()).offset(skip).limit(limit).all()
    return meals

@router.get("/{child_id}/behavior/")
async def get_child_behaviors(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all behavior logs for a specific child"""
    from app.domains.behavior import models as behavior_models
    behaviors = db.query(behavior_models.BehaviorLog).filter(
        behavior_models.BehaviorLog.child_id == child_id
    ).order_by(behavior_models.BehaviorLog.created_at.desc()).offset(skip).limit(limit).all()
    return behaviors

@router.get("/{child_id}/sleep/")
async def get_child_sleep_logs(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all sleep logs for a specific child"""
    from app.domains.sleep import models as sleep_models
    logs = db.query(sleep_models.SleepLog).filter(
        sleep_models.SleepLog.child_id == child_id
    ).order_by(sleep_models.SleepLog.start_time.desc()).offset(skip).limit(limit).all()
    return logs

@router.get("/{child_id}/activities/")
async def get_child_activities(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all activity logs for a specific child"""
    from app.domains.activities import models as activity_models
    logs = db.query(activity_models.Activity).filter(
        activity_models.Activity.child_id == child_id
    ).order_by(activity_models.Activity.created_at.desc()).offset(skip).limit(limit).all()
    return logs

@router.get("/{child_id}/hydration/")
async def get_child_hydration_logs(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all hydration logs for a specific child"""
    from app.domains.hydration import models as hydration_models
    logs = db.query(hydration_models.HydrationLog).filter(
        hydration_models.HydrationLog.child_id == child_id
    ).order_by(hydration_models.HydrationLog.created_at.desc()).offset(skip).limit(limit).all()
    return logs

@router.get("/{child_id}/knowledge/")
async def get_child_knowledge(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all knowledge entities for a specific child"""
    from app.domains.knowledge import models as knowledge_models
    entities = db.query(knowledge_models.Entity).filter(
        knowledge_models.Entity.child_id == child_id
    ).order_by(knowledge_models.Entity.created_at.desc()).offset(skip).limit(limit).all()
    return entities

@router.get("/{child_id}/location/")
async def get_child_location_checks(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all location checks for a specific child"""
    from app.domains.activities import models as activity_models
    checks = db.query(activity_models.LocationCheck).filter(
        activity_models.LocationCheck.child_id == child_id
    ).order_by(activity_models.LocationCheck.created_at.desc()).offset(skip).limit(limit).all()
    return checks 

