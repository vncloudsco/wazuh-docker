#!/bin/sh

set -e

# Generating certificates.
if [ ! -d /etc/nginx/conf.d/ssl ]; then
  echo "Generating SSL certificates"
  mkdir -p /etc/nginx/conf.d/ssl/certs /etc/nginx/conf.d/ssl/private
  openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout /etc/nginx/conf.d/ssl/private/kibana-access.key -out /etc/nginx/conf.d/ssl/certs/kibana-access.pem >/dev/null
else
  echo "SSL certificates already present"
fi

# Configuring default credentiales.
if [ ! -f /etc/nginx/conf.d/kibana.htpasswd ]; then
  echo "Setting Nginx credentials"
  echo bar|htpasswd -i -c /etc/nginx/conf.d/kibana.htpasswd foo >/dev/null
else
  echo "Kibana credentials already configured"
fi


if [ "x${NGINX_PORT}" = "x" ]; then
  NGINX_PORT=443
fi

if [ "x${KIBANA_HOST}" = "x" ]; then
  KIBANA_HOST="kibana:5601"
fi

echo "Configuring NGINX"
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    return 301 https://\$host:${NGINX_PORT}\$request_uri;
}

server {
    listen ${NGINX_PORT} default_server;
    listen [::]:${NGINX_PORT};
   
    ssl on;
    ssl_certificate /etc/nginx/conf.d/ssl/certs/kibana-access.pem;
    ssl_certificate_key /etc/nginx/conf.d/ssl/private/kibana-access.key;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
 
    ssl_protocols TLSv1.2;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security max-age=15768000;

    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/conf.d/kibana.htpasswd;
        proxy_pass http://${KIBANA_HOST}/;
    }
}
EOF

nginx -g 'daemon off;'
