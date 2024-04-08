#!/bin/bash

# Set working directory within the script
cd /etc/nginx/certs

# --- Root CA certificate generation ---
openssl genrsa -out Root_CA.key 2048
openssl req -x509 -new -nodes -key Root_CA.key -sha256 -days 1024 -out Root_CA.pem -subj "/C=US/ST=Massachusetts/L=Boston/CN=EliJun"

# --- Server certificate generation ---
openssl genrsa -out _wildcard.quantumworkspace.dev+3-key.pem 4096
openssl req -new -key _wildcard.quantumworkspace.dev+3-key.pem -out _wildcard.quantumworkspace.dev+3.csr -subj "/CN=*.quantumworkspace.dev" -config <( \
cat <<-EOF \
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
CN = *.quantumworkspace.dev 

[SAN]
subjectAltName = DNS:*.quantumworkspace.dev, DNS:localhost, IP:127.0.0.1, IP:::1
EOF
)
openssl x509 -req -days 365 -in _wildcard.quantumworkspace.dev+3.csr -CA Root_CA.pem -CAkey Root_CA.key -CAcreateserial -out _wildcard.quantumworkspace.dev+3.pem -sha256

# --- DH parameters generation ---
openssl dhparam -out dhparam.pem 4096

# --- Root CA certificate conversion (PEM -> DER) ---
openssl x509 -in Root_CA.pem -out Root_CA.crt -outform DER 
