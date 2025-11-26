import sys
import os

# Ensure we can import from 'app'
sys.path.append(os.getcwd())

from app.core.database import SessionLocal
# Import ALL models to ensure relationships are resolved
from app.domains.users import models as user_models
from app.domains.children import models as child_models
from app.domains.meals import models as meal_models
from app.domains.ai import models as ai_models
from app.domains.knowledge import models as knowledge_models
from app.domains.alerts import models as alert_models
from app.domains.sleep import models as sleep_models
from app.domains.behavior import models as behavior_models
from app.domains.activities import models as activity_models
from app.domains.hydration import models as hydration_models

def create_user():
    db = SessionLocal()
    try:
        user = db.query(user_models.User).filter(user_models.User.id == 'test_user').first()
        if not user:
            print("Creating test_user...")
            user = user_models.User(id='test_user', email='test@example.com', hashed_password='hash')
            db.add(user)
            db.commit()
            print("Created test_user successfully.")
        else:
            print("test_user already exists.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_user()
