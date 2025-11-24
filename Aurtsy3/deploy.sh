#!/bin/bash

# --- CONFIGURATION ---
# EDIT THESE VALUES TO MATCH YOUR SETUP
BACKEND_HOST="100.79.130.75"  # Found via tailscale status (epycserver-1)
BACKEND_USER="agoud"          # User specified: 'agoud' (Working)
AI_HOST="100.80.85.59"        # pop-os
AI_USER="anilgoud"           # Confirmed correct username
# ---------------------

echo "Deploying Aurtsy System..."

# 1. Deploy Backend to Epyc Server
echo "Deploying Backend to $BACKEND_HOST..."
# Create directory
ssh ${BACKEND_USER}@${BACKEND_HOST} "mkdir -p ~/aurtsy-backend"
# Copy files
scp -r backend/* ${BACKEND_USER}@${BACKEND_HOST}:~/aurtsy-backend/
# Check if uv is installed, install if needed
echo "Checking dependencies..."
ssh -t ${BACKEND_USER}@${BACKEND_HOST} "command -v uv || curl -LsSf https://astral.sh/uv/install.sh | sh"

# Setup Database using Docker (More robust, avoids system conflicts)
echo "Starting PostgreSQL in Docker..."
# Stop existing container if any, then run new one on port 5444 to avoid conflicts
ssh ${BACKEND_USER}@${BACKEND_HOST} "sudo docker rm -f aurtsy-db || true"
ssh ${BACKEND_USER}@${BACKEND_HOST} "sudo docker run -d --name aurtsy-db -p 5444:5432 -e POSTGRES_USER=aurtsy_user -e POSTGRES_PASSWORD=aurtsy_pass -e POSTGRES_DB=aurtsy_db --restart unless-stopped postgres:15"

# Wait for DB to start
echo "Waiting for Database to initialize..."
sleep 5

# Run server with DATABASE_URL pointing to Docker (localhost:5444)
ssh ${BACKEND_USER}@${BACKEND_HOST} "cd ~/aurtsy-backend && export PATH=\"\$HOME/.local/bin:\$PATH\" && sudo env \"PATH=\$PATH\" ~/.local/bin/uv pip install --system -r requirements.txt"
# Kill any existing backend process
ssh ${BACKEND_USER}@${BACKEND_HOST} "pkill -f 'uvicorn main:app' || true"
# Start the FastAPI backend after dependencies are installed
ssh ${BACKEND_USER}@${BACKEND_HOST} "cd ~/aurtsy-backend && export DATABASE_URL='postgresql://aurtsy_user:aurtsy_pass@localhost:5444/aurtsy_db' && nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8090 > backend.log 2>&1 &"

echo "Backend running on $BACKEND_HOST:8090"
# 2. Deploy AI Worker to GPU Machine
echo "Deploying AI Worker to $AI_HOST..."
# Create directory and copy files
ssh ${AI_USER}@${AI_HOST} "mkdir -p ~/aurtsy-ai-worker"
scp -r ai-worker/* ${AI_USER}@${AI_HOST}:~/aurtsy-ai-worker/
# Set up a virtual environment and install dependencies
ssh ${AI_USER}@${AI_HOST} "cd ~/aurtsy-ai-worker && python3 -m venv .venv && source .venv/bin/activate && ~/.local/bin/uv pip install -r requirements.txt"
# Kill any existing worker process
ssh ${AI_USER}@${AI_HOST} "pkill -f 'uvicorn main:app' || true"
# Start worker in background using the virtual environment
ssh ${AI_USER}@${AI_HOST} "cd ~/aurtsy-ai-worker && source .venv/bin/activate && nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8001 > worker.log 2>&1 &"

echo "Deployment Complete!"
echo "Backend running on $BACKEND_HOST:8000"
echo "AI Worker running on $AI_HOST:8001"
