#!/bin/bash
# Setup HTTPS for local development

set -e

echo "🔐 Setting up HTTPS for FastAPI backend..."

# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -nodes \
  -out /tmp/cert.pem \
  -keyout /tmp/key.pem \
  -days 365 \
  -subj "/CN=100.79.130.75"

echo "✅ Certificate generated at /tmp/cert.pem and /tmp/key.pem"
echo ""
echo "📝 To run FastAPI with HTTPS, use:"
echo "uvicorn main:app --host 0.0.0.0 --port 8090 --ssl-keyfile /tmp/key.pem --ssl-certfile /tmp/cert.pem"
