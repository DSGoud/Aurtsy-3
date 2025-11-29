from sqlalchemy.orm import Session
from app.domains.ai import schemas
from app.domains.children import models as child_models
from app.domains.meals import models as meal_models
from app.domains.behavior import models as behavior_models
from app.domains.sleep import models as sleep_models
from app.domains.activities import models as activity_models
from app.domains.hydration import models as hydration_models
from app.core.llm import ollama_client
from datetime import datetime, timedelta
import json

class AIService:
    def generate_handoff_summary(self, db: Session, child_id: str) -> schemas.HandoffSummary:
        """
        Generate an AI-powered handoff summary for caregivers.
        Uses Ollama LLM to analyze recent data and provide insights.
        """
        # 1. Fetch last 12 hours of ALL data types
        twelve_hours_ago = datetime.utcnow() - timedelta(hours=12)
        
        # Import additional models
        from app.domains.sleep import models as sleep_models
        from app.domains.behavior import models as behavior_models
        from app.domains.activities import models as activity_models
        from app.domains.hydration import models as hydration_models
        
        recent_meals = db.query(meal_models.Meal).filter(
            meal_models.Meal.child_id == child_id,
            meal_models.Meal.created_at >= twelve_hours_ago
        ).all()
        
        recent_sleep = db.query(sleep_models.SleepLog).filter(
            sleep_models.SleepLog.child_id == child_id,
            sleep_models.SleepLog.start_time >= twelve_hours_ago
        ).all()
        
        recent_behavior = db.query(behavior_models.BehaviorLog).filter(
            behavior_models.BehaviorLog.child_id == child_id,
            behavior_models.BehaviorLog.created_at >= twelve_hours_ago
        ).all()
        
        recent_activities = db.query(activity_models.Activity).filter(
            activity_models.Activity.child_id == child_id,
            activity_models.Activity.created_at >= twelve_hours_ago
        ).all()
        
        recent_hydration = db.query(hydration_models.HydrationLog).filter(
            hydration_models.HydrationLog.child_id == child_id,
            hydration_models.HydrationLog.created_at >= twelve_hours_ago
        ).all()
        
        # 2. Fetch child profile for context
        child = db.query(child_models.Child).filter(child_models.Child.id == child_id).first()
        child_name = child.name if child else "the individual"
        
        # 3. Prepare all data for LLM
        meal_data = [{"type": m.meal_type, "notes": m.notes, "time": m.created_at.isoformat()} for m in recent_meals]
        sleep_data = [{"start": s.start_time.isoformat(), "end": s.end_time.isoformat() if s.end_time else "ongoing", "quality": s.quality_rating, "notes": s.notes} for s in recent_sleep]
        behavior_data = [{"type": b.behavior_type, "mood": b.mood_rating, "description": b.incident_description, "notes": b.notes, "time": b.created_at.isoformat()} for b in recent_behavior]
        activity_data = [{"type": a.activity_type, "details": a.details, "time": a.created_at.isoformat()} for a in recent_activities]
        hydration_data = [{"fluid": h.fluid_type, "amount_ml": h.amount_ml, "notes": h.notes, "time": h.created_at.isoformat()} for h in recent_hydration]
        
        # 4. Build comprehensive prompt for LLM
        system_prompt = f"""You are a compassionate AI assistant helping caregivers of {child_name}, an individual with special needs. 
Your role is to analyze recent caregiving data and provide a concise, actionable handoff summary.
Be empathetic, clear, and focus on what matters most to caregivers. Always reference {child_name} by name in your recommendations."""
        
        user_prompt = f"""Analyze this caregiving data for {child_name} from the last 12 hours and create a handoff summary.

**Patient Profile:**
- Name: {child_name}

**Recent Data:**
- Meals/Snacks: {len(meal_data)} logged
{json.dumps(meal_data, indent=2) if meal_data else "No meals logged"}

- Sleep: {len(sleep_data)} periods
{json.dumps(sleep_data, indent=2) if sleep_data else "No sleep data"}

- Behavior: {len(behavior_data)} incidents/observations
{json.dumps(behavior_data, indent=2) if behavior_data else "No behavior logs"}

- Activities: {len(activity_data)} logged
{json.dumps(activity_data, indent=2) if activity_data else "No activities"}

- Hydration: {len(hydration_data)} drinks
{json.dumps(hydration_data, indent=2) if hydration_data else "No hydration logs"}

**Task:**
1. Provide 2-3 concise bullet points summarizing KEY observations about {child_name}'s day (look for patterns across sleep, diet, behavior)
2. Assign an alert level: LOW (all good), MEDIUM (minor concerns), or HIGH (urgent attention needed)
3. Provide 1-2 SPECIFIC, actionable recommendations for {child_name}'s care team based on the holistic data

**Important:**
- Reference {child_name} by name
- Connect dots between different data types (e.g., "Poor sleep may be affecting behavior")
- Make recommendations SPECIFIC to the actual data

**Response Format (JSON):**
{{
  "summary": ["specific observation 1", "specific observation 2"],
  "alert_level": "LOW|MEDIUM|HIGH",
  "recommendations": ["specific recommendation 1", "specific recommendation 2"]
}}

Respond ONLY with valid JSON, no additional text."""
        
        try:
            # 5. Call Ollama LLM
            response = ollama_client.chat(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.3  # Lower temperature for more consistent output
            )
            
            # 5. Parse LLM response
            # Try to extract JSON from response
            response_text = response.strip()
            if "```json" in response_text:
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                response_text = response_text.split("```")[1].split("```")[0].strip()
            
            result = json.loads(response_text)
            
            return schemas.HandoffSummary(
                summary=result.get("summary", []),
                alert_level=schemas.AlertLevel[result.get("alert_level", "MEDIUM")],
                recommendations=result.get("recommendations", [])
            )
            
        except Exception as e:
            # Fallback to simple logic if LLM fails
            print(f"LLM error: {e}, falling back to simple logic")
            summary_points = []
            if not recent_meals:
                summary_points.append("No meals logged in the last 12 hours.")
                alert_level = schemas.AlertLevel.MEDIUM
            else:
                summary_points.append(f"Consumed {len(recent_meals)} meals/snacks.")
                alert_level = schemas.AlertLevel.LOW
            
            summary_points.append("Sleep and behavior data not yet available.")
            
            return schemas.HandoffSummary(
                summary=summary_points,
                alert_level=alert_level,
                recommendations=["Check hydration.", "Monitor for patterns."]
            )

    def process_voice_log(self, db: Session, child_id: str, user_id: str, text: str) -> schemas.VoiceProcessResponse:
        """
        Process a natural language voice log, classify it, and save to appropriate tables.
        """
        # Import knowledge service here to avoid circular imports if any
        from app.domains.knowledge import service as knowledge_service
        from app.domains.knowledge import schemas as knowledge_schemas
        
        # DEBUG LOGGING
        import datetime
        with open("backend_debug.log", "a") as f:
            f.write(f"\n[{datetime.datetime.now()}] Processing Voice Log: {text[:50]}...\n")

        # 1. Construct Prompt
        system_prompt = """You are an intelligent data entry assistant for a special needs caregiving app.
Your task is to analyze a voice note and extract structured data to save into the database.

**CRITICAL: A single voice note often contains MULTIPLE events. Extract ALL of them.**

Supported Data Types:
1. MEAL: Food/drink intake
2. BEHAVIOR: Moods, meltdowns, positive moments, anxiety, tantrums, aggression, self-harm, REQUESTS
3. SLEEP: Naps, bedtime, wake up, sleep quality
4. ACTIVITY: Therapy, play, exercise
5. HYDRATION: Water, juice, milk intake
6. ENTITY: Permanent knowledge about the child (preferences, triggers, routines, safe foods, etc.)

**Behavior Analysis (ABC Model + Requests):**
For behaviors, identify:
- **Antecedent**: What happened BEFORE (triggers, context)
- **Behavior**: The actual behavior/incident
- **Consequence**: What happened AFTER, how it was resolved
- **Intervention**: Specific strategy used (e.g., "deep pressure", "gave snack")
- **Request Status**: If they asked for something, was it GRANTED, DENIED, DELAYED, or UNRESOLVED?
- **Food Seeking**: Is this a request for food (even if not eaten)? true/false

**Entity Extraction (The Knowledge Base):**
Extract PERMANENT facts about the child that should be remembered for the future.
- **Safe Foods**: Specific brands, textures (e.g., "Only eats Kraft Blue Box")
- **Triggers**: Specific sounds, smells, items (e.g., "Hates vacuum noise")
- **Soothing Tools**: What works to calm them (e.g., "Deep pressure vest")
- **Routines**: Specific steps for bath, bed, etc.
- **Communication**: How they communicate (e.g., "Uses 'To infinity' to mean 'Outside'")

Rules:
- **ALWAYS look for behavioral context around meals/activities**
- Extract temporal relationships
- For behaviors, classify as: positive, meltdown, anxiety, tantrum, aggression, self-harm, neutral, request
- Mood rating: 1 (very bad) to 5 (very good)

Response Format (JSON):
{
  "classifications": ["MEAL", "BEHAVIOR", "ENTITY"],
  "entries": [
    {
      "type": "BEHAVIOR",
      "data": {
        "behavior_type": "meltdown",
        "mood_rating": 2,
        "incident_description": "Full narrative summary...",
        "notes": "Original text...",
        "analysis_data": {
          "antecedent": "Denied access to iPad",
          "behavior": "Screaming and hitting",
          "consequence": "Removed to quiet room",
          "intervention": "Deep pressure",
          "request_object": "iPad",
          "request_status": "DENIED",
          "food_seeking": false
        }
      }
    },
    {
      "type": "ENTITY",
      "data": {
        "entity_type": "safe_food",
        "name": "Kraft Mac & Cheese",
        "resolved_value": "Kraft Macaroni & Cheese (Blue Box)",
        "context": {
          "detail": "Must be the Blue Box version, refuses generic brands",
          "category": "Dietary"
        }
      }
    }
  ]
}
"""
        user_prompt = f"Voice Note: \"{text}\""

        try:
            # 2. Call LLM
            response = ollama_client.chat(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.1
            )
            
            # 3. Parse JSON
            response_text = response.strip()
            if "```json" in response_text:
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                response_text = response_text.split("```")[1].split("```")[0].strip()
            
            result = json.loads(response_text)
            processed_types = []
            
            # 4. Save to DB
            for entry in result.get("entries", []):
                entry_type = entry.get("type")
                data = entry.get("data")
                
                if entry_type == "MEAL":
                    # Normalize meal_type to valid enum values
                    raw_meal_type = data.get("meal_type", "SNACK").upper()
                    # Map common AI outputs to valid MealType enum values
                    meal_type_mapping = {
                        "PRE_MEAL": "PRE_MEAL",
                        "POST_MEAL": "POST_MEAL",
                        "SNACK": "SNACK",
                        "BREAKFAST": "PRE_MEAL",
                        "LUNCH": "PRE_MEAL",
                        "DINNER": "PRE_MEAL",
                        "FOOD": "SNACK",
                        "MEAL": "PRE_MEAL"
                    }
                    normalized_meal_type = meal_type_mapping.get(raw_meal_type, "SNACK")
                    
                    new_meal = meal_models.Meal(
                        child_id=child_id,
                        user_id=user_id,
                        meal_type=normalized_meal_type,
                        notes=data.get("notes", text)
                    )
                    db.add(new_meal)
                    processed_types.append("meal")
                    
                elif entry_type == "BEHAVIOR":
                    # Extract analysis data
                    analysis_data = data.get("analysis_data", {})
                    
                    # Ensure incident_description is populated
                    description = data.get("incident_description")
                    if not description:
                        # Fallback: Construct from ABC if description missing
                        parts = []
                        if analysis_data.get("antecedent"): parts.append(f"Trigger: {analysis_data['antecedent']}")
                        if analysis_data.get("behavior"): parts.append(f"Behavior: {analysis_data['behavior']}")
                        if analysis_data.get("consequence"): parts.append(f"Result: {analysis_data['consequence']}")
                        description = " | ".join(parts) if parts else text

                    new_behavior = behavior_models.BehaviorLog(
                        child_id=child_id,
                        behavior_type=data.get("behavior_type", "neutral"),
                        mood_rating=data.get("mood_rating", 3),
                        incident_description=description,
                        notes=data.get("notes", text),
                        analysis_data=analysis_data
                    )
                    db.add(new_behavior)
                    processed_types.append("behavior")
                
                elif entry_type == "ENTITY":
                    # Create knowledge entity
                    entity_create = knowledge_schemas.EntityCreate(
                        child_id=child_id,
                        entity_type=data.get("entity_type", "general"),
                        name=data.get("name", "Unknown"),
                        resolved_value=data.get("resolved_value", data.get("name", "Unknown")),
                        context=data.get("context", {})
                    )
                    knowledge_service.knowledge_service.create_entity(db, entity_create)
                    processed_types.append("entity")
                
                # (Add other types as needed)
            
            db.commit()
            
            return schemas.VoiceProcessResponse(
                success=True,
                processed_types=processed_types,
                message=f"Successfully processed: {', '.join(processed_types)}"
            )
            
        except Exception as e:
            import traceback
            error_msg = f"Error: {str(e)}\n{traceback.format_exc()}"
            print(error_msg)
            
            # Fallback: Save as generic behavior note
            try:
                fallback_behavior = behavior_models.BehaviorLog(
                    child_id=child_id,
                    behavior_type="voice_note",
                    mood_rating=3,
                    incident_description=text,
                    notes=f"Processed via fallback. Original error: {str(e)}"
                )
                db.add(fallback_behavior)
                db.commit()
                
                return schemas.VoiceProcessResponse(
                    success=True,
                    processed_types=["behavior"],
                    message=f"Saved as general note. AI Error: {str(e)}"
                )
            except Exception as db_error:
                return schemas.VoiceProcessResponse(
                    success=False,
                    processed_types=[],
                    message=f"Critical Error: {str(e)} | DB Error: {str(db_error)}"
                )

    def generate_contextual_question(self, db: Session, child_id: str, context: str) -> schemas.ContextualQuestionResponse:
        """
        Generate a single, relevant follow-up question to fill knowledge gaps based on context.
        """
        from app.domains.knowledge import service as knowledge_service
        
        # 1. Fetch existing knowledge to avoid asking known things
        entities = knowledge_service.knowledge_service.list_entities(db, child_id)
        knowledge_summary = "\n".join([f"- {e.name} ({e.entity_type}): {e.resolved_value}" for e in entities])
        
        # 2. Fetch Recent Conversation History (Last 5 logs)
        # This is CRITICAL for handling corrections ("I meant X, not Y")
        from app.domains.behavior import models as behavior_models
        recent_logs = db.query(behavior_models.BehaviorLog).filter(
            behavior_models.BehaviorLog.child_id == child_id
        ).order_by(behavior_models.BehaviorLog.created_at.desc()).limit(5).all()
        
        # Reverse to show chronological order
        history_text = ""
        if recent_logs:
            history_text = "\n".join([f"- {log.created_at.strftime('%H:%M')}: {log.notes}" for log in reversed(recent_logs)])
        
        # 3. Construct Prompt
        system_prompt = f"""You are an inquisitive care assistant building a "User Manual" for a child with special needs.
Your goal is to ask ONE specific, high-value question to fill a gap in our knowledge base, based on the current context.

**Existing Knowledge:**
{knowledge_summary if entities else "No knowledge yet."}

**Recent Conversation History:**
{history_text if history_text else "No recent history."}

**Current Context:**
User just logged: "{context}"

**Strategy:**
1. **Check for Corrections**: If the user says "I meant...", "Correction", or contradicts a previous log, TRUST THE LATEST INPUT and ignore the previous error.
2. **Identify Gaps**: What is MISSING from our knowledge related to this context?
3. **Ask ONE Question**: Formulate ONE simple, conversational question.
4. **Avoid Hallucinations**: Do not invent details (like "Olive Garden") unless explicitly mentioned in the history.
5. If we already know everything relevant, return null.

**Examples:**
- Context: "Bath" -> Question: "Does he have a preferred soap brand?" (If soap unknown)
- Context: "Meltdown at Park" -> Question: "What specific trigger caused it?" (If trigger unknown)
- Context: "I meant perseverating, not writing" -> Question: "What specific behavior does 'perseverating' involve?" (Correcting previous topic)

**Response Format (JSON):**
{{
  "question": "The actual question text",
  "context_id": "category_topic",
  "reasoning": "Why this question matters"
}}
"""
        
        try:
            response = ollama_client.chat(
                messages=[{"role": "system", "content": system_prompt}],
                temperature=0.2 # Lower temperature to reduce hallucinations
            )
            
            response_text = response.strip()
            if "```json" in response_text:
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                response_text = response_text.split("```")[1].split("```")[0].strip()
                
            result = json.loads(response_text)
            
            return schemas.ContextualQuestionResponse(
                question=result.get("question"),
                context_id=result.get("context_id"),
                reasoning=result.get("reasoning")
            )
            
        except Exception as e:
            print(f"Error generating question: {e}")
            return schemas.ContextualQuestionResponse()

ai_service = AIService()
