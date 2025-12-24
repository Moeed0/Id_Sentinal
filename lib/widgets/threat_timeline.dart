import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ThreatTimeline extends StatelessWidget {
  const ThreatTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final threats = [
      ThreatItem(
        title: 'Suspicious Login Attempt',
        description: 'Unknown device tried to access your account',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        severity: ThreatSeverity.high,
        icon: Icons.login,
      ),
      ThreatItem(
        title: 'CNIC Used for SIM Registration',
        description: 'New SIM card registered with your CNIC',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        severity: ThreatSeverity.medium,
        icon: Icons.sim_card,
      ),
      ThreatItem(
        title: 'Phishing SMS Detected',
        description: 'Blocked SMS with suspicious link',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        severity: ThreatSeverity.low,
        icon: Icons.message,
      ),
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: threats.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final threat = threats[index];
          return _ThreatTile(threat: threat);
        },
      ),
    );
  }
}

class _ThreatTile extends StatelessWidget {
  final ThreatItem threat;

  const _ThreatTile({required this.threat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color severityColor;
    switch (threat.severity) {
      case ThreatSeverity.high:
        severityColor = Colors.red;
        break;
      case ThreatSeverity.medium:
        severityColor = Colors.orange;
        break;
      case ThreatSeverity.low:
        severityColor = Colors.green;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: severityColor.withOpacity(0.3), width: 1),
          ),
          child: Icon(threat.icon, color: severityColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      threat.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      threat.severity.name.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(threat.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(threat.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum ThreatSeverity { low, medium, high }

class ThreatItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final ThreatSeverity severity;
  final IconData icon;

  ThreatItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.icon,
  });
}
