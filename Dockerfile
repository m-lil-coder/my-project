# Use the official Nginx image from the Docker Hub
FROM nginx:latest

# Set the working directory inside the container (optional)
WORKDIR /usr/share/nginx/html

# Copy the custom HTML file into the Nginx container
COPY index.html /usr/share/nginx/html/index.html

# Copy the custom nginx.conf file into the container
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for the container
EXPOSE 80

# No need to specify CMD or ENTRYPOINT as the Nginx base image already has a default one
