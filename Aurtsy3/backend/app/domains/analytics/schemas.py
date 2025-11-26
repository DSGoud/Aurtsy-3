from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime, date

class RegulationBattery(BaseModel):
    level: int # 0-100
    status: str # "High", "Moderate", "Low", "Critical"
    inputs: List[str] # e.g., "Good sleep (8h)", "Protein breakfast"
    drains: List[str] # e.g., "2 Unresolved requests", "Sensory overload"
    recommendation: str

class OpenLoop(BaseModel):
    id: int
    request_object: str
    status: str # DENIED, DELAYED, UNRESOLVED
    timestamp: datetime
    time_elapsed_minutes: int
    risk_level: str # Low, Medium, High

class ABCStat(BaseModel):
    label: str # e.g., "Transitions"
    count: int
    percentage: float

class ABCAnalysis(BaseModel):
    top_triggers: List[ABCStat]
    effective_interventions: List[ABCStat]
    total_incidents: int

class Insight(BaseModel):
    type: str # "correlation", "pattern", "alert"
    title: str
    description: str
    confidence: str # High, Medium, Low
    actionable_tip: Optional[str] = None

class WeeklySummary(BaseModel):
    week_start: date
    week_end: date
    total_meals: int
    total_sleep_hours: float
    avg_sleep_quality: float
    total_incidents: int
    regulation_battery: RegulationBattery
    open_loops: List[OpenLoop]
    abc_analysis: ABCAnalysis
    insights: List[Insight]
