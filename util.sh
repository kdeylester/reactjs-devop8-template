#!/bin/bash

DOMAIN="$1"
PORT="$2"

# Show usage guide but do not block execution unless variables are actually missing
usage() {
    echo "Usage : $0 <domain> <port>"
}

if [ -z "$DOMAIN" ]; then
    echo "Error: No domain provided."
    usage
    exit 1
fi

if [ -z "$PORT" ]; then
    echo "Error: No port provided."
    usage
    exit 1
fi




# Create function for config domain name
create_domain(){
    local DOMAIN="$1"
    local PORT="$2"
    local FILE="${DOMAIN}.conf"


    cat << EOF > "$FILE"
server {
    server_name ${DOMAIN}.kdey.me;

    location / {
        proxy_pass http://localhost:${PORT}/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_connect_timeout 60s;
        proxy_send_timeout 600s;
        proxy_read_timeout 600s;
    }
}
EOF

    # Validate Nginx syntax right after creating the file
    if nginx -t 2>/dev/null; then
        echo "Nginx configuration test passed."
        ln -s $(pwd)"/${FILE}" /etc/nginx/conf.d/
        systemctl reload nginx
        echo "Domain ${DOMAIN}.kdey.me configured successfully and Nginx reloaded"
        echo "Now Config Domain with Https with certbot"
        certbot --nginx -d ${DOMAIN}.kdey.me
    else
        echo "Nginx configuration test failed. Please check the configuration."
        exit 1
    fi
}




# Check if the domain is already configured
if nginx -T 2>/dev/null | grep -qi "server_name.*${DOMAIN}\.kdey\.me"; then
    echo "TRUE: The domain: ${DOMAIN}.kdey.me is already configured."
else
    echo "Configuring the domain: ${DOMAIN}..."
    # Crucial: Pass the arguments into the function call
    create_domain "$DOMAIN" "$PORT"
fi