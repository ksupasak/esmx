#!/bin/bash
# Generate self-signed SSL certificate

CERT_DIR="$(dirname "$0")/ssl"
mkdir -p "$CERT_DIR"

if [ -f "$CERT_DIR/server.crt" ] && [ -f "$CERT_DIR/server.key" ]; then
    echo "SSL certificates already exist in $CERT_DIR"
    echo "Delete them first if you want to regenerate."
    exit 0
fi

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$CERT_DIR/server.key" \
    -out "$CERT_DIR/server.crt" \
    -subj "/C=TH/ST=Bangkok/L=Bangkok/O=Dev/OU=Dev/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

echo "Self-signed SSL certificate generated in $CERT_DIR"
