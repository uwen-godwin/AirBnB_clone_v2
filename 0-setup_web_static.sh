#!/usr/bin/env bash
# setup webserver for deployment of webstatic
DIR_DATA="/data"
DIR_TEST="$DIR_DATA/web_static/releases/test"
DIR_SHARED="$DIR_DATA/web_static/shared"
DIR_CUR="$DIR_DATA/web_static/current"
USER_CONF="ubuntu"
NGINX_CONF="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

# upgrase the system
apt-get update

# install nginx 
apt-get -y install nginx

# mkdir for test
mkdir -p $DIR_TEST

# mkdir for shared 
mkdir -p $DIR_SHARED

# create fake html file
if ! [[ -s "$DIR_TEST/index.html" ]]; then
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

# symbolic link  
ln -s -f $DIR_TEST $DIR_CUR

# chown 
chown -R $USER_CONF:$USER_CONF $DIR_DATA

# update nginx 
cat << EOT > "$NGINX_CONF/default"
server {
    
    listen 80 default_server;
    listen [::]:80 default_server;

    location /hbnb_static/ {
        alias "$DIR_CUR/";
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

if ! [[ -h "$NGINX_ENABLED/default" ]]; then
    ln -s "$NGINX_CONF/default" "$NGINX_ENABLED"
fi

if  nginx -t; then
    service nginx restart 
    exit 0
fi 
exit 1
