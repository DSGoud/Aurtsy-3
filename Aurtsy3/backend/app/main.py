from fastapi import FastAPI
from app.core.database import engine, Base
from app.domains.users import router as users_router, models as user_models
from app.domains.children import router as children_router, models as child_models
from app.domains.meals import router as meals_router, models as meal_models
from app.domains.ai import router as ai_router, models as ai_models
from app.domains.knowledge import router as knowledge_router, models as knowledge_models
from app.domains.alerts import router as alerts_router, models as alert_models
from app.domains.sleep import router as sleep_router, models as sleep_models
from app.domains.behavior import router as behavior_router, models as behavior_models
from app.domains.activities import router as activity_router, models as activity_models
from app.domains.hydration import router as hydration_router, models as hydration_models
from app.domains.analytics import router as analytics_router, schemas as analytics_schemas
from app.domains.chat import router as chat_router, models as chat_models

# Create tables (in a real app, use Alembic migrations)
# Import all models to ensure they are registered with Base
from app.core.database import Base
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Aurtsy API", version="0.3.0")

# Include Routers
app.include_router(users_router.router, prefix="/users", tags=["users"])
app.include_router(children_router.router, prefix="/children", tags=["children"])
# Note: The original API had /children/{child_id}/meals, but for simplicity we can use /meals
# and pass child_id as query or body. To keep backward compatibility with iOS app:
# The iOS app calls: /children/{child_id}/meals/
# We need to support that structure or update the iOS app.
# For now, let's mount meals router under /children/{child_id}/meals to match iOS expectation?
# Actually, the iOS app uses: "\(baseURL)/meals/?user_id=..."
# Wait, checking NetworkManager.swift...
# "let url = URL(string: "\(baseURL)/meals/?user_id=\(currentUser?.id ?? "unknown")")"
# So it uses /meals directly.
app.include_router(meals_router.router, prefix="/meals", tags=["meals"])
app.include_router(ai_router.router, prefix="/ai", tags=["ai"])
app.include_router(knowledge_router.router, prefix="/knowledge", tags=["knowledge"])
app.include_router(alerts_router.router, prefix="/alerts", tags=["alerts"])
app.include_router(sleep_router.router, prefix="/sleep", tags=["sleep"])
app.include_router(behavior_router.router, prefix="/behavior", tags=["behavior"])
app.include_router(activity_router.router, prefix="/activities", tags=["activities"])
app.include_router(hydration_router.router, prefix="/hydration", tags=["hydration"])
app.include_router(analytics_router.router, prefix="/analytics", tags=["analytics"])
app.include_router(chat_router.router, prefix="/chat", tags=["chat"])

@app.get("/health")
def health_check():
    return {"status": "healthy"}
