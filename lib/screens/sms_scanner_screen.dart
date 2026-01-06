import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:sms_spam_detector/sms_spam_detector.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsScannerScreen extends StatefulWidget {
  const SmsScannerScreen({super.key});

  @override
  State<SmsScannerScreen> createState() => _SmsScannerScreenState();
}

class _SmsScannerScreenState extends State<SmsScannerScreen> {
  bool _isScanning = false;
  List<ScannedMessage> _scannedMessages = [];
  final Telephony telephony = Telephony.instance;
  final SpamDetector detector = SpamDetector();
  String? _statusMessage;

  Future<void> _scanMessages() async {
    setState(() {
      _isScanning = true;
      _statusMessage = "Requesting permissions...";
      _scannedMessages = [];
    });

    // 1. Request Permissions
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      setState(() {
        _isScanning = false;
        _statusMessage = "SMS permission denied. Cannot scan messages.";
      });
      return;
    }

    setState(() {
      _statusMessage = "Reading inbox...";
    });

    try {
      // 2. Read SMS
      final List<SmsMessage> messages = await telephony.getInboxSms(
        columns: [SmsColumn.BODY, SmsColumn.ADDRESS, SmsColumn.DATE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      setState(() {
        _statusMessage = "Analyzing ${messages.length} messages...";
      });

      List<ScannedMessage> results = [];

      // 3. Analyze Messages
      for (var message in messages) {
        if (message.body != null) {
          final analysis = detector.analyze(message.body!);
          if (analysis['isSpam'] == true) {
            results.add(ScannedMessage(
              sender: message.address ?? "Unknown",
              body: message.body!,
              isSpam: true,
              explanation:
                  analysis['explanation'] ?? "Suspicious content detected",
              date: DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
            ));
          }
        }
      }

      setState(() {
        _scannedMessages = results;
        _isScanning = false;
        _statusMessage = results.isEmpty
            ? "No threats found in your inbox."
            : "Found ${results.length} suspicious messages.";
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = "Error scanning messages: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SMS Scanner')),
      body: Column(
        children: [
          // Header / Scan Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'SMS Threat Scanner',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Detect phishing and scam messages in your inbox',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _statusMessage!.contains("Error") ||
                                _statusMessage!.contains("denied")
                            ? Colors.red
                            : theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanMessages,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isScanning ? 'Scanning...' : 'Scan Inbox',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _scannedMessages.isEmpty
                ? Center(
                    child: _isScanning
                        ? const SizedBox()
                        : Opacity(
                            opacity: 0.5,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: 64, color: Colors.green),
                                const SizedBox(height: 16),
                                const Text("Safe! No threats detected."),
                              ],
                            ),
                          ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scannedMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _scannedMessages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      msg.sender,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(msg.date),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(msg.body),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        size: 16, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        msg.explanation,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class ScannedMessage {
  final String sender;
  final String body;
  final bool isSpam;
  final String explanation;
  final DateTime date;

  ScannedMessage({
    required this.sender,
    required this.body,
    required this.isSpam,
    required this.explanation,
    required this.date,
  });
}
