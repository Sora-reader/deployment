#!/bin/sh

generate_certificate () {
  certbot --nginx --non-interactive --agree-tos -d $1 --email $2
}

# Generate certificates if they don't exist
[ -d '/etc/letsencrypt/live/backend.sora-reader.app' ] || generate_certificate backend.sora-reader.app 1337kwiz@gmail.com
[ -d '/etc/letsencrypt/live/sora-reader.app' ] || generate_certificate sora-reader.app 1337kwiz@gmail.com

nginx -g 'daemon off;'
