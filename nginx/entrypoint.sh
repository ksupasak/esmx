#!/bin/sh
set -e

SSL_CERT_PATH="${SSL_CERT_PATH:-/etc/nginx/ssl/server.crt}"
SSL_KEY_PATH="${SSL_KEY_PATH:-/etc/nginx/ssl/server.key}"

# Generate self-signed cert if not provided
if [ ! -f "$SSL_CERT_PATH" ] || [ ! -f "$SSL_KEY_PATH" ]; then
    echo "SSL certificate not found. Generating self-signed certificate..."
    mkdir -p "$(dirname "$SSL_CERT_PATH")" "$(dirname "$SSL_KEY_PATH")"
    apk add --no-cache openssl > /dev/null 2>&1
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$SSL_KEY_PATH" \
        -out "$SSL_CERT_PATH" \
        -subj "/C=TH/ST=Bangkok/L=Bangkok/O=Dev/OU=Dev/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
    echo "Self-signed certificate generated."
fi

# Run the default nginx entrypoint (handles envsubst templates)
exec /docker-entrypoint.sh "$@"
