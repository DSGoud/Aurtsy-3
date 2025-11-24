# Manual Xcode Project Creation Guide

**Time:** 30-45 minutes  
**Goal:** Create a working iOS app with proper permissions

---

## Part 1: Create New Xcode Project (5 min)

1. **Open Xcode**
2. **File → New → Project**
3. **Choose template:**
   - Platform: **iOS**
   - Template: **App**
   - Click **Next**

4. **Project settings:**
   - Product Name: `AurtsyApp`
   - Team: Select your team (Dhru Goud)
   - Organization Identifier: `com.aurtsy`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (we'll use our own)
   - Include Tests: **Uncheck both boxes**
   - Click **Next**

5. **Save location:**
   - Navigate to: `/Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/`
   - Create new folder: `ios-app-manual`
   - Save there
   - **Uncheck** "Create Git repository"
   - Click **Create**

✅ **Checkpoint:** You should now have a working "Hello World" app. Press Cmd+R to verify it runs.

---

## Part 2: Add Privacy Permissions (2 min)

1. **In Xcode, select the project** (blue icon)
2. **Select "AurtsyApp" target**
3. **Go to "Info" tab**
4. **Click the "+" button** to add these keys:

```
Privacy - Camera Usage Description
→ We need camera access to take photos of meals for tracking nutrition

Privacy - Microphone Usage Description  
→ We need microphone access for voice dictation of meal notes

Privacy - Photo Library Usage Description
→ We need photo library access to select meal photos

Privacy - Speech Recognition Usage Description
→ We use speech recognition to transcribe your voice notes
```

✅ **Checkpoint:** All 4 permissions should be visible in the Info tab.

---

## Part 3: Copy Source Files (5 min)

1. **In Terminal, run:**
```bash
# Copy all Swift files
cp /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app/Sources/AurtsyApp/*.swift \
   /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-manual/AurtsyApp/
```

2. **In Xcode:**
   - **Delete** the default `ContentView.swift` (select it, press Delete, choose "Move to Trash")
   - **Delete** the default `AurtsyAppApp.swift` (select it, press Delete, choose "Move to Trash")

3. **Add your files:**
   - Right-click on the **"AurtsyApp" folder** in the navigator
   - Choose **"Add Files to AurtsyApp..."**
   - Navigate to `/Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-manual/AurtsyApp/`
   - **Select ALL .swift files** (Cmd+A)
   - **Check** "Copy items if needed"
   - **Check** "Create groups"
   - Target: Make sure **"AurtsyApp"** is checked
   - Click **Add**

✅ **Checkpoint:** You should see all your Swift files in the Xcode navigator.

---

## Part 4: Fix Camera Code for Simulator (2 min)

1. **Open `MealEntryModal.swift`** in Xcode
2. **Find line ~425** (the `makeUIViewController` function in `CameraPicker`)
3. **Replace:**
```swift
func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = context.coordinator
    picker.allowsEditing = false
    return picker
}
```

**With:**
```swift
func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    // Check if camera is available (won't be on simulator)
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
    } else {
        // Fallback to photo library on simulator
        picker.sourceType = .photoLibrary
    }
    picker.delegate = context.coordinator
    picker.allowsEditing = false
    return picker
}
```

✅ **Checkpoint:** Camera code now handles simulator gracefully.

---

## Part 5: Build and Test (5 min)

1. **Clean Build Folder:** Product → Clean Build Folder (Shift+Cmd+K)
2. **Build:** Cmd+B
3. **Fix any errors** (there shouldn't be any, but if there are, share them)
4. **Run:** Cmd+R

5. **Test features:**
   - ✅ App launches
   - ✅ Tap "Meal Log"
   - ✅ Tap "Add Photo" → "Camera" → Should open photo library
   - ✅ Tap "Dictate" → Should ask for microphone permission
   - ✅ Select a photo → Should display
   - ✅ Type notes → Should work

---

## Part 6: Commit Your Work (2 min)

```bash
cd /Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3
git add ios-app-manual/
git commit -m "feat: create manual Xcode project with working permissions"
```

---

## ✅ Success Criteria

- [ ] App builds without errors
- [ ] App runs in simulator
- [ ] Camera button opens photo library (simulator) or camera (device)
- [ ] Dictation requests microphone permission
- [ ] No crashes

---

## 🐛 Troubleshooting

**If build fails:**
- Check that all files are added to the AurtsyApp target
- Check that no files are duplicated
- Clean build folder and try again

**If camera still crashes:**
- Verify the camera availability check was added
- Check Xcode console for error message

**If dictation crashes:**
- Verify Speech Recognition permission is in Info tab
- Check that SpeechRecorder class is included

---

## 📝 Next Steps After Success

1. Test all features thoroughly
2. Proceed to Phase 2: Organize code into folders
3. Then Phase 3: Backend refactoring

