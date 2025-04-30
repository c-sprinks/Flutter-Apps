import requests
from flask import current_app
import json

class OllamaService:
    @staticmethod
    def generate_response(prompt):
        """Generate a response from Ollama"""
        try:
            url = f"{current_app.config['OLLAMA_URL']}/api/generate"
            
            payload = {
                "model": current_app.config['OLLAMA_MODEL'],
                "prompt": prompt,
                "stream": False
            }
            
            response = requests.post(url, json=payload)
            
            if response.status_code == 200:
                result = response.json()
                return result.get('response', 'No response from AI')
            else:
                return "Sorry, I'm having trouble connecting to the AI service."
        except Exception as e:
            print(f"Error calling Ollama: {str(e)}")
            return "Sorry, there was an error processing your request."