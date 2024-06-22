#!/bin/sh
set -e

CERT_DIR="/etc/letsencrypt/live/${SERVER_NAME}"

ROOT_CRT="${CERT_DIR}/rootCA.pem"  # Root certificate (import into browsers)
ROOT_KEY="${CERT_DIR}/rootCA-key.pem"  # Root private key

SERVER_CRT="${CERT_DIR}/fullchain.pem"  # Server certificate
SERVER_KEY="${CERT_DIR}/privkey.pem"  # Server private key
SERVER_CSR="${CERT_DIR}/cert.csr"  # Certificate Signing Request for the server

if [ "${LOCALHOST}" = "openssl" ]; then  # TODO: needs work, root CA not recognised
	echo "Using OpenSSL for certificates"
	# Check if certificates exist and generate if they don't
	if [ ! -f "${ROOT_CRT}" ] || [ ! -f "${ROOT_KEY}" ] || [ ! -f "${SERVER_CRT}" ] || [ ! -f "${SERVER_KEY}" ]; then
		echo "Certificates not found. Generating..."
		# Create your own Certificate Authority
		openssl genrsa -out "${ROOT_KEY}" 2048
		# Create and self sign the Root Certificate
		openssl req -x509 -new -nodes -key "${ROOT_KEY}" -sha256 -days 1024 \
			-out "${ROOT_CRT}" -subj "/CN=OpenSSL root CA for localhost" \
			-addext "basicConstraints=critical,CA:TRUE" \
			-addext "keyUsage=critical,keyCertSign,cRLSign"
		# Generate a private key
		openssl genrsa -out "${SERVER_KEY}" 2048
		# Create a certificate signing request (CSR)
		openssl req -new -key "${SERVER_KEY}" -out "${SERVER_CSR}" -subj "/CN=${SERVER_NAME}"
		# Create the certificate for localhost using your CA
		openssl x509 -req -in "${SERVER_CSR}" -CA "${ROOT_CRT}" -CAkey "${ROOT_KEY}" -CAcreateserial -out "${SERVER_CRT}" -days 90 -sha256
		echo "Certificates generated successfully."
	else
		echo "Certificates already exist. Skipping generation."
	fi
elif [ "${LOCALHOST}" = "mkcert" ]; then
	echo "Using mkcert for certificates"
	export CAROOT="${CERT_DIR}"  # mkcert
	# Install the local CA in the system trust store
    mkcert -install
	# Check if certificates exist and generate if they don't
	if [ ! -f "${SERVER_CRT}" ] || [ ! -f "${SERVER_KEY}" ]; then
		echo "Certificates not found. Generating..."
		# Generate certificates for the server
        mkcert -cert-file "${SERVER_CRT}" -key-file "${SERVER_KEY}" "${SERVER_NAME}"
		echo "Certificates generated successfully."
	else
		echo "Certificates already exist. Skipping generation."
	fi
else
	echo "Using Certbot for certificates"
	# $ certbot --help dns-cloudflare
	if [ "${STAGING}" = "true" ]; then
		echo "\$STAGING environment variable is ${STAGING}"
		certbot certonly \
			--config=/certbot_cli \
			--test-cert
	else
		echo "\$STAGING environment variable is not available, using production"
		certbot certonly \
			--config=/certbot_cli
	fi
fi
