from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel
import psycopg2
import requests
from typing import Optional

app = FastAPI()

# PostgreSQL connection configuration
DB_CONFIG = {
    "dbname": "ollama_conversations",
    "user": "ollama_user",
    "password": "MRKSophie0320$",  # Replace with your actual password
    "host": "localhost",
    "port": "5432"
}

# Ollama API endpoint (assumes Ollama is running locally)
OLLAMA_API_URL = "http://localhost:11434/api/generate"

# Pydantic model for incoming chat requests
class ChatMessage(BaseModel):
    message: str

# Function to verify token (placeholder, replace with actual auth logic)
def verify_token(token: str) -> bool:
    # For testing, accept the test token from your AuthService
    if token == "test-token-123":
        return True
    # TODO: Implement actual token verification (e.g., JWT decoding)
    return False

# Function to save a message to the database
def save_message(user_id: str, message: str, sender: str):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO conversations (user_id, message_text, sender) VALUES (%s, %s, %s) RETURNING id",
            (user_id, message, sender)
        )
        message_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return message_id
    except Exception as e:
        raise Exception(f"Database error: {str(e)}")

# Function to get conversation history
def get_conversation_history(user_id: str):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute(
            "SELECT id, user_id, message_text, sender, timestamp FROM conversations WHERE user_id = %s ORDER BY timestamp ASC",
            (user_id,)
        )
        history = cur.fetchall()
        cur.close()
        conn.close()
        return [
            {
                "id": str(row[0]),
                "text": row[2],
                "isUser": row[3] == "user",
                "timestamp": row[4].isoformat(),
                "mediaUrl": None,  # Not supported yet
                "mediaType": None  # Not supported yet
            }
            for row in history
        ]
    except Exception as e:
        raise Exception(f"Database error: {str(e)}")

# API endpoint to send a text message
@app.post("/chat")
async def send_message(message: ChatMessage, authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid or missing token")
    
    token = authorization.split("Bearer ")[1]
    if not verify_token(token):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # For testing, assume user_id is "1" (matches your test user)
    user_id = "1"  # TODO: Extract user_id from token in production
    
    try:
        # Save user message
        message_id = save_message(user_id, message.message, "user")

        # Send message to Ollama
        response = requests.post(
            OLLAMA_API_URL,
            json={"model": "llama3", "prompt": message.message}  # Adjust model as needed
        )
        response.raise_for_status()
        ai_response = response.json().get("response", "No response from AI")

        # Save AI response
        ai_message_id = save_message(user_id, ai_response, "ai")

        return {
            "id": str(ai_message_id),
            "response": ai_response,
            "isUser": False,
            "timestamp": None  # Flutter will set this client-side
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# API endpoint to get conversation history
@app.get("/chat/history")
async def get_history(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid or missing token")
    
    token = authorization.split("Bearer ")[1]
    if not verify_token(token):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # For testing, assume user_id is "1"
    user_id = "1"  # TODO: Extract user_id from token in production
    
    try:
        history = get_conversation_history(user_id)
        return history
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))