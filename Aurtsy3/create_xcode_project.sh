#!/bin/bash
# Script to create a proper Xcode iOS app project with permissions

set -e

echo "🚀 Creating Xcode iOS App Project..."
echo ""

# Variables
PROJECT_NAME="AurtsyApp"
ORG_IDENTIFIER="com.aurtsy"
SOURCE_DIR="/Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app/Sources/AurtsyApp"
NEW_PROJECT_DIR="/Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode"

# Step 1: Create new Xcode project directory
echo "📁 Creating project directory..."
mkdir -p "$NEW_PROJECT_DIR"

# Step 2: Create the Xcode project using xcodegen (if available) or manual template
echo "📝 Note: You'll need to create the Xcode project manually"
echo ""
echo "MANUAL STEPS REQUIRED:"
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. Choose: iOS → App"
echo "4. Settings:"
echo "   - Product Name: $PROJECT_NAME"
echo "   - Organization Identifier: $ORG_IDENTIFIER"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - Save Location: $NEW_PROJECT_DIR"
echo ""
echo "5. After creating, run this script again with 'copy' argument"
echo ""

# Check if project was created
if [ "$1" == "copy" ]; then
    echo "📋 Copying source files..."
    
    # Find the project
    if [ -d "$NEW_PROJECT_DIR/$PROJECT_NAME" ]; then
        # Copy all Swift files
        echo "Copying Swift files..."
        cp "$SOURCE_DIR"/*.swift "$NEW_PROJECT_DIR/$PROJECT_NAME/" 2>/dev/null || true
        
        echo "✅ Files copied!"
        echo ""
        echo "NEXT STEPS IN XCODE:"
        echo "1. Open $NEW_PROJECT_DIR/$PROJECT_NAME.xcodeproj"
        echo "2. Delete the default ContentView.swift and ${PROJECT_NAME}App.swift"
        echo "3. Add all copied .swift files to the project:"
        echo "   - Right-click on $PROJECT_NAME folder"
        echo "   - Add Files to \"$PROJECT_NAME\"..."
        echo "   - Select all .swift files"
        echo "   - Check 'Copy items if needed'"
        echo "   - Add to target: $PROJECT_NAME"
        echo ""
        echo "4. Add Info.plist entries:"
        echo "   - Select project → $PROJECT_NAME target → Info tab"
        echo "   - Add these custom iOS target properties:"
        echo "     • Privacy - Camera Usage Description"
        echo "       → 'We need camera access to take meal photos'"
        echo "     • Privacy - Microphone Usage Description"
        echo "       → 'We need microphone access for voice dictation'"
        echo "     • Privacy - Photo Library Usage Description"
        echo "       → 'We need photo library access to select meal photos'"
        echo "     • Privacy - Speech Recognition Usage Description"
        echo "       → 'We use speech recognition for voice notes'"
        echo ""
        echo "5. Build and run (Cmd+R)"
    else
        echo "❌ Project not found at $NEW_PROJECT_DIR/$PROJECT_NAME"
        echo "Please create the Xcode project first (see steps above)"
    fi
else
    echo "After creating the project in Xcode, run:"
    echo "  ./create_xcode_project.sh copy"
fi
