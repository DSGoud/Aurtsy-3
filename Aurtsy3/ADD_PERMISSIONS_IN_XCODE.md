# Manual Fix Required: Add Permissions in Xcode

The Info.plist file exists and has all permissions, but Xcode may not be reading it properly.

## Fix in Xcode (2 minutes):

1. **Open the project** in Xcode
2. **Select the project** (blue AurtsyApp icon)
3. **Select "AurtsyApp" target**
4. **Go to "Info" tab**
5. **Under "Custom iOS Target Properties"**, add these keys by clicking the **+** button:

### Required Permissions:

| Key | Value |
|-----|-------|
| Privacy - Camera Usage Description | We need camera access to take photos of meals |
| Privacy - Microphone Usage Description | We need microphone access for voice dictation |
| Privacy - Photo Library Usage Description | We need photo library access to select meal photos |
| Privacy - Speech Recognition Usage Description | We use speech recognition for voice notes |

**Note:** When you start typing "Privacy", Xcode will autocomplete these keys.

## After Adding:

1. Clean Build Folder (Shift+Cmd+K)
2. Build and Run (Cmd+R)
3. Test camera - it should prompt for permission!
4. Test dictation - it should prompt for permission!

## Why This Happens:

Modern Xcode projects sometimes don't automatically use the Info.plist file for permissions. Adding them directly in the target settings ensures they're included in the final app bundle.
