#!/bin/bash
# Deploy backend fix to EPYC server

SERVER_USER="agoud"
SERVER_IP="100.79.130.75"
SERVER_DIR="aurtsy-backend" # Based on your screenshot

echo "🚀 Deploying backend fix to $SERVER_USER@$SERVER_IP..."

# 1. Copy the fixed main.py
echo "📦 Copying main.py..."
scp /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/backend/main.py $SERVER_USER@$SERVER_IP:~/$SERVER_DIR/

# 2. Restart the backend
echo "🔄 Restarting backend service..."
ssh $SERVER_USER@$SERVER_IP "cd ~/$SERVER_DIR && pkill -f 'uvicorn main:app' && nohup uvicorn main:app --host 0.0.0.0 --port 8090 > backend.log 2>&1 &"

echo "✅ Deployment complete! Try saving a meal in the iOS app now."
