# Use the official Python image from Docker Hub
FROM python:3.10-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt /app/

# Install the required Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . /app/

# Expose port 81 (which you want to use)
EXPOSE 81

# Set the default command to run the app
CMD ["python", "app.py"]
