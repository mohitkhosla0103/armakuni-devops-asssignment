from flask import Flask, request
import logging
import requests  # for HTTP calls to Service B

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

@app.route("/serviceb")
def call_serviceb():
    app.logger.info(f"Calling Service B from {request.remote_addr}")
    try:
        # Replace 'serviceb.local' with the private DNS name of Service B in ECS
        serviceb_url = "http://dev-private-service.dev-cluster.terraform.local:3000/healthz" 
        response = requests.get(serviceb_url)
        response.raise_for_status()  # raise error for non-2xx responses
        data = response.json()
        return {"serviceB_response": data}, response.status_code
    except requests.exceptions.RequestException as e:
        app.logger.error(f"Error calling Service B: {e}")
        return {"error": str(e)}, 500

if __name__ == "__main__":
    # Run on 0.0.0.0 so it's accessible in Docker, port 3000
    app.run(host="0.0.0.0", port=3000)
