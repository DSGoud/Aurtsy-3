#!/bin/bash
# Quick backend health check

echo "🔍 Checking Backend Health..."
echo ""

# Check if backend is accessible
echo "1. Backend API Status:"
if curl -s http://100.79.130.75:8090/docs > /dev/null; then
    echo "   ✅ Backend is running at http://100.79.130.75:8090"
else
    echo "   ❌ Backend is not accessible"
fi

echo ""
echo "2. API Documentation:"
echo "   📖 Swagger UI: http://100.79.130.75:8090/docs"
echo "   📖 ReDoc: http://100.79.130.75:8090/redoc"

echo ""
echo "3. Test Endpoints:"
echo "   Testing /children endpoint..."
curl -s http://100.79.130.75:8090/children/ | python3 -m json.tool 2>/dev/null || echo "   ⚠️  No children data or endpoint not available"

echo ""
echo "✅ Backend check complete!"
echo ""
echo "Next: Test the iOS app features in the simulator"
