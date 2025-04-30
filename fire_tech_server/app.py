from flask import Flask
from flask_cors import CORS
from models import db
from routes import init_app
from config import Config
import os

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize CORS
    CORS(app)
    
    # Initialize database
    db.init_app(app)
    
    # Initialize routes
    init_app(app)
    
    # Initialize upload directories
    config_class.init_app(app)
    
    return app

app = create_app()

@app.before_first_request
def create_tables():
    db.create_all()

@app.route('/')
def index():
    return 'Fire Tech Agent Server is running'

# Admin route to create a test user
@app.route('/setup/<username>/<password>')
def setup(username, password):
    from services.auth_service import AuthService
    
    # Create a test user
    user = AuthService.register_user(username, password)
    
    if user:
        return f'User {username} created successfully'
    else:
        return f'User {username} already exists'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)