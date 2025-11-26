#!/usr/bin/env python3
"""
Populate test data for Aurtsy app with a realistic persona.

Persona: John - 23 year old male with autism spectrum disorder
- Behavior challenges (meltdowns, sensory overload)
- Sleep difficulties (irregular patterns, restlessness)
- Dietary preferences (texture sensitivities)
- Regular activities (walks, music therapy)
"""

import requests
import random
from datetime import datetime, timedelta

BASE_URL = "http://100.79.130.75:8090"
USER_ID = "test_user"

def create_child():
    """Create John's profile"""
    birthdate = "2002-03-15"  # 23 years old
    
    response = requests.post(
        f"{BASE_URL}/children/",
        json={
            "id": "john_001",
            "name": "John",
            "birthdate": birthdate
        }
    )
    print(f"✅ Created child profile: John (23yo)")
    return "john_001"

def populate_meals(child_id):
    """Generate realistic meal data for past 7 days"""
    meal_types = ["PRE_MEAL", "POST_MEAL", "SNACK"]
    
    # John's meal preferences and patterns
    meals_data = [
        # Today
        ("SNACK", "Had his favorite - plain crackers with cheese. Ate everything.", 2),
        ("POST_MEAL", "MAC AND CHEESE FOR LUNCH!!! (his safe food). Good appetite.", 4),
        
        # Yesterday 
        ("POST_MEAL", "Grilled chicken (cut into small pieces). Needed extra time to finish.", 1),
        ("SNACK", "Apple slices with peanut butter. Texture was okay today.", 1),
        ("POST_MEAL", "Tried new vegetable - broccoli. Only ate 2 pieces, rest was mac & cheese.", 1),
        
        # 2 days ago
        ("POST_MEAL", "Breakfast: Scrambled eggs (soft), toast (no crust). Ate 75%.", 2),
        ("SNACK", "Goldfish crackers. Counted them first (exactly 30).", 2),
        ("POST_MEAL", "Dinner: Pasta with butter. No sauce (too slimy). Ate well.", 2),
        
        # 3 days ago
        ("POST_MEAL", "Chicken nuggets (5 pieces). Must be crispy, not soggy.", 3),
        ("POST_MEAL", "Refused lunch - too loud in dining room. Ate crackers later.", 3),
        
        # 4 days ago
        ("POST_MEAL", "Pizza day! Plain cheese only, crust removed. Happy mood.", 4),
        ("SNACK", "Chocolate milk - his comfort drink after therapy.", 4),
        
        # 5 days ago
        ("POST_MEAL", "Oatmeal with brown sugar. Complained about \"lumps\" but finished.", 5),
        ("SNACK", "Carrot sticks - tried 1 bite, didn't like. Had crackers instead.", 5),
        
        # 6 days ago
        ("POST_MEAL", "Taco Tuesday - deconstructed. Just meat, cheese, shell separate.", 6),
        ("POST_MEAL", "Yogurt (vanilla only). Checked expiration date 3 times.", 6),
    ]
    
    for meal_type, notes, days_ago in meals_data:
        requests.post(
            f"{BASE_URL}/meals/?user_id={USER_ID}",
            json={
                "child_id": child_id,
                "meal_type": meal_type,
                "notes": notes
            }
        )
    
    print(f"✅ Created {len(meals_data)} meal logs")

def populate_sleep(child_id):
    """Generate sleep data showing irregular patterns"""
    sleep_data = [
        # Last night - poor sleep
        {
            "start": datetime.now() - timedelta(hours=10),
            "end": datetime.now() - timedelta(hours=2),
            "quality": 2,
            "notes": "Woke up 3 times. Had nightmare about loud noises. Needed weighted blanket."
        },
        # 2 nights ago - okay
        {
            "start": datetime.now() - timedelta(days=1, hours=21),
            "end": datetime.now() - timedelta(days=1, hours=6),
            "quality": 3,
            "notes": "Better night. Used white noise machine. Only 1 wake-up."
        },
        # 3 nights ago - good
        {
            "start": datetime.now() - timedelta(days=2, hours=22),
            "end": datetime.now() - timedelta(days=2, hours=7),
            "quality": 4,
            "notes": "Great sleep! Followed bedtime routine perfectly. Read favorite book."
        },
        # 4 nights ago - rough
        {
            "start": datetime.now() - timedelta(days=3, hours=23),
            "end": datetime.now() - timedelta(days=3, hours=5),
            "quality": 1,
            "notes": "Very restless. Sensory overload from earlier meltdown. Took 2 hrs to fall asleep."
        },
        # 5 nights ago
        {
            "start": datetime.now() - timedelta(days=4, hours=21, minutes=30),
            "end": datetime.now() - timedelta(days=4, hours=6, minutes=45),
            "quality": 4,
            "notes": "Calm evening routine helped. No screen time before bed."
        },
    ]
    
    for sleep in sleep_data:
        requests.post(
            f"{BASE_URL}/sleep/?user_id={USER_ID}",
            json={
                "child_id": child_id,
                "start_time": sleep["start"].isoformat(),
                "end_time": sleep["end"].isoformat(),
                "quality_rating": sleep["quality"],
                "notes": sleep["notes"]
            }
        )
    
    print(f"✅ Created {len(sleep_data)} sleep logs")

