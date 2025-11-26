from typing import Callable, Dict, List, Any
import asyncio
import logging

logger = logging.getLogger(__name__)

class EventBus:
    def __init__(self):
        self._subscribers: Dict[str, List[Callable]] = {}

    def subscribe(self, event_name: str, handler: Callable):
        """Subscribe a handler to an event."""
        if event_name not in self._subscribers:
            self._subscribers[event_name] = []
        self._subscribers[event_name].append(handler)
        logger.info(f"Subscribed {handler.__name__} to {event_name}")

    async def publish(self, event_name: str, payload: Any):
        """Publish an event to all subscribers."""
        if event_name not in self._subscribers:
            return

        logger.info(f"Publishing event: {event_name}")
        
        # Run all handlers concurrently
        tasks = []
        for handler in self._subscribers[event_name]:
            if asyncio.iscoroutinefunction(handler):
                tasks.append(asyncio.create_task(handler(payload)))
            else:
                # Run sync handlers in a thread pool to avoid blocking
                tasks.append(asyncio.to_thread(handler, payload))
        
        if tasks:
            await asyncio.gather(*tasks, return_exceptions=True)

# Global instance
event_bus = EventBus()
