import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:device_apps/device_apps.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class AppCleanseScreen extends StatefulWidget {
  const AppCleanseScreen({super.key});

  @override
  State<AppCleanseScreen> createState() => _AppCleanseScreenState();
}

class _AppCleanseScreenState extends State<AppCleanseScreen> {
  bool _isScanning = false;
  List<Map<String, dynamic>>? _riskyApps;
  List<Map<String, dynamic>>? _safeApps;
  String _apiKey = ''; // Store API key
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _scanApps() async {
    setState(() {
      _isScanning = true;
      _riskyApps = null;
      _safeApps = null;
    });

    // Check if we can run real scanning (Android only)
    if (!kIsWeb && Platform.isAndroid) {
      await _scanRealApps();
    } else {
      await _simulateScan();
    }
  }

  Future<void> _simulateScan() async {
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isScanning = false;
        // Simulated results for demonstration
        _riskyApps = [
          {
            'name': 'Flashlight Pro',
            'package': 'com.fake.flashlight',
            'risk': 'High',
            'reason': 'Excessive permissions (Contacts, Location)',
            'icon': Icons.highlight,
            'isReal': false,
          },
          {
            'name': 'Solitaire Free',
            'package': 'com.game.solitaire.adware',
            'risk': 'Medium',
            'reason': 'Adware detected',
            'icon': Icons.games,
            'isReal': false,
          },
        ];
        _safeApps = [
          {'name': 'WhatsApp', 'icon': Icons.chat, 'isReal': false},
          {'name': 'Instagram', 'icon': Icons.camera_alt, 'isReal': false},
          {'name': 'Spotify', 'icon': Icons.music_note, 'isReal': false},
          {'name': 'Maps', 'icon': Icons.map, 'isReal': false},
          {'name': 'Gmail', 'icon': Icons.mail, 'isReal': false},
        ];
      });
    }
  }

  Future<void> _scanRealApps() async {
    try {
      // Get list of installed apps
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );

      if (mounted) {
        setState(() {
          _isScanning = false;
          _riskyApps = []; // Initially empty, populated by VT scan
          _safeApps = apps.map((app) {
            return {
              'name': app.appName,
              'package': app.packageName,
              'icon': app is ApplicationWithIcon ? app.icon : null,
              'app': app,
              'isReal': true,
              'vtStatus': 'Not Scanned', // VirusTotal status
            };
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          // Fallback to simulation if real scan fails
          _simulateScan();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning apps: $e')),
        );
      }
    }
  }

  Future<void> _checkVirusTotal(int index, Map<String, dynamic> appData) async {
    if (_apiKey.isEmpty) {
      _showApiKeyDialog();
      return;
    }

    final app = appData['app'] as Application;
    final apkFile = File(app.apkFilePath);

    if (!apkFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('APK file not found')),
      );
      return;
    }

    // Show loading state for this item
    setState(() {
      appData['vtStatus'] = 'Scanning...';
    });

    try {
      // 1. Calculate SHA-256 hash
      final bytes = await apkFile.readAsBytes();
      final digest = sha256.convert(bytes);
      final hash = digest.toString();

      // 2. Query VirusTotal API
      final url = Uri.parse('https://www.virustotal.com/api/v3/files/$hash');
      final response = await http.get(
        url,
        headers: {'x-apikey': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = data['data']['attributes']['last_analysis_stats'];
        final malicious = stats['malicious'] as int;
        final suspicious = stats['suspicious'] as int;

        setState(() {
          if (malicious > 0 || suspicious > 0) {
            appData['vtStatus'] = 'Risky ($malicious detections)';
            appData['risk'] = 'High';
            appData['reason'] =
                'VirusTotal: $malicious engines detected malware';

            // Move to risky list
            _safeApps!.removeAt(index);
            _riskyApps!.add(appData);
          } else {
            appData['vtStatus'] = 'Safe (Clean)';
          }
        });
      } else if (response.statusCode == 404) {
        setState(() {
          appData['vtStatus'] = 'Unknown (Not in VT database)';
        });
      } else {
        setState(() {
          appData['vtStatus'] = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        appData['vtStatus'] = 'Error: $e';
      });
    }
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter VirusTotal API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Get a free API key from virustotal.com'),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _apiKey = _apiKeyController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _uninstallApp(int index) {
    // For simulation only
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uninstall App?'),
        content:
            Text('Do you want to uninstall ${_riskyApps![index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _riskyApps!.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App uninstalled successfully')),
              );
            },
            child: const Text('Uninstall', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon(dynamic iconData) {
    if (iconData is IconData) {
      return Icon(iconData, color: Colors.blue, size: 32);
    } else if (iconData is Uint8List) {
      return Image.memory(iconData, width: 40, height: 40);
    } else {
      return const Icon(Icons.android, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRealDevice = !kIsWeb && Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppCleanse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: _showApiKeyDialog,
            tooltip: 'Set VirusTotal API Key',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.cleaning_services,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Risky App Scanner',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRealDevice
                          ? 'Scan installed apps for malware using VirusTotal'
                          : 'Simulation Mode (Run on Android for real scanning)',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _scanApps,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isScanning ? 'Scanning...' : 'Scan Apps'),
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
            ),

            if (_riskyApps != null) ...[
              const SizedBox(height: 24),
              Text(
                'Scan Results',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_riskyApps!.isEmpty && _safeApps!.isEmpty)
                const SizedBox.shrink() // Should not happen if scanned
              else if (_riskyApps!.isEmpty &&
                  _safeApps!.isNotEmpty &&
                  !isRealDevice)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              'No risky apps found. Your device is safe!')),
                    ],
                  ),
                )
              else ...[
                if (_riskyApps!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Found ${_riskyApps!.length} potentially risky apps.',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ...List.generate(_riskyApps!.length, (index) {
                  final app = _riskyApps![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        child: _buildAppIcon(app['icon']),
                      ),
                      title: Text(app['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app['package'] as String,
                              style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(
                            app['reason'] as String,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _uninstallApp(index),
                      ),
                    ),
                  );
                }),
              ],
              if (_safeApps != null && _safeApps!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Installed Apps (${_safeApps!.length})',
                  style:
                      theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...List.generate(_safeApps!.length, (index) {
                  final app = _safeApps![index];
                  final isReal = app['isReal'] as bool;
                  final vtStatus = app['vtStatus'] as String?;

                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _buildAppIcon(app['icon']),
                      title: Text(app['name'] as String),
                      subtitle: isReal
                          ? Text('Status: ${vtStatus ?? "Not Scanned"}')
                          : null,
                      trailing: isReal
                          ? ElevatedButton(
                              onPressed: vtStatus == 'Scanning...'
                                  ? null
                                  : () => _checkVirusTotal(index, app),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text('Scan VT',
                                  style: TextStyle(fontSize: 12)),
                            )
                          : const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                    ),
                  );
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
