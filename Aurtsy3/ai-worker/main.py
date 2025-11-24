from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import random

app = FastAPI(title="Aurtsy AI Worker", version="0.1.0")

class AnalysisRequest(BaseModel):
    image_url: str
    analysis_type: str # "MEAL", "BEHAVIOR"

class AnalysisResult(BaseModel):
    status: str
    data: dict

@app.get("/")
def root():
    return {"message": "Aurtsy AI Worker Ready"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/analyze/", response_model=AnalysisResult)
def analyze_image(request: AnalysisRequest):
    if request.analysis_type == "MEAL":
        try:
            # Try to load YOLO model (requires ultralytics installed)
            from ultralytics import YOLO
            import cv2
            import numpy as np
            import requests
            
            # Load model (will download on first run)
            model = YOLO("yolov8n.pt") 
            
            # Download image from URL (in production, this would be a local path from NAS)
            # For now, we assume it's a reachable URL or local path
            # img = ... load image logic ...
            
            # Mocking the inference for now to avoid crashing if dependencies aren't present
            # In real deployment on 4090:
            # results = model(img)
            # items = [model.names[int(c)] for c in results[0].boxes.cls]
            
            items = ["sandwich", "apple"] # Placeholder until image loading is implemented
            
            return {
                "status": "COMPLETED",
                "data": {
                    "calories_estimated": 450, # Placeholder
                    "items_detected": items,
                    "consumption_percentage": 100 if "post" in request.image_url else 0
                }
            }
        except ImportError:
            # Fallback if ultralytics is not installed
            print("Ultralytics not found, using stub")
            return {
                "status": "COMPLETED",
                "data": {
                    "calories_estimated": random.randint(200, 800),
                    "items_detected": ["stub_food_item"],
                    "consumption_percentage": 50
                }
            }
            
    elif request.analysis_type == "BEHAVIOR":
        return {
            "status": "COMPLETED",
            "data": {
                "behavior_detected": "calm",
                "confidence": 0.95
            }
        }
    
    raise HTTPException(status_code=400, detail="Unknown analysis type")
