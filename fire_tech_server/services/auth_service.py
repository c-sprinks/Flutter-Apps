from models import db, User
from utils.security import hash_password, verify_password, generate_token

class AuthService:
    @staticmethod
    def register_user(username, password):
        """Register a new user"""
        # Check if username already exists
        if User.query.filter_by(username=username).first():
            return None
        
        # Create new user
        user = User(
            username=username,
            password_hash=hash_password(password)
        )
        
        db.session.add(user)
        db.session.commit()
        
        return user
    
    @staticmethod
    def login(username, password):
        """Login a user and return token if successful"""
        user = User.query.filter_by(username=username).first()
        
        if not user:
            return None
        
        if not verify_password(user.password_hash, password):
            return None
        
        # Generate access token
        token = generate_token(user.id)
        
        return {
            'id': str(user.id),
            'username': user.username,
            'token': token
        }
    
    @staticmethod
    def get_user_by_id(user_id):
        """Get a user by their ID"""
        return User.query.get(user_id)