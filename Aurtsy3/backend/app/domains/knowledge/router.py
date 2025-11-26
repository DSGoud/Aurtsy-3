from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.domains.knowledge import schemas, service

router = APIRouter()

@router.post("/resolve", response_model=schemas.EntityResolveResponse)
def resolve_entity(request: schemas.EntityResolveRequest, db: Session = Depends(get_db)):
    """
    Resolve an ambiguous query to a specific entity.
    Example: "Dan" -> "Dan Modern Chinese restaurant"
    """
    return service.knowledge_service.resolve_entity(
        db, 
        request.query, 
        request.child_id,
        request.entity_type
    )

@router.post("/entities", response_model=schemas.Entity)
def create_entity(entity: schemas.EntityCreate, db: Session = Depends(get_db)):
    """
    Add a new entity to the knowledge base.
    """
    return service.knowledge_service.create_entity(db, entity)

@router.get("/entities/{child_id}", response_model=list[schemas.Entity])
def list_entities(child_id: str, db: Session = Depends(get_db)):
    """
    List all entities for a specific child.
    """
    entities = service.knowledge_service.list_entities(db, child_id)
    return [schemas.Entity.from_orm(e) for e in entities]
