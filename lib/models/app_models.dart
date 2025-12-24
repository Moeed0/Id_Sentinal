class ThreatAlert {
  final String id;
  final String title;
  final String description;
  final ThreatType type;
  final ThreatSeverity severity;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  ThreatAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.toString(),
        'severity': severity.toString(),
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'metadata': metadata,
      };

  factory ThreatAlert.fromJson(Map<String, dynamic> json) => ThreatAlert(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: ThreatType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        severity: ThreatSeverity.values.firstWhere(
          (e) => e.toString() == json['severity'],
        ),
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'] ?? false,
        metadata: json['metadata'],
      );
}

enum ThreatType {
  cnicMisuse,
  documentForgery,
  dataLeak,
  photoMisuse,
  deepfake,
  riskyApp,
  phishingSms,
}

enum ThreatSeverity {
  low,
  medium,
  high,
  critical,
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<String> monitoredCnics;
  final bool isPremium;
  final DateTime createdAt;
  final Map<String, bool> preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.monitoredCnics = const [],
    this.isPremium = false,
    required this.createdAt,
    this.preferences = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'monitoredCnics': monitoredCnics,
        'isPremium': isPremium,
        'createdAt': createdAt.toIso8601String(),
        'preferences': preferences,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        monitoredCnics: List<String>.from(json['monitoredCnics'] ?? []),
        isPremium: json['isPremium'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        preferences: Map<String, bool>.from(json['preferences'] ?? {}),
      );
}

class CnicActivity {
  final String id;
  final String cnic;
  final String activityType;
  final String company;
  final String description;
  final DateTime timestamp;
  final ActivityStatus status;
  final String? location;
  final bool isAuthorized;

  CnicActivity({
    required this.id,
    required this.cnic,
    required this.activityType,
    required this.company,
    required this.description,
    required this.timestamp,
    required this.status,
    this.location,
    this.isAuthorized = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cnic': cnic,
        'activityType': activityType,
        'company': company,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'status': status.toString(),
        'location': location,
        'isAuthorized': isAuthorized,
      };

  factory CnicActivity.fromJson(Map<String, dynamic> json) => CnicActivity(
        id: json['id'],
        cnic: json['cnic'],
        activityType: json['activityType'],
        company: json['company'],
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
        status: ActivityStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
        ),
        location: json['location'],
        isAuthorized: json['isAuthorized'] ?? false,
      );
}

enum ActivityStatus {
  pending,
  approved,
  blocked,
  warning,
}

class DocumentAnalysis {
  final String id;
  final String documentType;
  final String imageUrl;
  final bool isForgery;
  final double confidenceScore;
  final List<Finding> findings;
  final DateTime analyzedAt;
  final String? recommendation;

  DocumentAnalysis({
    required this.id,
    required this.documentType,
    required this.imageUrl,
    required this.isForgery,
    required this.confidenceScore,
    required this.findings,
    required this.analyzedAt,
    this.recommendation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'documentType': documentType,
        'imageUrl': imageUrl,
        'isForgery': isForgery,
        'confidenceScore': confidenceScore,
        'findings': findings.map((f) => f.toJson()).toList(),
        'analyzedAt': analyzedAt.toIso8601String(),
        'recommendation': recommendation,
      };

  factory DocumentAnalysis.fromJson(Map<String, dynamic> json) =>
      DocumentAnalysis(
        id: json['id'],
        documentType: json['documentType'],
        imageUrl: json['imageUrl'],
        isForgery: json['isForgery'],
        confidenceScore: json['confidenceScore'],
        findings:
            (json['findings'] as List).map((f) => Finding.fromJson(f)).toList(),
        analyzedAt: DateTime.parse(json['analyzedAt']),
        recommendation: json['recommendation'],
      );
}

class Finding {
  final String type;
  final String title;
  final String description;
  final FindingStatus status;
  final double? score;

  Finding({
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.score,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'description': description,
        'status': status.toString(),
        'score': score,
      };

  factory Finding.fromJson(Map<String, dynamic> json) => Finding(
        type: json['type'],
        title: json['title'],
        description: json['description'],
        status: FindingStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
        ),
        score: json['score'],
      );
}

enum FindingStatus {
  pass,
  warning,
  fail,
}

class DataLeak {
  final String id;
  final String identifier;
  final String identifierType; // cnic, email, phone
  final List<LeakSource> sources;
  final DateTime discoveredAt;
  final bool hasBeenNotified;
  final String severity;

  DataLeak({
    required this.id,
    required this.identifier,
    required this.identifierType,
    required this.sources,
    required this.discoveredAt,
    this.hasBeenNotified = false,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'identifier': identifier,
        'identifierType': identifierType,
        'sources': sources.map((s) => s.toJson()).toList(),
        'discoveredAt': discoveredAt.toIso8601String(),
        'hasBeenNotified': hasBeenNotified,
        'severity': severity,
      };

  factory DataLeak.fromJson(Map<String, dynamic> json) => DataLeak(
        id: json['id'],
        identifier: json['identifier'],
        identifierType: json['identifierType'],
        sources: (json['sources'] as List)
            .map((s) => LeakSource.fromJson(s))
            .toList(),
        discoveredAt: DateTime.parse(json['discoveredAt']),
        hasBeenNotified: json['hasBeenNotified'] ?? false,
        severity: json['severity'],
      );
}

class LeakSource {
  final String name;
  final String url;
  final DateTime breachDate;
  final List<String> dataTypes;

  LeakSource({
    required this.name,
    required this.url,
    required this.breachDate,
    required this.dataTypes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'breachDate': breachDate.toIso8601String(),
        'dataTypes': dataTypes,
      };

  factory LeakSource.fromJson(Map<String, dynamic> json) => LeakSource(
        name: json['name'],
        url: json['url'],
        breachDate: DateTime.parse(json['breachDate']),
        dataTypes: List<String>.from(json['dataTypes']),
      );
}
