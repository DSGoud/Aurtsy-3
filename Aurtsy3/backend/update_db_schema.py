import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import engine, Base
from app.domains.behavior.models import BehaviorLog
from app.domains.children.models import Child # Required for ForeignKey resolution

def reset_behavior_table():
    print("Dropping behavior_logs table...")
    BehaviorLog.__table__.drop(engine, checkfirst=True)
    print("Recreating behavior_logs table...")
    BehaviorLog.__table__.create(engine)
    print("Done!")

if __name__ == "__main__":
    reset_behavior_table()
