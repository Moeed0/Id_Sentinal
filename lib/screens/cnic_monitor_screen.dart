import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CnicMonitorScreen extends StatefulWidget {
  const CnicMonitorScreen({super.key});

  @override
  State<CnicMonitorScreen> createState() => _CnicMonitorScreenState();
}

class _CnicMonitorScreenState extends State<CnicMonitorScreen> {
  final _cnicController = TextEditingController();
  bool _isMonitoring = false;

  final List<CnicActivity> _activities = [
    CnicActivity(
      title: 'Microloan Application',
      company: 'EasyPaisa Finance',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      status: ActivityStatus.blocked,
      icon: Icons.money_off,
    ),
    CnicActivity(
      title: 'SIM Registration Attempt',
      company: 'Jazz Telecom',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: ActivityStatus.warning,
      icon: Icons.sim_card_alert,
    ),
    CnicActivity(
      title: 'Mobile Wallet Signup',
      company: 'JazzCash',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: ActivityStatus.approved,
      icon: Icons.account_balance_wallet,
    ),
    CnicActivity(
      title: 'Job Application',
      company: 'ABC Corporation',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: ActivityStatus.approved,
      icon: Icons.work,
    ),
  ];

  void _startMonitoring() {
    if (_cnicController.text.isNotEmpty) {
      setState(() {
        _isMonitoring = !_isMonitoring;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isMonitoring
                ? 'CNIC monitoring activated'
                : 'CNIC monitoring paused',
          ),
          backgroundColor: _isMonitoring ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('CNIC Monitor'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // Show full history
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CNIC Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitor Your CNIC',
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get real-time alerts whenever your CNIC is used',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _cnicController,
                        decoration: InputDecoration(
                          labelText: 'CNIC Number',
                          hintText: '12345-1234567-1',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _startMonitoring(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                          _CnicInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startMonitoring,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isMonitoring
                                ? Colors.orange
                                : theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isMonitoring
                                ? 'Pause Monitoring'
                                : 'Start Monitoring',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Monitoring Status with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _isMonitoring
                    ? Container(
                        key: const ValueKey('monitoring'),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Monitoring',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Your CNIC is being monitored 24/7',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('not_monitoring')),
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Text('Recent Activity', style: theme.textTheme.displaySmall),
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activities.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  return _ActivityCard(activity: activity);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cnicController.dispose();
    super.dispose();
  }
}

class _ActivityCard extends StatelessWidget {
  final CnicActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (activity.status) {
      case ActivityStatus.blocked:
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'BLOCKED';
        break;
      case ActivityStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'WARNING';
        break;
      case ActivityStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'APPROVED';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(activity.icon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(activity.company, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(activity.timestamp),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 4 || i == 11) {
        buffer.write('-');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

enum ActivityStatus { blocked, warning, approved }

class CnicActivity {
  final String title;
  final String company;
  final DateTime timestamp;
  final ActivityStatus status;
  final IconData icon;

  CnicActivity({
    required this.title,
    required this.company,
    required this.timestamp,
    required this.status,
    required this.icon,
  });
}
