# Quick Build & Deploy Guide

## 🚀 Build Release APK

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

## 📦 Build App Bundle (Recommended for Play Store)

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build app bundle
flutter build appbundle --release

# AAB location:
# build/app/outputs/bundle/release/app-release.aab
```

## 📱 Install on Device

```bash
# Debug build (faster)
flutter build apk --debug
flutter install

# Or directly run
flutter run
```

## ✅ Pre-Submission Checklist

- [ ] App name is "ID Sentinel" everywhere
- [ ] Logo has no blue background
- [ ] Splash screen uses teal-purple-blue gradient
- [ ] Keyboard doesn't crash when typing
- [ ] All features work (SMS, Camera, etc.)
- [ ] No excessive permissions
- [ ] Tested on real device
- [ ] Release build created
- [ ] APK/AAB signed properly

## 🎨 Color Reference

```dart
Teal:   #00B894
Purple: #6C5CE7
Blue:   #0984E3
```

## 🔧 Quick Fixes

**Keyboard crashes?**
→ Already fixed with `adjustPan`

**Play Store flags app?**
→ Already removed dangerous permissions

**Logo has blue background?**
→ Already updated to transparent logo

**Wrong app name?**
→ Already changed to "ID Sentinel"

## 📋 Files Changed

1. `AndroidManifest.xml` - Keyboard fix + permissions
2. `splash_screen.dart` - Logo + colors
3. `enhanced_home_screen.dart` - Logo display
4. `home_screen.dart` - App name
5. `assets/images/logo.png` - New logo

## 🎯 Next Steps

1. Build release APK/AAB
2. Test on your phone
3. Submit to Play Store
4. Monitor for any issues

## 📞 Emergency Commands

```bash
# If build fails
flutter clean
flutter pub get
flutter pub upgrade

# If app crashes
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get

# If logo missing
flutter pub get
flutter clean
flutter run
```

## 🏆 Success Criteria

✅ App installs without errors
✅ Keyboard works with custom size
✅ Logo displays without blue background
✅ Splash screen has correct colors
✅ Play Store accepts submission
✅ No security warnings
