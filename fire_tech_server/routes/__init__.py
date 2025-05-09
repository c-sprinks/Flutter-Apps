from .auth import auth_bp
from .chat import chat_bp

def init_app(app):
    """Initialize routes"""
    app.register_blueprint(auth_bp, url_prefix='/api')
    app.register_blueprint(chat_bp, url_prefix='/api')