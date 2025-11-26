from sqlalchemy.orm import Session
from app.domains.alerts import models, schemas
from app.domains.meals import models as meal_models
from app.domains.children import models as child_models
from datetime import datetime, timedelta
from typing import List

class AlertService:
    def create_alert(self, db: Session, alert: schemas.AlertCreate) -> models.Alert:
        """Create a new alert."""
        db_alert = models.Alert(**alert.dict())
        db.add(db_alert)
        db.commit()
        db.refresh(db_alert)
        return db_alert
    
    def list_alerts(
        self, 
        db: Session, 
        child_id: str,
        include_acknowledged: bool = False
    ) -> List[models.Alert]:
        """List alerts for a child."""
        query = db.query(models.Alert).filter(models.Alert.child_id == child_id)
        
        if not include_acknowledged:
            query = query.filter(models.Alert.is_acknowledged == False)
        
        return query.order_by(models.Alert.created_at.desc()).all()
    
    def acknowledge_alert(self, db: Session, alert_id: int) -> models.Alert:
        """Mark an alert as acknowledged."""
        alert = db.query(models.Alert).filter(models.Alert.id == alert_id).first()
        if not alert:
            raise ValueError("Alert not found")
        
        alert.is_acknowledged = True
        alert.acknowledged_at = datetime.utcnow()
        db.commit()
        db.refresh(alert)
        return alert
    
    def analyze_patterns(self, db: Session, child_id: str) -> List[schemas.AlertCreate]:
        """
        Analyze recent data for patterns and generate alerts.
        This is a simplified version - will be enhanced with LLM later.
        """
        alerts_to_create = []
        
        # Fetch last 7 days of meals
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        recent_meals = db.query(meal_models.Meal).filter(
            meal_models.Meal.child_id == child_id,
            meal_models.Meal.created_at >= seven_days_ago
        ).all()
        
        # Simple pattern: Check if meals are being logged regularly
        if len(recent_meals) < 14:  # Less than 2 meals/day average
            alerts_to_create.append(schemas.AlertCreate(
                child_id=child_id,
                alert_type="pattern_detected",
                severity="MEDIUM",
                title="Low Meal Logging Frequency",
                description=f"Only {len(recent_meals)} meals logged in the past 7 days. Consider logging meals more consistently.",
                pattern_data={
                    "meal_count": len(recent_meals),
                    "days_analyzed": 7,
                    "average_per_day": round(len(recent_meals) / 7, 1)
                }
            ))
        
        # TODO: Add more sophisticated pattern detection:
        # - Sleep quality correlation with behavior
        # - Meal timing patterns
        # - Hydration trends
        # - LLM-based analysis
        
        return alerts_to_create

alert_service = AlertService()
