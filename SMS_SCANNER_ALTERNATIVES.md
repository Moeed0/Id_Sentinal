# SMS Scanner Feature - Alternative Implementation

## Problem
The SMS Scanner feature requires READ_SMS and RECEIVE_SMS permissions, which are flagged by Play Protect as dangerous. We removed these permissions to pass security checks.

## Solution Options

### Option 1: Manual Text Input (Recommended)
Allow users to manually paste SMS text for scanning.

**Implementation:**
```dart
// In sms_scanner_screen.dart

// Add a TextField for manual input
TextField(
  decoration: InputDecoration(
    labelText: 'Paste SMS text here',
    hintText: 'Long press and paste your SMS message',
    border: OutlineInputBorder(),
  ),
  maxLines: 5,
  onChanged: (text) {
    // Analyze the pasted text for phishing
    _analyzeSmsText(text);
  },
)

// Scan button
ElevatedButton(
  onPressed: () {
    // Analyze the text
    _scanForPhishing();
  },
  child: Text('Scan for Phishing'),
)
```

### Option 2: Disable the Feature
Simply remove SMS Scanner from the app until you can justify the permissions to Google.

**Implementation:**
```dart
// In home_screen.dart or enhanced_home_screen.dart

// Comment out or remove SMS Scanner from features list
final features = [
  // ... other features ...
  // (\r\n  //   'SMS Scanner',\r\n  //   'Phishing detection',\r\n  //   Icons.message,\r\n  //   [Colors.amber, Colors.orange],\r\n  //   () => const SmsScannerScreen()\r\n  // ),
];
```

### Option 3: Request Permission Only When Needed
Add runtime permission request with clear explanation.

**Implementation:**
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestSmsPermission() async {
  // Show explanation dialog first
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('SMS Permission Required'),
      content: Text(
        'To automatically scan your SMS messages for phishing attempts, '
        'we need permission to read your messages. '
        'We only analyze text locally and never send your messages anywhere.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _requestPermission();
          },
          child: Text('Grant Permission'),
        ),
      ],
    ),
  );
}

Future<void> _requestPermission() async {
  final status = await Permission.sms.request();
  if (status.isGranted) {
    // Permission granted, can read SMS
    _startSmsScanning();
  } else {
    // Permission denied, show manual input option
    _showManualInputOption();
  }
}
```

**Note:** Even with runtime permission, Play Store may still flag the app if you can't justify why you need SMS access.

---

## Recommended Approach

**Use Option 1: Manual Text Input**

### Why?
1. ✅ No dangerous permissions needed
2. ✅ Won't be flagged by Play Protect
3. ✅ User has full control
4. ✅ Still provides value (phishing detection)
5. ✅ Complies with Play Store policies

### How It Works:
1. User receives suspicious SMS
2. User opens ID Sentinel app
3. User copies SMS text
4. User pastes into SMS Scanner
5. App analyzes text for phishing patterns
6. App shows results and warnings

### User Instructions:
```
How to scan an SMS:
1. Long press on the SMS message
2. Tap "Copy"
3. Open ID Sentinel
4. Go to SMS Scanner
5. Paste the message
6. Tap "Scan for Phishing"
```

---

## Implementation Example

Here's a complete example for the manual input approach:

```dart
// sms_scanner_screen.dart

class SmsScannerScreen extends StatefulWidget {
  const SmsScannerScreen({super.key});

  @override
  State<SmsScannerScreen> createState() => _SmsScannerScreenState();
}

class _SmsScannerScreenState extends State<SmsScannerScreen> {
  final TextEditingController _smsController = TextEditingController();
  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS Scanner'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'How to use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Copy the suspicious SMS message\n'
                      '2. Paste it in the box below\n'
                      '3. Tap "Scan for Phishing"',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Input field
            TextField(
              controller: _smsController,
              decoration: InputDecoration(
                labelText: 'Paste SMS message here',
                hintText: 'Long press and paste...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _smsController.clear();
                    setState(() => _scanResult = null);
                  },
                ),
              ),
              maxLines: 6,
              onChanged: (text) {
                setState(() => _scanResult = null);
              },
            ),
            
            SizedBox(height: 16),
            
            // Scan button
            ElevatedButton.icon(
              onPressed: _smsController.text.isEmpty || _isScanning
                  ? null
                  : _scanMessage,
              icon: _isScanning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.search),
              label: Text(_isScanning ? 'Scanning...' : 'Scan for Phishing'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Results
            if (_scanResult != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  Future<void> _scanMessage() async {
    setState(() => _isScanning = true);
    
    // Simulate scanning (replace with actual phishing detection logic)
    await Future.delayed(Duration(seconds: 2));
    
    final text = _smsController.text.toLowerCase();
    
    // Simple phishing detection patterns
    final phishingKeywords = [
      'verify account',
      'click here',
      'urgent action',
      'suspended account',
      'confirm identity',
      'prize winner',
      'claim reward',
      'reset password',
      'unusual activity',
    ];
    
    final suspiciousPatterns = phishingKeywords
        .where((keyword) => text.contains(keyword))
        .toList();
    
    final hasLinks = text.contains('http') || text.contains('www.');
    final hasPhoneNumber = RegExp(r'\d{10,}').hasMatch(text);
    
    setState(() {
      _scanResult = {
        'isSafe': suspiciousPatterns.isEmpty && !hasLinks,
        'suspiciousPatterns': suspiciousPatterns,
        'hasLinks': hasLinks,
        'hasPhoneNumber': hasPhoneNumber,
      };
      _isScanning = false;
    });
  }

  Widget _buildResults() {
    final isSafe = _scanResult!['isSafe'] as bool;
    final patterns = _scanResult!['suspiciousPatterns'] as List<String>;
    
    return Card(
      color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSafe ? Icons.check_circle : Icons.warning,
                  color: isSafe ? Colors.green : Colors.red,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSafe ? 'Message appears safe' : 'Potential phishing detected!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSafe ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            if (!isSafe) ...[
              SizedBox(height: 16),
              Text(
                'Warning signs found:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...patterns.map((pattern) => Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Contains: "$pattern"'),
                  ],
                ),
              )),
              if (_scanResult!['hasLinks'] as bool)
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Contains suspicious links'),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }
}
```

---

## Play Store Justification (If You Still Want SMS Permissions)

If you decide to keep SMS permissions, you MUST provide this in Play Store:

### Declaration Form:
**Why do you need SMS permissions?**
"Our app provides security analysis of SMS messages to detect phishing and fraud attempts. Users can opt-in to automatic SMS scanning to protect themselves from scams targeting Pakistani citizens. The SMS content is analyzed locally on the device and never transmitted to external servers."

### Privacy Policy Must Include:
- What SMS data you collect
- How you use it (local analysis only)
- That you don't share it with third parties
- How users can disable the feature

### App Description Must Explain:
"ID Sentinel includes an optional SMS scanner that helps detect phishing attempts and fraudulent messages. This feature requires SMS permissions and can be disabled at any time."

---

## Recommendation

**Go with Manual Input (Option 1)** - It's the safest approach that won't get flagged by Play Protect and still provides value to users.
