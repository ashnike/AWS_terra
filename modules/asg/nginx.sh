#!/bin/bash

# Update package lists and install required packages
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install nginx -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Define NGINX configuration content
nginx_config="
upstream flask_app {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name example.com;  # Change this to your domain name

    location / {
        proxy_pass http://flask_app;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}"

# Replace the contents of the default NGINX configuration file with the custom configuration
echo "$nginx_config" | sudo tee /etc/nginx/sites-available/default > /dev/null

sudo systemctl restart nginx

sudo docker run -d -e S3_BUCKET_NAME="webserver-websapp" -e AWS_REGION="ap-south-1 " -p 8000:8000 ashniike/aws_s3_webapp:latest

