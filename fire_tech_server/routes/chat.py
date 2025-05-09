from flask import Blueprint, request, jsonify, current_app, send_from_directory
import os
from services.chat_service import ChatService
from utils.security import verify_token
import mimetypes

chat_bp = Blueprint('chat', __name__)

def get_user_id_from_token(request):
    """Extract and verify user ID from token"""
    auth_header = request.headers.get('Authorization')
    
    if not auth_header or not auth_header.startswith('Bearer '):
        return None
    
    token = auth_header.split(' ')[1]
    return verify_token(token)

@chat_bp.route('/chat', methods=['POST'])
def send_message():
    """Send a text message"""
    user_id = get_user_id_from_token(request)
    
    if not user_id:
        return jsonify({'error': 'Invalid or expired token'}), 401
    
    data = request.get_json()
    
    if not data or not data.get('message'):
        return jsonify({'error': 'No message provided'}), 400
    
    result = ChatService.process_message(user_id, data['message'])
    
    return jsonify({'response': result['text'], 'id': result['id']}), 200

@chat_bp.route('/chat/media', methods=['POST'])
def send_media():
    """Send a message with media"""
    user_id = get_user_id_from_token(request)
    
    if not user_id:
        return jsonify({'error': 'Invalid or expired token'}), 401
    
    # Check if file was uploaded
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    message = request.form.get('message', '')
    
    # Determine media type from mimetype
    mime_type = file.content_type
    if mime_type.startswith('image/'):
        media_type = 'image'
    elif mime_type.startswith('video/'):
        media_type = 'video'
    elif mime_type.startswith('audio/'):
        media_type = 'audio'
    else:
        media_type = 'document'
    
    result = ChatService.process_media_message(user_id, message, file, media_type)
    
    return jsonify({'response': result['text'], 'id': result['id']}), 200

@chat_bp.route('/chat/history', methods=['GET'])
def get_history():
    """Get chat history"""
    user_id = get_user_id_from_token(request)
    
    if not user_id:
        return jsonify({'error': 'Invalid or expired token'}), 401
    
    history = ChatService.get_chat_history(user_id)
    
    return jsonify(history), 200

@chat_bp.route('/uploads/<path:filename>', methods=['GET'])
def get_upload(filename):
    """Serve an uploaded file"""
    return send_from_directory(
        os.path.join(current_app.root_path, current_app.config['UPLOAD_FOLDER']),
        filename
    )