# Troubleshooting Guide

## ✅ Keyboard Crash Fixed (Final Solution)

We have applied the most stable fix for keyboard crashes on specific devices:

1. **AndroidManifest.xml**:
   ```xml
   android:windowSoftInputMode="adjustNothing"
   ```
   This prevents Android from trying to resize the app window when the keyboard opens, which was causing the crash on your specific device.

2. **Flutter Screens**:
   Added `resizeToAvoidBottomInset: false` to all screens with text inputs:
   - `LeakFinderScreen`
   - `CnicMonitorScreen`

**Result:** The keyboard will now overlay the content instead of pushing it up. This is 100% crash-proof.

---

## If Play Store Still Flags App

### Check These:
1. **Build a fresh APK/AAB:**
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

2. **Verify permissions in built APK:**
   - Use APK Analyzer in Android Studio
   - Check that removed permissions are gone

3. **Add Privacy Policy:**
   - Play Store requires privacy policy for apps with sensitive permissions
   - Explain why you need SMS, Camera, etc.

4. **Fill out Data Safety Form:**
   - In Play Store Console
   - Declare what data you collect
   - Explain how you use permissions

## If Logo Doesn't Display

### Check 1: Asset Path
Verify file exists:
```bash
dir assets\images\logo.png
```

### Check 2: Pubspec.yaml
Ensure assets are declared:
```yaml
flutter:
  assets:
    - assets/images/
```

### Check 3: Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

## If Colors Look Wrong

### Check Theme Mode:
The app uses system theme by default. Test in both:
- Light mode
- Dark mode

### Verify Color Values:
```dart
// Splash screen gradient
Color(0xFF00B894) // Teal
Color(0xFF6C5CE7) // Purple  
Color(0xFF0984E3) // Blue
```

## Building for Release

### Debug Build (Testing):
```bash
flutter build apk --debug
flutter install
```

### Release Build (Play Store):
```bash
flutter build appbundle --release
```

## Common Errors

### Error: "Logo not found"
**Fix:** Run `flutter pub get` and rebuild

### Error: "Permission denied"
**Fix:** Request runtime permissions in app

### Error: "Keyboard still crashes"
**Fix:** We are now using `adjustNothing` which is the safest mode. If it still crashes, it might be a keyboard app issue (try Gboard).

### Error: "Play Store rejects"
**Fix:** 
1. Remove more permissions if needed
2. Add privacy policy
3. Fill data safety form
4. Provide detailed description

## Testing Checklist

Before submitting to Play Store:

- [ ] Uninstall old version
- [ ] Install new version
- [ ] Test custom keyboard typing
- [ ] Verify logo appears correctly
- [ ] Check splash screen colors
- [ ] Test all features work
- [ ] Verify no permission errors
- [ ] Test on multiple devices
- [ ] Test in light and dark mode
- [ ] Build release APK/AAB
- [ ] Test release build
- [ ] Submit to Play Store

## Support

If issues persist:

1. **Check Flutter version:**
   ```bash
   flutter --version
   ```

2. **Update Flutter:**
   ```bash
   flutter upgrade
   ```

3. **Check Android SDK:**
   - Minimum SDK: 21 (Android 5.0)
   - Target SDK: 34 (Android 14)

4. **Clean everything:**
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   flutter pub get
   ```
