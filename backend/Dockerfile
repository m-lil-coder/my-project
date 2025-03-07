# Use the official Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the backend application files into the container
COPY app.py /app/
COPY requirements.txt /app/

# Install the required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install curl
RUN apt-get update && apt-get install -y curl

# Expose the Flask default port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]
