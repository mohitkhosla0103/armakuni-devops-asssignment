# Base Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /appserviceb

# Copy files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Expose desired port
EXPOSE 3000

# Run the app on port 3000
CMD ["python", "app.py"]
