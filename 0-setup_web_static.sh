#!/usr/bin/env bash

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    apt-get update
    apt-get -y install nginx
fi

# Create directories if they don't exist
DIR_DATA="/data"
DIR_STATIC="$DIR_DATA/web_static"
DIR_RELEASES="$DIR_STATIC/releases"
DIR_SHARED="$DIR_STATIC/shared"
DIR_TEST="$DIR_RELEASES/test"
DIR_CURRENT="$DIR_STATIC/current"

mkdir -p "$DIR_DATA" "$DIR_STATIC" "$DIR_RELEASES" "$DIR_SHARED" "$DIR_TEST"

# Create fake HTML file if it doesn't exist
if [ ! -f "$DIR_TEST/index.html" ]; then
    echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee "$DIR_TEST/index.html" >/dev/null
fi

# Create symbolic link (remove it if it already exists)
[ -L "$DIR_CURRENT" ] && rm "$DIR_CURRENT"
ln -s "$DIR_TEST" "$DIR_CURRENT"

# Give ownership to the ubuntu user and group recursively
chown -R ubuntu:ubuntu "$DIR_DATA"

# Update Nginx configuration
CONFIG_FILE="/etc/nginx/sites-available/default"
CONFIG_LINE="location /hbnb_static/ { alias $DIR_CURRENT/; }"

# Add or replace the configuration line
if grep -q "$CONFIG_LINE" "$CONFIG_FILE"; then
    sed -i "s|.*location /hbnb_static/.*|$CONFIG_LINE|" "$CONFIG_FILE"
else
    sed -i "/server {/ a $CONFIG_LINE" "$CONFIG_FILE"
fi

# Restart Nginx
service nginx restart

exit 0
