from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from app.domains.chat import models, schemas
from app.domains.ai import service as ai_service
import json

class ChatService:
    def get_or_create_session(self, db: Session, child_id: str) -> models.ChatSession:
        # 1. Find active session (active flag + recent activity)
        thirty_mins_ago = datetime.utcnow() - timedelta(minutes=30)
        
        session = db.query(models.ChatSession).filter(
            models.ChatSession.child_id == child_id,
            models.ChatSession.is_active == True,
            models.ChatSession.last_activity_at >= thirty_mins_ago
        ).order_by(models.ChatSession.last_activity_at.desc()).first()
        
        if session:
            # Update activity time
            session.last_activity_at = datetime.utcnow()
            db.commit()
            return session
            
        # 2. Create new session
        # First, mark old sessions as inactive (optional cleanup)
        old_sessions = db.query(models.ChatSession).filter(
            models.ChatSession.child_id == child_id,
            models.ChatSession.is_active == True
        ).all()
        for s in old_sessions:
            s.is_active = False
            
        new_session = models.ChatSession(child_id=child_id)
        db.add(new_session)
        db.commit()
        db.refresh(new_session)
        return new_session

    def get_session_history(self, db: Session, child_id: str) -> models.ChatSession:
        # Get the most recent active session with messages
        return self.get_or_create_session(db, child_id)

    def process_message(self, db: Session, child_id: str, user_id: str, content: str) -> schemas.SendMessageResponse:
        # 1. Get Session
        session = self.get_or_create_session(db, child_id)
        
        # 2. Save User Message
        user_msg = models.ChatMessage(
            session_id=session.id,
            role=models.MessageRole.USER,
            content=content
        )
        db.add(user_msg)
        db.commit()
        db.refresh(user_msg)
        
        # 3. Process with AI (The "Brain")
        # We use the existing AI service to extract data
        # Note: We pass the raw text. The AI service now uses recent logs for context,
        # but ideally we should pass the CHAT history for context.
        # For now, let's stick to the existing flow but capture the output.
        
        ai_text = ""
        processed_summary = {}
        
        # Sanitize user_id to prevent ForeignKey errors
        # If user_id is "unknown" or empty, default to "test_user"
        # In a real app, we would validate against the DB or require auth
        safe_user_id = user_id if user_id and user_id != "unknown" else "test_user"
        
        try:
            process_result = ai_service.ai_service.process_voice_log(db, child_id, safe_user_id, content)
            
            # 4. Generate AI Response (The "Voice")
            # If the AI extracted data, we acknowledge it.
            # If it generated a question, we ask it.
            
            # Check for contextual question
            question_response = ai_service.ai_service.generate_contextual_question(db, child_id, content)
            
            if question_response.question:
                ai_text = question_response.question
            else:
                # Default acknowledgments based on what was saved
                if "meal" in process_result.processed_types:
                    ai_text = "Got it, saved the meal."
                elif "behavior" in process_result.processed_types:
                    ai_text = "Logged the behavior."
                elif "sleep" in process_result.processed_types:
                    ai_text = "Sleep log updated."
                else:
                    ai_text = "I've noted that down."
                    
            processed_summary = {"types": process_result.processed_types}
            
        except Exception as e:
            print(f"Error processing message with AI: {e}")
            ai_text = "I saved your message, but I'm having trouble processing it right now."
            processed_summary = {"error": str(e)}
                
        # 5. Save AI Message
        ai_msg = models.ChatMessage(
            session_id=session.id,
            role=models.MessageRole.AI,
            content=ai_text,
            meta_data=json.dumps(processed_summary)
        )
        db.add(ai_msg)
        db.commit()
        db.refresh(ai_msg)
        
        return schemas.SendMessageResponse(
            user_message=schemas.ChatMessage.from_orm(user_msg),
            ai_message=schemas.ChatMessage.from_orm(ai_msg),
            processed_data=processed_summary
        )

chat_service = ChatService()
