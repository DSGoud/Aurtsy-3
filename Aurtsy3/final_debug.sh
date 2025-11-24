#!/bin/bash
# Final debug script to capture backend crash logs

SERVER_USER="agoud"
SERVER_IP="100.79.130.75"
DB_URL="postgresql://aurtsy_user:aurtsy_pass@localhost:5444/aurtsy_db"

echo "🔍 FINAL DEBUG on $SERVER_USER@$SERVER_IP..."

ssh $SERVER_USER@$SERVER_IP "
    # Ensure we have the right path
    export PATH=\$HOME/.local/bin:\$PATH
    cd ~/aurtsy-backend
    
    # Set the database URL
    export DATABASE_URL='$DB_URL'
    
    echo '--- Environment Check ---'
    echo \"PATH: \$PATH\"
    echo \"DATABASE_URL: \$DATABASE_URL\"
    echo -n 'Python: '; which python3
    echo -n 'Uvicorn: '; which uvicorn
    
    echo '--- Starting Backend (Foreground) ---'
    # Run with python3 -m uvicorn to avoid path issues
    python3 -m uvicorn main:app --host 0.0.0.0 --port 8090
"
