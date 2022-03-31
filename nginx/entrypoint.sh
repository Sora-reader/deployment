#!/bin/sh

generate_certificate () {
  certbot --nginx --non-interactive --agree-tos -d $1 --email $2
}

# Generate certificates if they don't exist
[ -d "/etc/letsencrypt/live/$BACKEND_DOMAIN" ] || generate_certificate "$BACKEND_DOMAIN" "$CERTBOT_EMAIL"
[ -d "/etc/letsencrypt/live/$FRONTEND_DOMAIN" ] || generate_certificate "$FRONTEND_DOMAIN" "$CERTBOT_EMAIL"

./docker-entrypoint.sh nginx -g 'daemon off;'
