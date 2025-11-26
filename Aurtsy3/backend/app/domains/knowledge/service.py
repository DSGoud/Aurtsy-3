from sqlalchemy.orm import Session
from app.domains.knowledge import models, schemas
from typing import Optional
from difflib import SequenceMatcher

class KnowledgeService:
    def create_entity(self, db: Session, entity: schemas.EntityCreate) -> models.Entity:
        """Create a new entity in the knowledge base."""
        # Check if entity already exists
        existing = db.query(models.Entity).filter(
            models.Entity.child_id == entity.child_id,
            models.Entity.name.ilike(entity.name),
            models.Entity.entity_type == entity.entity_type
        ).first()
        
        if existing:
            # Update frequency and context
            existing.frequency += 1
            if entity.context:
                existing.context = {**(existing.context or {}), **entity.context}
            db.commit()
            db.refresh(existing)
            return existing
        
        # Create new entity
        db_entity = models.Entity(**entity.dict())
        db.add(db_entity)
        db.commit()
        db.refresh(db_entity)
        return db_entity
    
    def resolve_entity(
        self, 
        db: Session, 
        query: str, 
        child_id: str,
        entity_type: Optional[str] = None
    ) -> schemas.EntityResolveResponse:
        """Resolve a query to a specific entity using string matching."""
        # Build query
        q = db.query(models.Entity).filter(models.Entity.child_id == child_id)
        
        if entity_type:
            q = q.filter(models.Entity.entity_type == entity_type)
        
        candidates = q.all()
        
        if not candidates:
            return schemas.EntityResolveResponse(confidence=0.0)
        
        # Calculate similarity scores
        scored_candidates = []
        for candidate in candidates:
            # Use SequenceMatcher for fuzzy string matching
            similarity = SequenceMatcher(None, query.lower(), candidate.name.lower()).ratio()
            scored_candidates.append((candidate, similarity))
        
        # Sort by similarity (descending) and frequency (descending)
        scored_candidates.sort(key=lambda x: (x[1], x[0].frequency), reverse=True)
        
        best_match, confidence = scored_candidates[0]
        alternatives = [c[0] for c in scored_candidates[1:4]]  # Top 3 alternatives
        
        return schemas.EntityResolveResponse(
            entity=schemas.Entity.from_orm(best_match),
            confidence=confidence,
            alternatives=[schemas.Entity.from_orm(a) for a in alternatives]
        )
    
    def list_entities(self, db: Session, child_id: str) -> list[models.Entity]:
        """List all entities for a child."""
        return db.query(models.Entity).filter(
            models.Entity.child_id == child_id
        ).order_by(models.Entity.frequency.desc()).all()

knowledge_service = KnowledgeService()
