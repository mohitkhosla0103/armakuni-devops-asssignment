from flask import Flask, request
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)

@app.route("/")
def hello():
    app.logger.info(f"Request to / from {request.remote_addr}")
    return "Hello World"

@app.route("/healthz")
def health():
    app.logger.info(f"Health check from {request.remote_addr}")
    return {"status": "ok"}, 200

if __name__ == "__main__":
    # Run on 0.0.0.0 so it's accessible in Docker, port 3000
    app.run(host="0.0.0.0", port=3000)
