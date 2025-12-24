# IDSentinel - Quick Reference

## 🚀 Quick Start Commands

```bash
# Get dependencies
flutter pub get

# Run on web (Chrome)
flutter run -d chrome

# Run on web (Edge)
flutter run -d edge

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Hot reload (while running)
Press 'r' in terminal

# Hot restart (while running)
Press 'R' in terminal

# Build release
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web
```

## 📱 Key Features Quick Access

| Feature | Screen | Route | Icon |
|---------|--------|-------|------|
| CNIC Monitor | `CnicMonitorScreen` | `/cnic-monitor` | `credit_card` |
| DocGuard | `DocGuardScreen` | `/doc-guard` | `document_scanner` |
| LeakFinder | `LeakFinderScreen` | `/leak-finder` | `warning_amber` |
| PhotoShield | `PhotoShieldScreen` | `/photo-shield` | `photo_camera` |
| MirrorTrace | `MirrorTraceScreen` | `/mirror-trace` | `face` |
| AppCleanse | `AppCleanseScreen` | `/app-cleanse` | `cleaning_services` |
| SMS Scanner | `SmsScannerScreen` | `/sms-scanner` | `message` |

## 🎨 Theme Colors

```dart
Primary: #6C5CE7 (Purple)
Secondary: #00B894 (Green)
Accent: #FF7675 (Pink)
Warning: #FDCB6E (Yellow)
Danger: #D63031 (Red)

// Dark Theme
Background: #0F0F1E
Surface: #1A1A2E
Card: #16213E

// Light Theme
Background: #F5F6FA
Surface: #FFFFFF
Card: #FFFFFF
```

## 📦 Important Dependencies

```yaml
# State Management
flutter_riverpod: ^2.6.1

# UI
google_fonts: ^6.3.3
fl_chart: ^0.65.0

# Storage
hive: ^2.2.3
hive_flutter: ^1.1.0

# Image
image_picker: ^1.2.1
cached_network_image: ^3.4.1

# Network
dio: ^5.9.0
http: ^1.6.0

# Utils
permission_handler: ^11.4.0
intl: ^0.19.0
```

## 🔧 Common Code Snippets

### Navigate to Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TargetScreen(),
  ),
);
```

### Show SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message here'),
    backgroundColor: Colors.green,
  ),
);
```

### Show Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('OK'),
      ),
    ],
  ),
);
```

### Pick Image
```dart
final picker = ImagePicker();
final image = await picker.pickImage(
  source: ImageSource.camera, // or ImageSource.gallery
);

if (image != null) {
  final file = File(image.path);
  // Use file
}
```

### Use Riverpod Provider
```dart
// Read once
final value = ref.read(myProvider);

// Watch for updates
final value = ref.watch(myProvider);

// Update state
ref.read(myProvider.notifier).state = newValue;
```

### Save to Hive
```dart
final box = Hive.box('myBox');
await box.put('key', 'value');

// Retrieve
final value = box.get('key');
```

### Make API Call with Dio
```dart
final dio = Dio();

try {
  final response = await dio.get('https://api.example.com/data');
  print(response.data);
} catch (e) {
  print('Error: $e');
}
```

## 🐛 Debugging Tips

### Enable Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Check Device Logs
```bash
# Android
flutter logs

# iOS
flutter logs --device-id=<device-id>
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

## 📊 App Statistics

- **Total Screens**: 8 (Home + 7 features)
- **Widgets**: 3 reusable components
- **Models**: 7 data classes
- **Dependencies**: 30+ packages
- **Lines of Code**: ~2000+ (estimated)
- **Platforms**: Android, iOS, Web, Windows

## 🔐 Security Features

- CNIC data encryption
- Secure local storage
- Permission-based access
- Input validation
- Safe API calls with timeout

## 📈 Performance Tips

1. Use `const` constructors where possible
2. Implement `ListView.builder` for long lists
3. Cache network images
4. Lazy load data
5. Debounce search inputs
6. Use `RepaintBoundary` for complex widgets

## 🎯 Next Steps for Production

1. **Backend Setup**
   - Set up Firebase project
   - Create Node.js API server
   - Configure cloud functions

2. **AI/ML Integration**
   - Add TensorFlow Lite models
   - Implement actual deepfake detection
   - Train custom models for document analysis

3. **Testing**
   - Write unit tests (target 80% coverage)
   - Create integration tests
   - Perform security audit

4. **Optimization**
   - Optimize images and assets
   - Implement code splitting
   - Add analytics

5. **Deployment**
   - Generate app icons
   - Create splash screens
   - Prepare store listings
   - Submit to app stores

## 📞 Support & Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Riverpod**: https://riverpod.dev
- **Material Design**: https://m3.material.io
- **Firebase**: https://firebase.google.com/docs
- **Stack Overflow**: Tag with `flutter`

## 📝 File Structure

```
lib/
├── main.dart                       # App entry point
├── models/
│   └── app_models.dart            # Data models
├── screens/
│   ├── home_screen.dart           # Dashboard
│   ├── cnic_monitor_screen.dart   # CNIC monitoring
│   ├── doc_guard_screen.dart      # Document analysis
│   ├── leak_finder_screen.dart    # Data leak detection
│   ├── photo_shield_screen.dart   # Deepfake detection
│   ├── mirror_trace_screen.dart   # Photo tracking
│   ├── app_cleanse_screen.dart    # App scanning
│   └── sms_scanner_screen.dart    # SMS analysis
├── widgets/
│   ├── feature_card.dart          # Feature cards
│   ├── stats_card.dart            # Statistics display
│   └── threat_timeline.dart       # Activity timeline
└── utils/
    └── app_theme.dart             # Theme configuration
```

## 🎨 UI Guidelines

- **Spacing**: Multiples of 4 (4, 8, 16, 24, 32)
- **Border Radius**: 8, 12, 16, 20
- **Font Sizes**: 12, 14, 16, 20, 24, 32
- **Icon Sizes**: 20, 24, 28, 32, 48, 64
- **Card Elevation**: 2, 4, 8
- **Animation Duration**: 200-300ms

## ⚡ VS Code Shortcuts

- `Ctrl+Space`: Show suggestions
- `F12`: Go to definition
- `Shift+F12`: Find references
- `Ctrl+.`: Quick fix
- `Ctrl+Shift+R`: Refactor
- `Ctrl+/`: Toggle comment

## 🚨 Common Errors & Fixes

| Error | Solution |
|-------|----------|
| `CardTheme` type error | Use `CardThemeData` instead |
| Firebase compilation error | Comment out Firebase dependencies |
| Image picker not working | Add permissions in AndroidManifest.xml |
| Hive not persisting | Call `Hive.initFlutter()` in main |
| Theme not switching | Use `ref.read().notifier.state` |

---

**Last Updated**: December 17, 2025  
**Version**: 1.0.0+1  
**Status**: MVP Ready ✅
