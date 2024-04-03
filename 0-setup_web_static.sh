#!/usr/bin/env bash
# setup webserver for deployment of webstatic

# Define directories and configurations
DIR_DATA="/data"
DIR_TEST="$DIR_DATA/web_static/releases/test"
DIR_SHARED="$DIR_DATA/web_static/shared"
DIR_CURRENT="$DIR_DATA/web_static/current"
USER_CONF="ubuntu"
NGINX_CONF="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
NGINX_DEFAULT="$NGINX_CONF/default"
NGINX_DEFAULT_ENABLED="$NGINX_ENABLED/default"

# Upgrade the system
apt-get update

# Install nginx 
apt-get -y install nginx

# Create directories
mkdir -p "$DIR_TEST" "$DIR_SHARED"

# Create fake html file if it doesn't exist
if ! [[ -e "$DIR_TEST/index.html" ]]; then
    cat << EOT > "$DIR_TEST/index.html"
<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>
EOT
fi

# Create symbolic link
ln -sf "$DIR_TEST" "$DIR_CURRENT"

# Change ownership
chown -R "$USER_CONF:$USER_CONF" "$DIR_DATA"

# Update nginx configuration
cat << EOT > "$NGINX_DEFAULT"
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location /hbnb_static/ {
        alias "$DIR_CURRENT/";
        autoindex off;
    }

    location / {
        root /var/www/html;
        index index.html;
    }

    location /redirect_me {
        return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4;
    }

    error_page 404 /404.html;

    location = /404.html{
        internal;
    }

    add_header X-Served-By $(hostname);
}
EOT

# Enable default site if not already enabled
if ! [[ -h "$NGINX_DEFAULT_ENABLED" ]]; then
    ln -s "$NGINX_DEFAULT" "$NGINX_ENABLED"
fi

# Check nginx configuration and restart nginx
if nginx -t; then
    service nginx restart 
    exit 0
fi 
exit 1
