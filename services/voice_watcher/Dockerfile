FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy watcher script
COPY watcher.py .

# Create data directories including processed folder
RUN mkdir -p /app/data/input /app/data/output /app/data/input/processed

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV INPUT_DIR=/app/data/input
ENV OUTPUT_DIR=/app/data/output
ENV PROCESSED_DIR=/app/data/input/processed

# Run watcher
CMD ["python", "watcher.py"]

