from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from typing import List, Dict

from app.domains.analytics import schemas
from app.domains.behavior.models import BehaviorLog
from app.domains.meals.models import Meal
from app.domains.sleep.models import SleepLog
from app.domains.activities.models import Activity

class AnalyticsService:
    def get_weekly_summary(self, db: Session, child_id: str) -> schemas.WeeklySummary:
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=7)
        
        # Fetch Data
        meals = db.query(Meal).filter(Meal.child_id == child_id, Meal.created_at >= start_date).all()
        sleeps = db.query(SleepLog).filter(SleepLog.child_id == child_id, SleepLog.start_time >= start_date).all()
        behaviors = db.query(BehaviorLog).filter(BehaviorLog.child_id == child_id, BehaviorLog.created_at >= start_date).all()
        
        # Calculate Regulation Battery (Current Status)
        regulation = self._calculate_regulation_battery(db, child_id)
        
        # Identify Open Loops
        open_loops = self._identify_open_loops(behaviors)
        
        # ABC Analysis
        abc_analysis = self._analyze_abc(behaviors)
        
        # Generate Insights
        insights = self._generate_insights(sleeps, behaviors, meals)
        
        # Basic Stats
        total_sleep_mins = 0
        for s in sleeps:
            if s.end_time:
                duration = (s.end_time - s.start_time).total_seconds() / 60
                total_sleep_mins += duration
        
        avg_sleep_quality = sum([s.quality_rating or 0 for s in sleeps]) / len(sleeps) if sleeps else 0
        
        return schemas.WeeklySummary(
            week_start=start_date.date(),
            week_end=end_date.date(),
            total_meals=len(meals),
            total_sleep_hours=round(total_sleep_mins / 60.0, 1),
            avg_sleep_quality=round(avg_sleep_quality, 1),
            total_incidents=len(behaviors),
            regulation_battery=regulation,
            open_loops=open_loops,
            abc_analysis=abc_analysis,
            insights=insights
        )
    
    def _calculate_regulation_battery(self, db: Session, child_id: str) -> schemas.RegulationBattery:
        # Look at last 24 hours
        since = datetime.utcnow() - timedelta(hours=24)
        
        sleep = db.query(SleepLog).filter(SleepLog.child_id == child_id, SleepLog.start_time >= since).order_by(SleepLog.start_time.desc()).first()
        meals = db.query(Meal).filter(Meal.child_id == child_id, Meal.created_at >= since).all()
        behaviors = db.query(BehaviorLog).filter(BehaviorLog.child_id == child_id, BehaviorLog.created_at >= since).all()
        
        level = 70 # Baseline
        inputs = []
        drains = []
        
        # Sleep Impact
        if sleep and sleep.end_time:
            duration_mins = (sleep.end_time - sleep.start_time).total_seconds() / 60
            if duration_mins > 480: # > 8 hours
                level += 20
                inputs.append("Good sleep (>8h)")
            elif duration_mins < 360: # < 6 hours
                level -= 20
                drains.append("Poor sleep (<6h)")
        
        # Meal Impact
        if len(meals) >= 3:
            level += 10
            inputs.append("Regular meals")
        elif len(meals) < 2:
            level -= 10
            drains.append("Missed meals")
            
        # Behavior Impact
        meltdowns = [b for b in behaviors if b.behavior_type.lower() in ["meltdown", "tantrum", "aggression"]]
        if meltdowns:
            level -= (15 * len(meltdowns))
            drains.append(f"{len(meltdowns)} Meltdowns")
            
        # Cap level
        level = max(0, min(100, level))
        
        status = "High" if level > 80 else "Moderate" if level > 50 else "Low" if level > 20 else "Critical"
        recommendation = "Encourage rest and low-demand activities." if level < 50 else "Great time for learning or outings."
        
        return schemas.RegulationBattery(
            level=level,
            status=status,
            inputs=inputs,
            drains=drains,
            recommendation=recommendation
        )

    def _identify_open_loops(self, behaviors: List[BehaviorLog]) -> List[schemas.OpenLoop]:
        loops = []
        now = datetime.utcnow()
        
        for b in behaviors:
            # Check analysis_data for request status
            if b.analysis_data:
                data = b.analysis_data
                if isinstance(data, dict):
                    status = data.get("request_status", "").upper()
                    if status in ["DENIED", "DELAYED", "UNRESOLVED"]:
                        # Only recent ones (last 4 hours) matter for open loops
                        elapsed = (now - b.created_at.replace(tzinfo=None)).total_seconds() / 60
                        if elapsed < 240: # 4 hours
                            loops.append(schemas.OpenLoop(
                                id=b.id,
                                request_object=data.get("request_object", "Unknown request"),
                                status=status,
                                timestamp=b.created_at,
                                time_elapsed_minutes=int(elapsed),
                                risk_level="High" if elapsed < 60 else "Medium"
                            ))
        return loops

    def _analyze_abc(self, behaviors: List[BehaviorLog]) -> schemas.ABCAnalysis:
        triggers = {}
        interventions = {}
        
        for b in behaviors:
            if b.analysis_data and isinstance(b.analysis_data, dict):
                ant = b.analysis_data.get("antecedent")
                if ant:
                    triggers[ant] = triggers.get(ant, 0) + 1
                
                intv = b.analysis_data.get("intervention")
                if intv:
                    interventions[intv] = interventions.get(intv, 0) + 1
        
        total = len(behaviors)
        
        top_triggers = [
            schemas.ABCStat(label=k, count=v, percentage=round((v/total)*100, 1))
            for k, v in sorted(triggers.items(), key=lambda x: x[1], reverse=True)[:5]
        ]
        
        effective_interventions = [
            schemas.ABCStat(label=k, count=v, percentage=round((v/total)*100, 1))
            for k, v in sorted(interventions.items(), key=lambda x: x[1], reverse=True)[:5]
        ]
        
        return schemas.ABCAnalysis(
            top_triggers=top_triggers,
            effective_interventions=effective_interventions,
            total_incidents=total
        )

    def _generate_insights(self, sleeps: List[SleepLog], behaviors: List[BehaviorLog], meals: List[Meal]) -> List[schemas.Insight]:
        insights = []
        
        # Sleep-Behavior Correlation
        bad_sleep_days = set()
        for s in sleeps:
            if s.end_time:
                duration_mins = (s.end_time - s.start_time).total_seconds() / 60
                if duration_mins < 420: # 7 hours
                    bad_sleep_days.add(s.start_time.date())
        
        meltdowns_after_bad_sleep = 0
        for b in behaviors:
            if b.created_at.date() in bad_sleep_days and b.behavior_type.lower() == "meltdown":
                meltdowns_after_bad_sleep += 1
                
        if meltdowns_after_bad_sleep > 0:
            insights.append(schemas.Insight(
                type="correlation",
                title="Sleep Impact",
                description=f"Detected {meltdowns_after_bad_sleep} meltdowns following nights with poor sleep.",
                confidence="High",
                actionable_tip="Prioritize earlier bedtime tonight."
            ))
            
        return insights

analytics_service = AnalyticsService()
