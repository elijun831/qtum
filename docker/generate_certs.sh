#!/bin/bash

# Set working directory within the script
cd /etc/nginx/certs

# Certificate Generation Logic
openssl genrsa -out _wildcard.quantumworkspace.dev+3-key.pem 4096 && \
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
) && \
openssl x509 -req -days 365 -in _wildcard.quantumworkspace.dev+3.csr -signkey _wildcard.quantumworkspace.dev+3-key.pem -out _wildcard.quantumworkspace.dev+3.pem && \
openssl dhparam -out dhparam.pem 4096
