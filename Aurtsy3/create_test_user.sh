#!/bin/bash
# Create the test_user in the backend to fix Foreign Key error

BACKEND_URL="http://100.79.130.75:8090"

echo "Creating test_user at $BACKEND_URL..."

curl -X POST "$BACKEND_URL/users/" \
     -H "Content-Type: application/json" \
     -d '{
           "id": "test_user",
           "email": "test@example.com",
           "full_name": "Test User",
           "role": "PARENT"
         }'

echo -e "\n\n✅ User creation request sent."
