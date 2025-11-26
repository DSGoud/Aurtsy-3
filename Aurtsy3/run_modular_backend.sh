#!/bin/bash
# Run the modular backend

# Ensure we are in the backend directory or set PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$(pwd)/backend

echo "🚀 Starting Modular Backend..."
export DATABASE_URL="postgresql://aurtsy_user:aurtsy_pass@localhost:5444/aurtsy_db"
cd backend
python3 run.py
