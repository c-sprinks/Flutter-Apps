from . import db
from datetime import datetime

class Message(db.Model):
    __tablename__ = 'messages'
    
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.Text)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    is_user = db.Column(db.Boolean, default=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    media_url = db.Column(db.String(256), nullable=True)
    media_type = db.Column(db.String(32), nullable=True)
    
    def to_dict(self):
        return {
            'id': str(self.id),
            'text': self.text,
            'isUser': self.is_user,
            'timestamp': self.timestamp.isoformat(),
            'mediaUrl': self.media_url,
            'mediaType': self.media_type
        }