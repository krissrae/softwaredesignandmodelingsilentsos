import 'user.dart';
import 'risk_area.dart';

enum AlertType {
  sos('SOS');

  const AlertType(this.value);
  final String value;

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => AlertType.sos,
    );
  }

  @override
  String toString() => value;
}

class Alert {
  final int id;
  final User user;
  final AlertType alertType;
  final DateTime timestamp;
  final RiskArea? riskArea;
  final String? locationLink;
  final String? audioUrl;
  final double credibilityScore;

  Alert({
    required this.id,
    required this.user,
    required this.alertType,
    required this.timestamp,
    this.riskArea,
    this.locationLink,
    this.audioUrl,
    required this.credibilityScore,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['id'] == null || json['user'] == null) {
      throw Exception('Alert missing required fields: id or user');
    }

    return Alert(
      id: (json['id'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      alertType: AlertType.fromString(json['alert_type']?.toString() ?? 'SOS'),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      riskArea: json['risk_area'] != null
          ? RiskArea.fromJson(json['risk_area'] as Map<String, dynamic>)
          : null,
      locationLink: json['location_link']?.toString(),
      audioUrl: json['audio']?.toString(),
      credibilityScore: (json['credibility_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'alert_type': alertType.value,
      'timestamp': timestamp.toIso8601String(),
      'risk_area': riskArea?.toJson(),
      'location_link': locationLink,
      'audio': audioUrl,
      'credibility_score': credibilityScore,
    };
  }

  // Convenience getters for backward compatibility
  int get userId => user.id;
  int? get riskAreaId => riskArea?.id;

  // Utility methods
  bool get isHighCredibility => credibilityScore >= 0.8;
  bool get isMediumCredibility => credibilityScore >= 0.5 && credibilityScore < 0.8;
  bool get isLowCredibility => credibilityScore < 0.5;

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasLocation => locationLink != null && locationLink!.isNotEmpty;
  bool get hasRiskArea => riskArea != null;

  Duration get timeSinceAlert => DateTime.now().difference(timestamp);
  bool get isRecent => timeSinceAlert.inHours < 24;

  String get formattedTimestamp =>
      '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

  String get credibilityLevel {
    if (isHighCredibility) return 'High';
    if (isMediumCredibility) return 'Medium';
    return 'Low';
  }

  // User-related convenience methods
  String get userEmail => user.email;
  bool get isUserActive => user.isActive;
  bool get isUserStaff => user.isStaff;

  // Risk area-related convenience methods
  String? get riskAreaName => riskArea?.name;
  String? get riskAreaDescription => riskArea?.description;
  double? get riskAreaLatitude => riskArea?.latitude;
  double? get riskAreaLongitude => riskArea?.longitude;
  double? get riskAreaRadius => riskArea?.radius;

  // Create a copy with updated fields
  Alert copyWith({
    int? id,
    User? user,
    AlertType? alertType,
    DateTime? timestamp,
    RiskArea? riskArea,
    String? locationLink,
    String? audioUrl,
    double? credibilityScore,
  }) {
    return Alert(
      id: id ?? this.id,
      user: user ?? this.user,
      alertType: alertType ?? this.alertType,
      timestamp: timestamp ?? this.timestamp,
      riskArea: riskArea ?? this.riskArea,
      locationLink: locationLink ?? this.locationLink,
      audioUrl: audioUrl ?? this.audioUrl,
      credibilityScore: credibilityScore ?? this.credibilityScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Alert(id: $id, user: ${user.email}, alertType: ${alertType.value}, '
        'timestamp: $formattedTimestamp, credibility: $credibilityLevel, '
        'riskArea: ${riskArea?.name ?? 'None'})';
  }
}