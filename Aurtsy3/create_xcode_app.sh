#!/bin/bash
# Automated Xcode project creation using xcodegen

set -e

echo "🚀 Creating proper Xcode iOS App project..."

# Install xcodegen if not present
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installing xcodegen..."
    brew install xcodegen
fi

# Create project.yml for xcodegen
cat > /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode/project.yml << 'EOF'
name: AurtsyApp
options:
  bundleIdPrefix: com.aurtsy
  deploymentTarget:
    iOS: "16.0"
targets:
  AurtsyApp:
    type: application
    platform: iOS
    sources:
      - path: AurtsyApp
    info:
      path: AurtsyApp/Info.plist
      properties:
        CFBundleDisplayName: Aurtsy
        UILaunchScreen: {}
        NSCameraUsageDescription: "We need camera access to take photos of meals for tracking nutrition and progress."
        NSMicrophoneUsageDescription: "We need microphone access for voice dictation of meal notes."
        NSPhotoLibraryUsageDescription: "We need photo library access to select meal photos."
        NSPhotoLibraryAddUsageDescription: "We need permission to save meal photos."
        NSSpeechRecognitionUsageDescription: "We use speech recognition to transcribe your voice notes about meals and activities."
EOF

# Create directory structure
mkdir -p /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode/AurtsyApp

# Copy all Swift files
echo "📋 Copying Swift files..."
cp /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app/Sources/AurtsyApp/*.swift \
   /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode/AurtsyApp/

# Generate Xcode project
cd /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode
echo "🔨 Generating Xcode project..."
xcodegen generate

echo "✅ Done!"
echo ""
echo "📱 Next steps:"
echo "1. Open: /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode/AurtsyApp.xcodeproj"
echo "2. Select AurtsyApp scheme"
echo "3. Select iPhone simulator"
echo "4. Press Cmd+R to build and run"
echo ""
echo "The project now has all required permissions configured!"
