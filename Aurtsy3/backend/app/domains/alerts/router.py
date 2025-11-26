from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.domains.alerts import schemas, service

router = APIRouter()

@router.get("/{child_id}", response_model=list[schemas.Alert])
def list_alerts(
    child_id: str, 
    include_acknowledged: bool = False,
    db: Session = Depends(get_db)
):
    """
    List all alerts for a specific child.
    By default, only shows unacknowledged alerts.
    """
    alerts = service.alert_service.list_alerts(db, child_id, include_acknowledged)
    return [schemas.Alert.from_orm(a) for a in alerts]

@router.post("/{alert_id}/acknowledge", response_model=schemas.Alert)
def acknowledge_alert(alert_id: int, db: Session = Depends(get_db)):
    """
    Mark an alert as acknowledged.
    """
    try:
        alert = service.alert_service.acknowledge_alert(db, alert_id)
        return schemas.Alert.from_orm(alert)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.post("/analyze/{child_id}")
def analyze_patterns(child_id: str, db: Session = Depends(get_db)):
    """
    Manually trigger pattern analysis for a child.
    This will create alerts if patterns are detected.
    """
    potential_alerts = service.alert_service.analyze_patterns(db, child_id)
    
    created_alerts = []
    for alert_data in potential_alerts:
        alert = service.alert_service.create_alert(db, alert_data)
        created_alerts.append(schemas.Alert.from_orm(alert))
    
    return {
        "analyzed": True,
        "alerts_created": len(created_alerts),
        "alerts": created_alerts
    }
