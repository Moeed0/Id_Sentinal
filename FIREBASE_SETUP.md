# Firebase Configuration Guide

This guide will help you set up Firebase for IDSentinel app.

## Prerequisites
- Google account
- Firebase project created at https://console.firebase.google.com

## Steps to Configure Firebase

### 1. Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Enter project name: "IDSentinel"
4. Follow the setup wizard

### 2. Enable Firebase Services

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable Email/Password authentication
3. (Optional) Enable Google Sign-in

#### Cloud Firestore
1. Go to Firestore Database
2. Click "Create database"
3. Start in production mode
4. Choose your region

#### Cloud Messaging (FCM)
1. Go to Cloud Messaging
2. Note your Server Key and Sender ID

#### Storage
1. Go to Storage
2. Click "Get Started"
3. Use default security rules for now

### 3. Add Firebase to Flutter App

#### For Android:
```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add firebase_messaging
flutterfire configure
```

Select your Firebase project and platforms.

#### For Web:
Add this to `web/index.html` before `</body>`:
```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  
  firebase.initializeApp(firebaseConfig);
</script>
```

### 4. Uncomment Firebase Dependencies

In `pubspec.yaml`, uncomment:
```yaml
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
firebase_messaging: ^14.7.9
```

Run:
```bash
flutter pub get
```

### 5. Initialize Firebase in main.dart

Uncomment this line in `lib/main.dart`:
```dart
await Firebase.initializeApp();
```

### 6. Set Up Cloud Functions (Optional)

Create `functions/index.js`:
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// CNIC Monitoring Alert
exports.sendCnicAlert = functions.firestore
  .document('cnic_activities/{activityId}')
  .onCreate(async (snap, context) => {
    const activity = snap.data();
    const userToken = activity.userToken;
    
    const message = {
      notification: {
        title: 'CNIC Activity Detected',
        body: activity.description
      },
      token: userToken
    };
    
    return admin.messaging().send(message);
  });

// Data Leak Alert
exports.dataLeakAlert = functions.https.onCall(async (data, context) => {
  const { cnic, email, phone } = data;
  
  // Implement dark web scanning logic here
  // This would integrate with external APIs
  
  return {
    found: false,
    message: 'No leaks detected'
  };
});
```

Deploy:
```bash
firebase deploy --only functions
```

### 7. Firestore Security Rules

Update Firestore rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // CNIC activities
    match /cnic_activities/{activityId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Threat alerts
    match /threats/{threatId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

### 8. Storage Rules

Update Storage rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /documents/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

## Backend API Integration

Create a Node.js backend for advanced features:

### Setup Express Server
```bash
npm init -y
npm install express firebase-admin body-parser cors
```

### server.js
```javascript
const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(cors());
app.use(express.json());

const db = admin.firestore();

// CNIC Registration Endpoint
app.post('/api/cnic/register', async (req, res) => {
  const { userId, cnic } = req.body;
  
  await db.collection('monitored_cnics').doc(userId).set({
    cnic: cnic,
    registeredAt: admin.firestore.FieldValue.serverTimestamp(),
    active: true
  });
  
  res.json({ success: true });
});

// Document Analysis Endpoint
app.post('/api/document/analyze', async (req, res) => {
  const { imageUrl } = req.body;
  
  // Integrate with TensorFlow or AWS Rekognition
  // For now, return mock data
  
  res.json({
    isForgery: false,
    confidence: 87.5,
    findings: [
      { type: 'font', status: 'pass' },
      { type: 'compression', status: 'pass' }
    ]
  });
});

// Leak Detection Endpoint
app.post('/api/leak/check', async (req, res) => {
  const { identifier } = req.body;
  
  // Integrate with haveibeenpwned API
  // Implement dark web monitoring
  
  res.json({
    found: false,
    sources: []
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

## Testing Firebase

### Test Authentication
```dart
// In your login screen
try {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  print('User logged in: ${credential.user?.uid}');
} catch (e) {
  print('Error: $e');
}
```

### Test Firestore
```dart
// Save CNIC monitoring data
await FirebaseFirestore.instance
  .collection('monitored_cnics')
  .doc(userId)
  .set({
    'cnic': cnicNumber,
    'active': true,
    'timestamp': FieldValue.serverTimestamp(),
  });
```

### Test Cloud Messaging
```dart
// Request permission and get token
FirebaseMessaging messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

String? token = await messaging.getToken();
print('FCM Token: $token');
```

## Production Checklist

- [ ] Update Firestore security rules
- [ ] Update Storage security rules  
- [ ] Set up Cloud Functions
- [ ] Configure FCM for push notifications
- [ ] Add proper error handling
- [ ] Implement rate limiting
- [ ] Set up monitoring and analytics
- [ ] Test on real devices
- [ ] Set up staging environment
- [ ] Configure CI/CD pipeline

## Support

For Firebase support:
- Documentation: https://firebase.google.com/docs
- Stack Overflow: Tag with `firebase`
- GitHub Issues: https://github.com/firebase/flutterfire/issues
