#!/usr/bin/env python3
"""
Populate test data for John (john_001) to demonstrate analytics features
"""

import requests
from datetime import datetime, timedelta
import random

BASE_URL = "http://100.79.130.75:8090"
CHILD_ID = "john_001"
USER_ID = "test_user"

def create_sleep_logs():
    """Create sleep logs for the past week"""
    print("Creating sleep logs...")
    for days_ago in range(7):
        date = datetime.now() - timedelta(days=days_ago)
        
        # Night sleep
        start_time = date.replace(hour=21, minute=0)
        
        # Vary sleep quality and duration
        if days_ago in [2, 5]:  # Bad sleep days
            duration_hours = random.uniform(5, 6.5)
            quality = random.randint(1, 2)
        else:  # Good sleep days
            duration_hours = random.uniform(7.5, 9)
            quality = random.randint(3, 5)
        
        end_time = start_time + timedelta(hours=duration_hours)
        
        payload = {
            "child_id": CHILD_ID,
            "start_time": start_time.isoformat(),
            "end_time": end_time.isoformat(),
            "quality_rating": quality,
            "notes": f"Sleep quality: {quality}/5"
        }
        
        response = requests.post(
            f"{BASE_URL}/sleep/?user_id={USER_ID}",
            json=payload
        )
        print(f"  Sleep log {days_ago} days ago: {response.status_code}")

def create_meals():
    """Create meals for the past week"""
    print("Creating meals...")
    meal_types = ["BREAKFAST", "LUNCH", "DINNER", "SNACK"]
    
    for days_ago in range(7):
        date = datetime.now() - timedelta(days=days_ago)
        
        # Breakfast, lunch, dinner, snacks
        for meal_type in meal_types[:3]:  # Skip snack for variety
            if meal_type == "BREAKFAST":
                hour = 8
            elif meal_type == "LUNCH":
                hour = 12
            else:  # DINNER
                hour = 18
            
            created_at = date.replace(hour=hour, minute=0)
            
            payload = {
                "child_id": CHILD_ID,
                "user_id": USER_ID,
                "meal_type": meal_type,
                "notes": f"{meal_type.lower().capitalize()} - protein-rich meal",
                "analysis_status": "COMPLETED"
            }
            
            response = requests.post(
                f"{BASE_URL}/meals/?user_id={USER_ID}",
                json=payload
            )
            print(f"  Meal {meal_type} {days_ago} days ago: {response.status_code}")

def create_behavior_logs():
    """Create behavior logs with analysis_data for analytics"""
    print("Creating behavior logs...")
    
    # Meltdowns on bad sleep days
    bad_sleep_days = [2, 5]
    
    for days_ago in bad_sleep_days:
        date = datetime.now() - timedelta(days=days_ago)
        
        # Meltdown in afternoon
        created_at = date.replace(hour=15, minute=30)
        
        payload = {
            "child_id": CHILD_ID,
            "behavior_type": "MELTDOWN",
            "mood_rating": 1,
            "incident_description": "Major meltdown in living room",
            "severity": 4,
            "analysis_data": {
                "antecedent": "Denied screen time after already poor sleep",
                "behavior": "Screaming, hitting, throwing objects",
                "consequence": "Removed to quiet room until calm",
                "intervention": "Deep pressure, calm voice",
                "request_object": None,
                "request_status": None,
                "food_seeking": False
            }
        }
        
        response = requests.post(
            f"{BASE_URL}/behavior/?user_id={USER_ID}",
            json=payload
        )
        print(f"  Meltdown {days_ago} days ago: {response.status_code}")
    
    # Open loops (unresolved requests)
    recent_date = datetime.now() - timedelta(hours=2)
    
    # Denied iPad request
    payload = {
        "child_id": CHILD_ID,
        "behavior_type": "REQUEST",
        "mood_rating": 3,
        "incident_description": "Asked for iPad, was denied",
        "severity": 2,
        "analysis_data": {
            "antecedent": "Saw iPad on table",
            "behavior": "Asked nicely but became upset when denied",
            "consequence": "Continued to ask repeatedly",
            "intervention": "Offered alternative activity",
            "request_object": "iPad",
            "request_status": "DENIED",
            "food_seeking": False
        }
    }
    
    response = requests.post(
        f"{BASE_URL}/behavior/?user_id={USER_ID}",
        json=payload
    )
    print(f"  Denied iPad request: {response.status_code}")
    
    # Delayed snack request
    recent_date2 = datetime.now() - timedelta(minutes=90)
    
    payload = {
        "child_id": CHILD_ID,
        "behavior_type": "REQUEST",
        "mood_rating": 4,
        "incident_description": "Asked for cookies, told to wait until after dinner",
        "severity": 1,
        "analysis_data": {
            "antecedent": "Hungry before dinner time",
            "behavior": "Asked for cookies",
            "consequence": "Told to wait 30 minutes",
            "intervention": "Offered water and distraction",
            "request_object": "Cookies",
            "request_status": "DELAYED",
            "food_seeking": True
        }
    }
    
    response = requests.post(
        f"{BASE_URL}/behavior/?user_id={USER_ID}",
        json=payload
    )
    print(f"  Delayed cookie request: {response.status_code}")
    
    # Successful interventions
    for days_ago in range(1, 4):
        date = datetime.now() - timedelta(days=days_ago)
        created_at = date.replace(hour=10, minute=0)
        
        payload = {
            "child_id": CHILD_ID,
            "behavior_type": "AGITATION",
            "mood_rating": 3,
            "incident_description": "Minor agitation resolved quickly",
            "severity": 2,
            "analysis_data": {
                "antecedent": "Transition between activities",
                "behavior": "Mild frustration, raised voice",
                "consequence": "Calmed down within 5 minutes",
                "intervention": "Visual schedule reminder",
                "request_object": None,
                "request_status": None,
                "food_seeking": False
            }
        }
        
        response = requests.post(
            f"{BASE_URL}/behavior/?user_id={USER_ID}",
            json=payload
        )
        print(f"  Agitation {days_ago} days ago: {response.status_code}")

def main():
    print(f"Populating data for child: {CHILD_ID}")
    print(f"Using user: {USER_ID}")
    print(f"Target: {BASE_URL}\n")
    
    create_sleep_logs()
    print()
    create_meals()
    print()
    create_behavior_logs()
    print()
    
    print("✅ Data population complete!")
    print(f"\nNow test the analytics endpoint:")
    print(f"curl {BASE_URL}/analytics/weekly-summary/{CHILD_ID}")

if __name__ == "__main__":
    main()
