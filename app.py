# app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from tanushree!"

# Health check endpoint
@app.route('/health')
def health_check():
    return "OK", 200  # Return HTTP 200 with OK message

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
