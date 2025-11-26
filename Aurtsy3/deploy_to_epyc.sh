#!/bin/bash
# Deploy to EPYC Server

SERVER="agoud@100.79.130.75"
REMOTE_DIR="~/Aurtsy_git/Aurtsy-3/Aurtsy3"

echo "🚀 Deploying to $SERVER..."

# 1. Sync files (excluding git, venv, etc)
echo "📦 Syncing files..."
rsync -avz --exclude '.git' --exclude '__pycache__' --exclude 'venv' --exclude '.DS_Store' \
    ./ $SERVER:$REMOTE_DIR/

# 2. Run Docker Compose on server
echo "🐳 Building and starting containers..."
ssh $SERVER "cd $REMOTE_DIR/infra && docker compose -f docker-compose.dev.yml up -d --build"

echo "✅ Deployment complete!"
