import os
import uuid
from datetime import datetime
from werkzeug.utils import secure_filename
from flask import current_app
from models import db, Message
from .ollama_service import OllamaService

class ChatService:
    @staticmethod
    def save_message(user_id, text, is_user=True, media_url=None, media_type=None):
        """Save a message to the database"""
        message = Message(
            user_id=user_id,
            text=text,
            is_user=is_user,
            media_url=media_url,
            media_type=media_type
        )
        
        db.session.add(message)
        db.session.commit()
        
        return message
    
    @staticmethod
    def get_chat_history(user_id, limit=50):
        """Get chat history for a user"""
        messages = Message.query.filter_by(user_id=user_id).order_by(Message.timestamp.asc()).limit(limit).all()
        return [message.to_dict() for message in messages]
    
    @staticmethod
    def process_message(user_id, message_text):
        """Process a user message and generate a response"""
        # Save user message
        user_message = ChatService.save_message(user_id, message_text)
        
        # Get response from Ollama
        ai_response = OllamaService.generate_response(message_text)
        
        # Save AI response
        ai_message = ChatService.save_message(user_id, ai_response, is_user=False)
        
        return {
            'id': str(ai_message.id),
            'text': ai_message.text,
            'isUser': False,
            'timestamp': ai_message.timestamp.isoformat()
        }
    
    @staticmethod
    def save_file(file, media_type):
        """Save an uploaded file and return the path"""
        if file:
            filename = secure_filename(file.filename)
            unique_filename = f"{uuid.uuid4()}_{filename}"
            
            # Determine the subdirectory based on media type
            subdirectory = media_type + 's'  # e.g., 'image' -> 'images'
            
            file_path = os.path.join(
                current_app.root_path,
                current_app.config['UPLOAD_FOLDER'],
                subdirectory,
                unique_filename
            )
            
            # Save the file
            file.save(file_path)
            
            # Return the path relative to the upload folder
            return os.path.join(subdirectory, unique_filename)
        
        return None
    
    @staticmethod
    def process_media_message(user_id, message_text, file, media_type):
        """Process a message with media attachment"""
        # Save the file
        media_url = ChatService.save_file(file, media_type)
        
        # Default text if none provided
        if not message_text:
            message_text = f"Sent {media_type}"
        
        # Save user message with media
        user_message = ChatService.save_message(
            user_id,
            message_text,
            is_user=True,
            media_url=media_url,
            media_type=media_type
        )
        
        # For AI response, include context about the media
        prompt = f"The user sent a {media_type} and said: {message_text}"
        ai_response = OllamaService.generate_response(prompt)
        
        # Save AI response
        ai_message = ChatService.save_message(user_id, ai_response, is_user=False)
        
        return {
            'id': str(ai_message.id),
            'text': ai_message.text,
            'isUser': False,
            'timestamp': ai_message.timestamp.isoformat()
        }