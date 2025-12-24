# Development Guide for IDSentinel

## Best Practices & Implementation Tips

### 1. State Management with Riverpod

#### Provider Setup
```dart
// User state provider
final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null);

  Future<void> loadUser(String userId) async {
    // Load user from Hive or API
    final user = await getUserFromStorage(userId);
    state = user;
  }

  void updateProfile(UserProfile profile) {
    state = profile;
  }
}

// Threat alerts provider
final threatAlertsProvider = StreamProvider<List<ThreatAlert>>((ref) {
  return getThreatAlertsStream();
});

// Theme provider (already in main.dart)
final themeProvider = StateProvider<bool>((ref) => false);
```

#### Using Providers
```dart
// In your widgets
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeProvider);
    
    return Scaffold(
      body: user == null 
        ? LoginView()
        : DashboardView(user: user),
    );
  }
}
```

### 2. Local Storage with Hive

#### Setup Hive Boxes
```dart
// In main.dart
void main() async {
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(ThreatAlertAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  
  // Open boxes
  await Hive.openBox<ThreatAlert>('threats');
  await Hive.openBox<UserProfile>('user');
  await Hive.openBox('settings');
  
  runApp(MyApp());
}
```

#### Using Hive
```dart
// Save data
final box = Hive.box<ThreatAlert>('threats');
await box.add(threatAlert);

// Read data
final threats = box.values.toList();

// Watch for changes
box.watch().listen((event) {
  print('Box changed: ${event.key}');
});
```

### 3. API Integration

#### Create API Service
```dart
// lib/services/api_service.dart
class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.idsentinel.com/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token
          final token = getAuthToken();
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors
          print('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<CnicActivity>> getCnicActivities(String cnic) async {
    try {
      final response = await _dio.get('/cnic/activities', 
        queryParameters: {'cnic': cnic}
      );
      return (response.data as List)
        .map((json) => CnicActivity.fromJson(json))
        .toList();
    } catch (e) {
      throw Exception('Failed to load activities: $e');
    }
  }

  Future<DocumentAnalysis> analyzeDocument(File image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path),
    });
    
    final response = await _dio.post('/document/analyze', data: formData);
    return DocumentAnalysis.fromJson(response.data);
  }
}
```

### 4. Permission Handling

#### Request Permissions
```dart
// lib/utils/permissions.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestSmsPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.sms.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
```

#### Use in Widgets
```dart
Future<void> _pickImage() async {
  final hasPermission = await PermissionService.requestCameraPermission();
  
  if (!hasPermission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('Camera permission is needed to scan documents'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionService.openSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
    return;
  }
  
  // Proceed with image picking
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.camera);
}
```

### 5. Error Handling

#### Global Error Handler
```dart
// lib/utils/error_handler.dart
class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An error occurred';
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout';
          break;
        case DioExceptionType.badResponse:
          message = 'Server error: ${error.response?.statusCode}';
          break;
        default:
          message = 'Network error';
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // Retry logic
          },
        ),
      ),
    );
  }
}
```

### 6. Notifications

#### Setup Local Notifications
```dart
// Add flutter_local_notifications package
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
    FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }

  static Future<void> showThreatAlert(ThreatAlert alert) async {
    const androidDetails = AndroidNotificationDetails(
      'threat_alerts',
      'Threat Alerts',
      channelDescription: 'Notifications for detected threats',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      alert.id.hashCode,
      alert.title,
      alert.description,
      details,
    );
  }
}
```

### 7. Testing

#### Unit Tests
```dart
// test/models/threat_alert_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThreatAlert', () {
    test('should serialize to JSON correctly', () {
      final alert = ThreatAlert(
        id: '123',
        title: 'Test',
        description: 'Test alert',
        type: ThreatType.cnicMisuse,
        severity: ThreatSeverity.high,
        timestamp: DateTime(2024, 1, 1),
      );
      
      final json = alert.toJson();
      
      expect(json['id'], '123');
      expect(json['title'], 'Test');
    });
    
    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'description': 'Test alert',
        'type': 'ThreatType.cnicMisuse',
        'severity': 'ThreatSeverity.high',
        'timestamp': '2024-01-01T00:00:00.000',
        'isRead': false,
      };
      
      final alert = ThreatAlert.fromJson(json);
      
      expect(alert.id, '123');
      expect(alert.title, 'Test');
    });
  });
}
```

#### Widget Tests
```dart
// test/widgets/feature_card_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FeatureCard displays correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureCard(
            title: 'Test',
            subtitle: 'Test subtitle',
            icon: Icons.shield,
            gradient: [Colors.blue, Colors.cyan],
            onTap: () {},
          ),
        ),
      ),
    );
    
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Test subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.shield), findsOneWidget);
  });
}
```

### 8. Performance Optimization

#### Image Caching
```dart
// Use cached_network_image for remote images
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 400, // Resize for performance
  memCacheHeight: 400,
)
```

#### Lazy Loading
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
)
```

#### Debouncing
```dart
// Debounce search input
Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(const Duration(milliseconds: 500), () {
    // Perform search
    performSearch(query);
  });
}
```

### 9. Security Best Practices

#### Encrypt Sensitive Data
```dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromLength(32);
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String text) {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String encrypted) {
    return _encrypter.decrypt64(encrypted, iv: _iv);
  }
}
```

#### Secure Storage
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

### 10. Code Organization

```
lib/
├── main.dart
├── models/
│   ├── app_models.dart
│   └── ...
├── screens/
│   ├── home_screen.dart
│   └── ...
├── widgets/
│   ├── common/
│   │   ├── custom_button.dart
│   │   └── loading_indicator.dart
│   └── ...
├── services/
│   ├── api_service.dart
│   ├── notification_service.dart
│   └── ...
├── providers/
│   ├── user_provider.dart
│   ├── threat_provider.dart
│   └── ...
├── utils/
│   ├── app_theme.dart
│   ├── constants.dart
│   ├── permissions.dart
│   └── error_handler.dart
└── config/
    └── api_config.dart
```

## Deployment Checklist

### Pre-Release
- [ ] Run `flutter analyze` and fix all issues
- [ ] Run tests with `flutter test`
- [ ] Test on real devices (Android & iOS)
- [ ] Check app performance with DevTools
- [ ] Review privacy policy and terms
- [ ] Prepare app store assets (screenshots, descriptions)

### Android Release
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS Release
```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
# Product > Archive
```

### Web Release
```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Common Issues & Solutions

### Issue: Image picker not working on web
**Solution**: Use `kIsWeb` to conditionally use file_picker on web

### Issue: Hive not persisting data
**Solution**: Ensure `await Hive.initFlutter()` is called before opening boxes

### Issue: Theme not switching
**Solution**: Use `ref.read(themeProvider.notifier).state = newValue` to update

### Issue: Build errors with Firebase
**Solution**: Ensure Firebase is properly configured with `flutterfire configure`

## Resources

- Flutter Docs: https://docs.flutter.dev
- Riverpod Docs: https://riverpod.dev
- Hive Docs: https://docs.hivedb.dev
- Material Design: https://m3.material.io
