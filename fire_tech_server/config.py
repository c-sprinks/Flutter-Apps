import os
from datetime import timedelta

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URI', 'sqlite:///fire_tech.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'jwt-secret-key')
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=1)
    
    # Ollama settings
    OLLAMA_URL = os.environ.get('OLLAMA_URL', 'http://localhost:11434')
    OLLAMA_MODEL = os.environ.get('OLLAMA_MODEL', 'llama2')
    
    # Upload settings
    UPLOAD_FOLDER = 'uploads'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max upload size
    
    # Create upload directories if they don't exist
    @staticmethod
    def init_app(app):
        upload_dirs = [
            os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], 'images'),
            os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], 'videos'),
            os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], 'audio'),
            os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], 'documents')
        ]
        
        for directory in upload_dirs:
            if not os.path.exists(directory):
                os.makedirs(directory)