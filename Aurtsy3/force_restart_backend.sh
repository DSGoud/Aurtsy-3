#!/bin/bash
# Force restart backend on EPYC server with ROBUST settings

SERVER_USER="agoud"
SERVER_IP="100.79.130.75"
SERVER_DIR="aurtsy-backend"
DB_URL="postgresql://aurtsy_user:aurtsy_pass@localhost:5444/aurtsy_db"

echo "🔄 Force restarting backend on $SERVER_USER@$SERVER_IP..."

ssh $SERVER_USER@$SERVER_IP "
    export PATH=\$HOME/.local/bin:\$PATH
    cd ~/$SERVER_DIR/backend
    
    echo 'Stopping old process...'
    pkill -f 'uvicorn app.main:app' || true
    sleep 2
    
    echo 'Starting new process...'
    export DATABASE_URL='$DB_URL'
    
    # Use nohup and python3 -m uvicorn
    nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8090 > backend.log 2>&1 &
"

echo "✅ Restart command sent. Waiting 5 seconds..."
sleep 5
./check_backend.sh