def populate_behavior(child_id):
    """Generate behavior logs including meltdowns and good days"""
    behavior_data = [
        # Recent meltdown
        {
            "type": "meltdown",
            "mood": 1,
            "description": "Sensory overload at grocery store. Too bright, too loud. Lasted 15 mins.",
            "notes": "Trigger: fluorescent lights + cart wheels squeaking. Used noise-canceling headphones for recovery.",
            "hours_ago": 3
        },
        # Good moment
        {
            "type": "positive",
            "mood": 5,
            "description": "Completed puzzle independently! (250 pieces)",
            "notes": "Focused for 45 minutes straight. Very proud of himself. Asked to do another one.",
            "hours_ago": 8
        },
        # Yesterday - anxiety
        {
            "type": "anxiety",
            "mood": 2,
            "description": "Worried about schedule change. Therapy time moved 30 minutes earlier.",
            "notes": "Needed extra reassurance. Used visual schedule to prepare. Eventually adjusted.",
            "hours_ago": 26
        },
        # 2 days ago - routine success
        {
            "type": "positive",
            "mood": 4,
            "description": "Followed morning routine perfectly. Even brushed teeth without reminder!",
            "notes": "Using checklist really helping. He likes checking things off.",
            "hours_ago": 50
        },
        # 3 days ago - social challenge
        {
            "type": "social_difficulty",
            "mood": 2,
            "description": "Had trouble at group activity. Too many people talking at once.",
            "notes": "Stepped out for break. Needed 10 mins quiet time. Rejoined after.",
            "hours_ago": 74
        },
        # 5 days ago - sensory seeking
        {
            "type": "sensory",
            "mood": 3,
            "description": "Needed extra vestibular input - wanted to swing for 30 mins",
            "notes": "Self-regulation tool. Helped him stay calm rest of day.",
            "hours_ago": 122
        },
    ]
    
    for behavior in behavior_data:
        created_time = datetime.now() - timedelta(hours=behavior["hours_ago"])
        requests.post(
            f"{BASE_URL}/behavior/?user_id={USER_ID}",
            json={
                "child_id": child_id,
                "behavior_type": behavior["type"],
                "mood_rating": behavior["mood"],
                "incident_description": behavior["description"],
                "notes": behavior["notes"]
            }
        )
    
    print(f"✅ Created {len(behavior_data)} behavior logs")

def populate_activities(child_id):
    """Generate activity logs"""
    activities = [
        ("Walk in park", 30, "Favorite route. Watched birds. Counted 7 robins.", 4),
        ("Music therapy", 45, "Played piano. Learning new song. Very engaged.", 8),
        ("Swimming", 25, "Sensory integration activity. Loves the water.", 28),
        ("Art class", 40, "Painting with blue (favorite color). Made ocean scene.", 52),
        ("Outdoor time", 20, "Played on swings. Good vestibular input.", 76),
    ]
    
    for activity_type, duration, notes, hours_ago in activities:
        requests.post(
            f"{BASE_URL}/activities/?user_id={USER_ID}",
            json={
                "child_id": child_id,
                "activity_type": activity_type,
                "details": {
                    "duration_minutes": duration,
                    "notes": notes
                }
            }
        )
    
    print(f"✅ Created {len(activities)} activity logs")

def populate_hydration(child_id):
    """Generate hydration logs"""
    hydration_data = [
        ("water", 250, "Morning water. Reminded 2x.", 2),
        ("juice", 180, "Apple juice with lunch.", 5),
        ("water", 300, "After swimming - drank whole bottle!", 28),
        ("milk", 240, "Chocolate milk (comfort drink).", 30),
        ("water", 200, "With medication.", 50),
    ]
    
    for fluid_type, amount, notes, hours_ago in hydration_data:
        requests.post(
            f"{BASE_URL}/hydration/?user_id={USER_ID}",
            json={
                "child_id": child_id,
                "amount_ml": amount,
                "fluid_type": fluid_type,
                "notes": notes
            }
        )
    
    print(f"✅ Created {len(hydration_data)} hydration logs")

def populate_knowledge_base(child_id):
    """Add entities to knowledge base"""
    entities = [
        {
            "entity_type": "restaurant",
            "name": "Olive Garden",
            "resolved_value": "Olive Garden Italian Restaurant",
            "context": {
                "safe_food": "plain pasta with butter",
                "seating_preference": "booth in quiet corner",
                "notes": "Always orders same thing. Knows the menu."
            }
        },
        {
            "entity_type": "person",
            "name": "Dr. Sarah",
            "resolved_value": "Dr. Sarah Martinez - Speech Therapist",
            "context": {
                "relationship": "therapist",
                "frequency": "twice weekly",
                "notes": "John really likes her. She uses visual aids."
            }
        },
        {
            "entity_type": "location",
            "name": "The Park",
            "resolved_value": "Riverside Park - North Entrance",
            "context": {
                "favorite_spot": "by the pond with ducks",
                "notes": "Goes here when needs calming down. Counts ducks."
            }
        },
        {
            "entity_type": "item",
            "name": "blue blanket",
            "resolved_value": "Weighted blanket (15 lbs, blue)",
            "context": {
                "use": "sleep aid, anxiety relief",
                "notes": "Cannot sleep without it. Brings everywhere."
            }
        },
    ]
    
    for entity in entities:
        requests.post(
            f"{BASE_URL}/knowledge/entities",
            json={
                "child_id": child_id,
                **entity
            }
        )
    
    print(f"✅ Created {len(entities)} knowledge base entities")

def main():
    print("\n🎭 Creating Test Persona: John (23yo, Autism)\n" + "="*50)
    
    try:
        child_id = create_child()
        populate_meals(child_id)
        populate_sleep(child_id)
        populate_behavior(child_id)
        populate_activities(child_id)
        populate_hydration(child_id)
        populate_knowledge_base(child_id)
        
        print("\n" + "="*50)
        print("✨ Test data population complete!")
        print(f"\n📱 Child ID: {child_id}")
        print(f"🔗 Backend: {BASE_URL}")
        print("\nYou can now test the app with realistic data! 🎉\n")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("Make sure the backend is running at http://100.79.130.75:8090")

if __name__ == "__main__":
    main()
