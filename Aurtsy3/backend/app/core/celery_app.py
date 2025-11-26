from celery import Celery
import os

# Use the same Redis URL as in config.py, but get it directly from env for simplicity in worker
REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")

celery_app = Celery(
    "worker",
    broker=REDIS_URL,
    backend=REDIS_URL
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

# Auto-discover tasks in all domains
celery_app.autodiscover_tasks([
    "app.domains.ai",
    "app.domains.alerts",
])

# Celery Beat schedule for periodic tasks
from celery.schedules import crontab

celery_app.conf.beat_schedule = {
    'analyze-patterns-nightly': {
        'task': 'app.domains.alerts.tasks.analyze_patterns_for_all_children',
        'schedule': crontab(hour=2, minute=0),  # Run at 2 AM daily
    },
}
