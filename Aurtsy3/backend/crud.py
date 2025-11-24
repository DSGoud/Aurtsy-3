from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
import models, schemas

def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()

def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(**user.dict())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_meal(db: Session, meal: schemas.MealCreate, user_id: str):
    db_meal = models.Meal(**meal.dict(), user_id=user_id)
    db.add(db_meal)
    db.commit()
    db.refresh(db_meal)
    return db_meal

def get_meals(db: Session, child_id: str, skip: int = 0, limit: int = 100):
    return db.query(models.Meal).filter(models.Meal.child_id == child_id).offset(skip).limit(limit).all()

def create_activity(db: Session, activity: schemas.ActivityCreate, user_id: str):
    db_activity = models.Activity(**activity.dict(), user_id=user_id)
    db.add(db_activity)
    db.commit()
    db.refresh(db_activity)
    return db_activity

def get_activities(db: Session, child_id: str, skip: int = 0, limit: int = 100):
    return db.query(models.Activity).filter(models.Activity.child_id == child_id).order_by(models.Activity.created_at.desc()).offset(skip).limit(limit).all()


# --- Child CRUD ---

def create_child(db: Session, child: schemas.ChildCreate):
    db_child = models.Child(**child.dict())
    db.add(db_child)
    db.commit()
    db.refresh(db_child)
    return db_child

def get_children(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Child).offset(skip).limit(limit).all()

def get_child(db: Session, child_id: str):
    return db.query(models.Child).filter(models.Child.id == child_id).first()

def update_child(db: Session, child_id: str, child_update: dict):
    db_child = get_child(db, child_id)
    if db_child:
        for key, value in child_update.items():
            setattr(db_child, key, value)
        db.commit()
        db.refresh(db_child)
    return db_child

def delete_child(db: Session, child_id: str):
    db_child = get_child(db, child_id)
    if db_child:
        db.delete(db_child)
        db.commit()
    return db_child

# --- Sleep Log CRUD ---

def create_sleep_log(db: Session, sleep_log: schemas.SleepLogCreate, user_id: str):
    db_sleep = models.SleepLog(**sleep_log.dict(), user_id=user_id)
    db.add(db_sleep)
    db.commit()
    db.refresh(db_sleep)
    return db_sleep

def get_sleep_logs(db: Session, child_id: str, skip: int = 0, limit: int = 100):
    return db.query(models.SleepLog).filter(models.SleepLog.child_id == child_id).order_by(models.SleepLog.created_at.desc()).offset(skip).limit(limit).all()

def get_sleep_log(db: Session, sleep_id: int):
    return db.query(models.SleepLog).filter(models.SleepLog.id == sleep_id).first()

def update_sleep_log(db: Session, sleep_id: int, sleep_update: schemas.SleepLogUpdate):
    db_sleep = get_sleep_log(db, sleep_id)
    if db_sleep:
        update_data = sleep_update.dict(exclude_unset=True)
        # Calculate duration if end_time is being set
        if 'end_time' in update_data and update_data['end_time'] and db_sleep.start_time:
            duration = update_data['end_time'] - db_sleep.start_time
            db_sleep.duration_minutes = int(duration.total_seconds() / 60)
        
        for key, value in update_data.items():
            setattr(db_sleep, key, value)
        db.commit()
        db.refresh(db_sleep)
    return db_sleep

def delete_sleep_log(db: Session, sleep_id: int):
    db_sleep = get_sleep_log(db, sleep_id)
    if db_sleep:
        db.delete(db_sleep)
        db.commit()
    return db_sleep

# --- Behavior Log CRUD ---

def create_behavior_log(db: Session, behavior_log: schemas.BehaviorLogCreate, user_id: str):
    db_behavior = models.BehaviorLog(**behavior_log.dict(), user_id=user_id)
    db.add(db_behavior)
    db.commit()
    db.refresh(db_behavior)
    return db_behavior

def get_behavior_logs(db: Session, child_id: str, skip: int = 0, limit: int = 100):
    return db.query(models.BehaviorLog).filter(models.BehaviorLog.child_id == child_id).order_by(models.BehaviorLog.created_at.desc()).offset(skip).limit(limit).all()

def get_behavior_log(db: Session, behavior_id: int):
    return db.query(models.BehaviorLog).filter(models.BehaviorLog.id == behavior_id).first()

def delete_behavior_log(db: Session, behavior_id: int):
    db_behavior = get_behavior_log(db, behavior_id)
    if db_behavior:
        db.delete(db_behavior)
        db.commit()
    return db_behavior

# --- Hydration Log CRUD ---

def create_hydration_log(db: Session, hydration_log: schemas.HydrationLogCreate, user_id: str):
    db_hydration = models.HydrationLog(**hydration_log.dict(), user_id=user_id)
    db.add(db_hydration)
    db.commit()
    db.refresh(db_hydration)
    return db_hydration

def get_hydration_logs(db: Session, child_id: str, skip: int = 0, limit: int = 100):
    return db.query(models.HydrationLog).filter(models.HydrationLog.child_id == child_id).order_by(models.HydrationLog.created_at.desc()).offset(skip).limit(limit).all()

def get_hydration_log(db: Session, hydration_id: int):
    return db.query(models.HydrationLog).filter(models.HydrationLog.id == hydration_id).first()

def get_daily_hydration_total(db: Session, child_id: str, date: datetime = None):
    if date is None:
        date = datetime.now()
    
    start_of_day = date.replace(hour=0, minute=0, second=0, microsecond=0)
    end_of_day = start_of_day + timedelta(days=1)
    
    total = db.query(func.sum(models.HydrationLog.amount_ml)).filter(
        models.HydrationLog.child_id == child_id,
        models.HydrationLog.created_at >= start_of_day,
        models.HydrationLog.created_at < end_of_day
    ).scalar()
    
    return total or 0

def delete_hydration_log(db: Session, hydration_id: int):
    db_hydration = get_hydration_log(db, hydration_id)
    if db_hydration:
        db.delete(db_hydration)
        db.commit()
    return db_hydration

def get_activity_feed(db: Session, child_id: str):
    """Aggregate all logs for a child into a dict matching ActivityFeed schema."""
    sleep_logs = db.query(models.SleepLog).filter(models.SleepLog.child_id == child_id).order_by(models.SleepLog.created_at.desc()).all()
    behavior_logs = db.query(models.BehaviorLog).filter(models.BehaviorLog.child_id == child_id).order_by(models.BehaviorLog.created_at.desc()).all()
    hydration_logs = db.query(models.HydrationLog).filter(models.HydrationLog.child_id == child_id).order_by(models.HydrationLog.created_at.desc()).all()
    location_checks = db.query(models.LocationCheck).filter(models.LocationCheck.child_id == child_id).order_by(models.LocationCheck.created_at.desc()).all()
    activities = db.query(models.Activity).filter(models.Activity.child_id == child_id).order_by(models.Activity.created_at.desc()).all()
    return {
        "child_id": child_id,
        "sleep_logs": [s.__dict__ for s in sleep_logs],
        "behavior_logs": [b.__dict__ for b in behavior_logs],
        "hydration_logs": [h.__dict__ for h in hydration_logs],
        "location_checks": [l.__dict__ for l in location_checks],
        "activities": [a.__dict__ for a in activities],
    }
