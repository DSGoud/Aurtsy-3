from celery import shared_task
from app.core.database import SessionLocal
from app.domains.alerts import service as alert_service
from app.domains.children import models as child_models

@shared_task
def analyze_patterns_for_all_children():
    """
    Celery task that runs nightly to analyze patterns for all children.
    Creates alerts if concerning patterns are detected.
    """
    db = SessionLocal()
    try:
        # Get all children
        children = db.query(child_models.Child).all()
        
        total_alerts_created = 0
        for child in children:
            # Analyze patterns for this child
            potential_alerts = alert_service.alert_service.analyze_patterns(db, child.id)
            
            # Create alerts
            for alert_data in potential_alerts:
                alert_service.alert_service.create_alert(db, alert_data)
                total_alerts_created += 1
        
        return {
            "success": True,
            "children_analyzed": len(children),
            "alerts_created": total_alerts_created
        }
    finally:
        db.close()
