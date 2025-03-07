# Use a simple web server to serve static files (e.g., nginx or httpd)
FROM nginx:alpine

# Copy frontend files into the container
COPY index.html /usr/share/nginx/html/index.html
COPY script.js /usr/share/nginx/html/script.js

# Expose the default HTTP port
EXPOSE 80
