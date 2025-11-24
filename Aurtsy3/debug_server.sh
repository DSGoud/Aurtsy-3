#!/bin/bash
# Debug script to check DB status and run backend in foreground

SERVER_USER="agoud"
SERVER_IP="100.79.130.75"
DB_URL="postgresql://aurtsy_user:aurtsy_pass@localhost:5444/aurtsy_db"

echo "🔍 Debugging Server on $SERVER_USER@$SERVER_IP..."

ssh $SERVER_USER@$SERVER_IP "
    echo '--- 1. Checking Docker Container (aurtsy-db) ---'
    if sudo docker ps | grep -q aurtsy-db; then
        echo '✅ Database container is running.'
    else
        echo '❌ Database container is NOT running!'
        echo 'Attempting to start it...'
        sudo docker start aurtsy-db || echo 'Failed to start container.'
    fi

    echo '--- 2. Trying to start backend (foreground) ---'
    cd ~/aurtsy-backend
    # Kill any existing instance first
    pkill -f 'uvicorn main:app' || true
    
    export DATABASE_URL='$DB_URL'
    echo 'Using DATABASE_URL: $DB_URL'
    
    # Run in foreground to see errors
    uvicorn main:app --host 0.0.0.0 --port 8090
"
