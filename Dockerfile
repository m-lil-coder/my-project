# Use the official Python image from Docker Hub
FROM python:3.10-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy requirements.txt and app.py first
COPY requirements.txt /app/
COPY app.py /app/

# Install the required Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 (which your app uses)
EXPOSE 80

# Set the default command to run the app
CMD ["python", "app.py"]
