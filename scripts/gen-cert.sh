#!/bin/bash
# Generate internal CA + server certificate with proper SANs
set -e

DOMAIN=${DOMAIN:-chat.yourdomain.com}
SERVER_IP=${SERVER_IP:-192.168.1.100}
CERT_DIR="./nginx/certs"

mkdir -p "$CERT_DIR" /tmp/ssl_gen
cd /tmp/ssl_gen

echo "Generating CA..."
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
    -subj "/CN=Internal CA/O=Self-Hosted/C=IR"

echo "Generating server key..."
openssl genrsa -out server.key 2048

cat > san.cnf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $DOMAIN

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
IP.1 = $SERVER_IP
EOF

openssl req -new -key server.key -out server.csr -config san.cnf
openssl x509 -req -days 3650 \
    -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server.crt -extfile san.cnf -extensions v3_req

cat server.crt ca.crt > "$OLDPWD/$CERT_DIR/cert.pem"
cp server.key "$OLDPWD/$CERT_DIR/key.pem"
cp ca.crt "$OLDPWD/$CERT_DIR/ca.crt"

# Generate DH params
openssl dhparam -out "$OLDPWD/$CERT_DIR/dhparam.pem" 2048

echo "Done! CA cert for device distribution: $CERT_DIR/ca.crt"
