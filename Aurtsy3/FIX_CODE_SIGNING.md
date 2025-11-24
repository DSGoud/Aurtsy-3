# Quick Fix: Code Signing Error

## Error
"Signing for 'AurtsyApp' requires a development team"

## Solution (30 seconds)

### In Xcode:

1. **Select the project** (blue icon at top of navigator)
2. **Select "AurtsyApp" target** (under TARGETS)
3. **Go to "Signing & Capabilities" tab**
4. **Check "Automatically manage signing"**
5. **Select your Team** from dropdown (or select "Add an Account..." if needed)
   - For personal development: Select your Apple ID
   - Or select "None" for simulator-only testing

### Alternative: Disable Signing for Simulator

If you don't have an Apple Developer account:

1. Select project → AurtsyApp target
2. Signing & Capabilities tab
3. **Uncheck** "Automatically manage signing"
4. Set **Signing Certificate** to "Sign to Run Locally"
5. This works for simulator testing

## After Fixing

Press **Cmd+R** to build and run!
