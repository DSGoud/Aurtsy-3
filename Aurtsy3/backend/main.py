from fastapi import FastAPI, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
import models, schemas, crud, database

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Aurtsy Caregiver Support System", version="0.1.0")

# Dependency
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"message": "Welcome to Aurtsy Backend"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

# --- User Endpoints ---

@app.post("/users/", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user.id)
    if db_user:
        raise HTTPException(status_code=400, detail="User already registered")
    return crud.create_user(db=db, user=user)

# --- Child Endpoints ---

@app.post("/children/", response_model=schemas.Child)
def create_child(child: schemas.ChildCreate, db: Session = Depends(get_db)):
    db_child = crud.get_child(db, child_id=child.id)
    if db_child:
        raise HTTPException(status_code=400, detail="Child already exists")
    return crud.create_child(db=db, child=child)

@app.get("/children/", response_model=List[schemas.Child])
def read_children(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_children(db, skip=skip, limit=limit)

@app.get("/children/{child_id}", response_model=schemas.Child)
def read_child(child_id: str, db: Session = Depends(get_db)):
    db_child = crud.get_child(db, child_id=child_id)
    if db_child is None:
        raise HTTPException(status_code=404, detail="Child not found")
    return db_child

@app.put("/children/{child_id}", response_model=schemas.Child)
def update_child(child_id: str, child_update: schemas.ChildBase, db: Session = Depends(get_db)):
    db_child = crud.update_child(db, child_id=child_id, child_update=child_update.dict())
    if db_child is None:
        raise HTTPException(status_code=404, detail="Child not found")
    return db_child

@app.delete("/children/{child_id}")
def delete_child(child_id: str, db: Session = Depends(get_db)):
    db_child = crud.delete_child(db, child_id=child_id)
    if db_child is None:
        raise HTTPException(status_code=404, detail="Child not found")
    return {"message": "Child deleted successfully"}

# --- Meal Endpoints ---

@app.post("/meals/", response_model=schemas.Meal)
def create_meal(meal: schemas.MealCreate, user_id: str = Query(...), db: Session = Depends(get_db)):
    # In real app, user_id comes from auth token
    return crud.create_meal(db=db, meal=meal, user_id=user_id)

@app.get("/children/{child_id}/meals/", response_model=List[schemas.Meal])
def read_meals(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_meals(db, child_id=child_id, skip=skip, limit=limit)

# --- Activity Endpoints ---

@app.post("/activities/", response_model=schemas.Activity)
def create_activity(activity: schemas.ActivityCreate, user_id: str, db: Session = Depends(get_db)):
    return crud.create_activity(db=db, activity=activity, user_id=user_id)

@app.get("/children/{child_id}/activities/", response_model=List[schemas.Activity])
def read_activities(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_activities(db, child_id=child_id, skip=skip, limit=limit)


# --- Sleep Log Endpoints ---

@app.post("/sleep/", response_model=schemas.SleepLog)
def create_sleep_log(sleep_log: schemas.SleepLogCreate, user_id: str, db: Session = Depends(get_db)):
    return crud.create_sleep_log(db=db, sleep_log=sleep_log, user_id=user_id)

@app.get("/children/{child_id}/sleep/", response_model=List[schemas.SleepLog])
def read_sleep_logs(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_sleep_logs(db, child_id=child_id, skip=skip, limit=limit)

@app.get("/sleep/{sleep_id}", response_model=schemas.SleepLog)
def read_sleep_log(sleep_id: int, db: Session = Depends(get_db)):
    db_sleep = crud.get_sleep_log(db, sleep_id=sleep_id)
    if db_sleep is None:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    return db_sleep

@app.put("/sleep/{sleep_id}", response_model=schemas.SleepLog)
def update_sleep_log(sleep_id: int, sleep_update: schemas.SleepLogUpdate, db: Session = Depends(get_db)):
    db_sleep = crud.update_sleep_log(db, sleep_id=sleep_id, sleep_update=sleep_update)
    if db_sleep is None:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    return db_sleep

@app.delete("/sleep/{sleep_id}")
def delete_sleep_log(sleep_id: int, db: Session = Depends(get_db)):
    db_sleep = crud.delete_sleep_log(db, sleep_id=sleep_id)
    if db_sleep is None:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    return {"message": "Sleep log deleted successfully"}

# --- Behavior Log Endpoints ---

@app.post("/behavior/", response_model=schemas.BehaviorLog)
def create_behavior_log(behavior_log: schemas.BehaviorLogCreate, user_id: str, db: Session = Depends(get_db)):
    return crud.create_behavior_log(db=db, behavior_log=behavior_log, user_id=user_id)

@app.get("/children/{child_id}/behavior/", response_model=List[schemas.BehaviorLog])
def read_behavior_logs(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_behavior_logs(db, child_id=child_id, skip=skip, limit=limit)

@app.get("/behavior/{behavior_id}", response_model=schemas.BehaviorLog)
def read_behavior_log(behavior_id: int, db: Session = Depends(get_db)):
    db_behavior = crud.get_behavior_log(db, behavior_id=behavior_id)
    if db_behavior is None:
        raise HTTPException(status_code=404, detail="Behavior log not found")
    return db_behavior

@app.delete("/behavior/{behavior_id}")
def delete_behavior_log(behavior_id: int, db: Session = Depends(get_db)):
    db_behavior = crud.delete_behavior_log(db, behavior_id=behavior_id)
    if db_behavior is None:
        raise HTTPException(status_code=404, detail="Behavior log not found")
    return {"message": "Behavior log deleted successfully"}

# --- Hydration Log Endpoints ---

@app.post("/hydration/", response_model=schemas.HydrationLog)
def create_hydration_log(hydration_log: schemas.HydrationLogCreate, user_id: str, db: Session = Depends(get_db)):
    return crud.create_hydration_log(db=db, hydration_log=hydration_log, user_id=user_id)

@app.get("/children/{child_id}/hydration/", response_model=List[schemas.HydrationLog])
def read_hydration_logs(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_hydration_logs(db, child_id=child_id, skip=skip, limit=limit)

@app.get("/children/{child_id}/hydration/daily-total", response_model=schemas.DailyHydrationTotal)
def read_daily_hydration_total(child_id: str, date: str = None, db: Session = Depends(get_db)):
    # date format: YYYY-MM-DD
    target_date = datetime.fromisoformat(date) if date else datetime.now()
    total_ml = crud.get_daily_hydration_total(db, child_id=child_id, date=target_date)
    return schemas.DailyHydrationTotal(
        child_id=child_id,
        date=target_date.strftime("%Y-%m-%d"),
        total_ml=total_ml
    )

@app.delete("/hydration/{hydration_id}")
def delete_hydration_log(hydration_id: int, db: Session = Depends(get_db)):
    db_hydration = crud.delete_hydration_log(db, hydration_id=hydration_id)
    if db_hydration is None:
        raise HTTPException(status_code=404, detail="Hydration log not found")
    return {"message": "Hydration log deleted successfully"}

# --- Location Check Endpoints ---

@app.post("/location/", response_model=schemas.LocationCheck)
def create_location_check(location_check: schemas.LocationCheckCreate, user_id: str, db: Session = Depends(get_db)):
    return crud.create_location_check(db=db, location_check=location_check, user_id=user_id)

@app.get("/children/{child_id}/location/", response_model=List[schemas.LocationCheck])
def read_location_checks(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_location_checks(db, child_id=child_id, skip=skip, limit=limit)

@app.get("/children/{child_id}/location/latest", response_model=schemas.LocationCheck)
@app.get("/activity-feed/{child_id}", response_model=schemas.ActivityFeed)
def read_activity_feed(child_id: str, db: Session = Depends(get_db)):
    """Return aggregated logs for a child"""
    feed = crud.get_activity_feed(db, child_id=child_id)
    if not any([feed["sleep_logs"], feed["behavior_logs"], feed["hydration_logs"], feed["location_checks"], feed["activities"]]):
        raise HTTPException(status_code=404, detail="No activity data found for this child")
    return feed

