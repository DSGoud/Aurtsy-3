#!/bin/bash
# Build script for Aurtsy iOS app

set -e

echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "📦 Opening project in Xcode..."
cd /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app
open Package.swift

echo "✅ Project opened in Xcode"
echo ""
echo "Next steps:"
echo "1. In Xcode, select 'AurtsyApp' scheme"
echo "2. Select 'iPhone 16 Pro' simulator as destination"
echo "3. Press Cmd+B to build"
echo "4. Check the build log for any errors"
