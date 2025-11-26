from sqlalchemy.orm import Session
from . import models, schemas

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
