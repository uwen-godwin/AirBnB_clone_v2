#!/usr/bin/env bash
# script that sets up your web servers for the deployment of web_static

# Updating all packages
sudo apt-get -y update
sudo apt-get -y install nginx

# Create directories and symbolic link
sudo mkdir -p /data/web_static/releases/test /data/web_static/shared
echo "Holberton School" > /data/web_static/releases/test/index.html
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Change permissions
sudo chown -hR ubuntu:ubuntu /data

printf %s "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    add_header X-Served-By $HOSTNAME;
    root   /var/www/html;
    index  index.html index.htm;
    location /hbnb_static {
        alias /data/web_static/current;
        index index.html index.htm;
    }
    location /redirect_me {
        return 301 http://cuberule.com/;
    }
    error_page 404 /404.html;
    location /404 {
        root /var/www/html;
	internal;
    }
}" > /etc/nginx/sites-available/default

# Restart Nginx
sudo service nginx restart
