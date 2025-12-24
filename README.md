# IDSentinel - Identity Protection & Fraud Detection App

![IDSentinel](https://img.shields.io/badge/Flutter-App-blue?style=for-the-badge&logo=flutter)
![Status](https://img.shields.io/badge/Status-MVP-success?style=for-the-badge)

A comprehensive Flutter application for protecting your digital identity and detecting fraud across multiple channels including CNIC misuse, document forgery, data leaks, deepfakes, and more.

## 🚀 Features

### 1. **CNIC Misuse Monitor**
- Real-time alerts for CNIC usage
- Track microloan registrations
- Monitor SIM card registrations
- Detect job application fraud
- Alert on mobile wallet signups
- Color-coded status indicators (Approved, Warning, Blocked)

### 2. **DocGuard - Document Forgery Detection**
- Upload documents via camera or gallery
- AI-powered forensic analysis
- Font consistency checking
- Compression analysis
- Edge detection for manipulation
- Metadata verification

### 3. **LeakFinder - Data Leak Checker**
- Scan for leaked CNIC, email, or phone numbers
- Dark web monitoring simulation
- Fuzzy matching algorithms
- Actionable recommendations

### 4. **PhotoShield - Deepfake Detection**
- Upload photos for analysis
- Detect AI-manipulated images
- Deepfake detection capabilities
- Reverse image search integration

### 5. **MirrorTrace - Photo Misuse Tracker**
- Track photos used in fake accounts
- Facial geometry matching
- Detect re-edits and face-swaps
- Alert on photo misuse

### 6. **AppCleanse - Risky App Scanner**
- Scan installed applications
- Detect spyware and fake banking apps
- Permission analysis
- Background network monitoring

### 7. **SMS Threat Scanner**
- Scan SMS for phishing attempts
- NLP pattern recognition
- Flag dangerous messages
- Report scam SMS

## 🎨 UI/UX Features

- **Modern Design**: Premium gradient cards with smooth animations
- **Dark/Light Mode**: Toggle between themes with a single tap
- **Responsive Layout**: Optimized for all screen sizes
- **Interactive Cards**: Beautiful feature cards with gradient backgrounds
- **Real-time Statistics**: Safety score and threats blocked
- **Timeline View**: Recent activity with severity indicators

## 📱 Tech Stack

### State Management
- **Riverpod** - For reactive state management

### UI/UX
- **Google Fonts** (Inter) - Modern typography
- **FL Chart** - Data visualization
- **Custom Gradients** - Premium visual design

### Storage
- **Hive** - Local caching and offline storage
- **Shared Preferences** - User settings

### Image & File Handling
- **Image Picker** - Camera and gallery access
- **File Picker** - Document selection
- **Cached Network Image** - Optimized image loading

### Utilities
- **Intl** - Date/time formatting
- **Permission Handler** - App permissions
- **Telephony** - SMS reading
- **Dio/HTTP** - Network requests

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Edge/Chrome browser (for web)
- Visual Studio (for Windows desktop)
- Android Studio/Xcode (for mobile)

### Setup Steps

1. **Clone or download the project**

2. **Navigate to project directory**
```bash
cd "Innovation project app"
```

3. **Get dependencies**
```bash
flutter pub get
```

4. **Enable desired platform**
```bash
# For web
flutter create --platforms=web .

# For Windows
flutter create --platforms=windows .

# For Android/iOS
flutter create --platforms=android,ios .
```

5. **Run the app**
```bash
# Web (Edge)
flutter run -d edge

# Web (Chrome)
flutter run -d chrome

# Windows
flutter run -d windows

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── utils/
│   └── app_theme.dart          # Theme configuration
├── widgets/
│   ├── feature_card.dart       # Reusable feature cards
│   ├── stats_card.dart         # Statistics display
│   └── threat_timeline.dart    # Activity timeline
└── screens/
    ├── home_screen.dart        # Main dashboard
    ├── cnic_monitor_screen.dart
    ├── doc_guard_screen.dart
    ├── leak_finder_screen.dart
    ├── photo_shield_screen.dart
    ├── mirror_trace_screen.dart
    ├── app_cleanse_screen.dart
    └── sms_scanner_screen.dart
```

## 🎯 Future Enhancements

### High Priority
- [ ] Firebase integration for backend
- [ ] Real AI/ML models for document analysis
- [ ] Actual dark web scanning API
- [ ] Real-time CNIC monitoring backend
- [ ] Push notifications implementation

### Medium Priority
- [ ] Multi-CNIC monitoring
- [ ] Emergency CNIC lock feature
- [ ] Identity recovery guidance
- [ ] Analytics dashboard with charts
- [ ] Gamified security tips

### Low Priority
- [ ] WhatsApp/Social media scam detection
- [ ] Export reports as PDF
- [ ] Share threat alerts
- [ ] Biometric authentication

## 🔐 Permissions Required

The app requires the following permissions:
- **Camera** - Document and photo scanning
- **Storage** - Image/file access
- **SMS** - Reading messages for threat detection (Android only)
- **Internet** - API calls and leak detection
- **Installed Apps** - App scanning (Android only)

## 🎨 Color Scheme

- **Primary**: Purple (`#6C5CE7`)
- **Secondary**: Green (`#00B894`)
- **Accent**: Pink (`#FF7675`)
- **Warning**: Yellow (`#FDCB6E`)
- **Danger**: Red (`#D63031`)

## 📝 Notes

- Firebase dependencies are commented out in `pubspec.yaml` for MVP
- Some features use simulated data for demonstration
- Real API integrations need to be implemented for production
- SMS reading is currently simulated (requires Android permissions)
- Image analysis uses mock results (integrate TensorFlow Lite for production)

## 👨‍💻 Development

### Hot Reload
Press `r` in the terminal while the app is running to hot reload changes.

### Hot Restart
Press `R` in the terminal for a full restart.

### Clear Console
Press `c` to clear the console.

### Quit
Press `q` to quit the application.

## 🐛 Known Issues

- Firebase packages need compatible versions for web
- Windows build requires Visual Studio 2019 or later
- Telephony package is discontinued (consider alternatives)
- Some plugins show warnings about default implementations

## 📄 License

This project is for educational and demonstration purposes.

## 🤝 Contributing

This is a demonstration app. For production use, implement proper backend services, authentication, and real analysis APIs.

---

**Built with ❤️ using Flutter**
