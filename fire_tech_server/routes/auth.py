from flask import Blueprint, request, jsonify
from services.auth_service import AuthService
from utils.security import verify_token

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    """Login route"""
    data = request.get_json()
    
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Missing username or password'}), 400
    
    result = AuthService.login(data['username'], data['password'])
    
    if not result:
        return jsonify({'error': 'Invalid username or password'}), 401
    
    return jsonify(result), 200

@auth_bp.route('/logout', methods=['POST'])
def logout():
    """Logout route"""
    # In a stateless JWT system, the client simply discards the token
    # No server-side action needed for basic implementation
    return jsonify({'message': 'Logged out successfully'}), 200

@auth_bp.route('/verify-token', methods=['GET'])
def verify():
    """Verify token route"""
    auth_header = request.headers.get('Authorization')
    
    if not auth_header or not auth_header.startswith('Bearer '):
        return jsonify({'error': 'Invalid token'}), 401
    
    token = auth_header.split(' ')[1]
    user_id = verify_token(token)
    
    if not user_id:
        return jsonify({'error': 'Invalid or expired token'}), 401
    
    user = AuthService.get_user_by_id(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify({'valid': True, 'user_id': user_id}), 200