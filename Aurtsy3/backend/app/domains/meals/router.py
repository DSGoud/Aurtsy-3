from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from . import schemas, service

router = APIRouter()

@router.post("/", response_model=schemas.Meal)
async def create_meal(meal: schemas.MealCreate, user_id: str = Query(...), db: Session = Depends(get_db)):
    # In real app, user_id comes from auth token
    return await service.create_meal(db=db, meal=meal, user_id=user_id)

@router.get("/", response_model=List[schemas.Meal])
def read_meals(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return service.get_meals(db, child_id=child_id, skip=skip, limit=limit)

# Alternative route for RESTful child-specific access
@router.get("/children/{child_id}/meals/", response_model=List[schemas.Meal])
def read_child_meals(child_id: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return service.get_meals(db, child_id=child_id, skip=skip, limit=limit)
