# Converting Swift Package to Xcode Project

## Problem
The iOS app is currently a Swift Package (`Package.swift`), which doesn't support `Info.plist` files needed for privacy permissions (camera, microphone, speech recognition).

## Solution
We need to convert this to a proper Xcode app project.

## Steps to Convert

### Option 1: Manual Xcode Project Creation (RECOMMENDED)

1. **In Xcode:**
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: `AurtsyApp`
   - Organization Identifier: `com.aurtsy`
   - Interface: SwiftUI
   - Language: Swift
   - Save in: `/Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode/`

2. **Copy Source Files:**
   ```bash
   cp -r /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app/Sources/AurtsyApp/*.swift \
         /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-xcode/AurtsyApp/
   ```

3. **Add to Xcode Project:**
   - Drag all `.swift` files into the Xcode project navigator
   - Make sure "Copy items if needed" is checked
   - Add to target: AurtsyApp

4. **Add Info.plist Entries:**
   - Select project in navigator
   - Select "AurtsyApp" target
   - Go to "Info" tab
   - Add custom iOS target properties:
     - `NSCameraUsageDescription`: "We need access to your camera to take photos of meals"
     - `NSMicrophoneUsageDescription`: "We need access to your microphone for voice dictation"
     - `NSPhotoLibraryUsageDescription`: "We need access to your photo library to select meal photos"
     - `NSSpeechRecognitionUsageDescription`: "We use speech recognition to transcribe your voice notes"

### Option 2: Use Existing Package with Workaround

Since Swift Packages can't have Info.plist, we can create an Xcode workspace that wraps the package:

1. Create workspace
2. Add Package.swift
3. Create an app target that depends on the package
4. Add Info.plist to the app target

## Recommended Action

**Create a new Xcode project** and migrate the code. This gives you:
- ✅ Proper Info.plist support
- ✅ Better Xcode integration
- ✅ Easier to add entitlements later
- ✅ Standard iOS app structure

## Next Steps

1. Create new Xcode project
2. Copy source files
3. Add Info.plist entries
4. Build and test
5. Verify permissions work
