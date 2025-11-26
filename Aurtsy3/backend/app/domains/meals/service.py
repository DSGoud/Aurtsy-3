from sqlalchemy.orm import Session
from . import models, schemas
from app.core.events import event_bus

async def create_meal(db: Session, meal: schemas.MealCreate, user_id: str):
    db_meal = models.Meal(**meal.dict(), user_id=user_id)
    db.add(db_meal)
    db.commit()
    db.refresh(db_meal)
    
    # Publish event for AI analysis or alerts
    await event_bus.publish("meal_logged", {
        "meal_id": db_meal.id,
        "child_id": db_meal.child_id,
        "notes": db_meal.notes,
        "photo_url": db_meal.photo_url
    })
    
    return db_meal

def get_meals(db: Session, child_id: str, skip: int = 0, limit: int = 100):
    return db.query(models.Meal).filter(models.Meal.child_id == child_id).offset(skip).limit(limit).all()
