import 'dart:io' show Platform;

import 'analytics_ids.dart';

/// One user-journey event. `properties` values must be JSON-primitive
/// (String/num/bool/null) — the backend contract is a flat JSON map.
class AnalyticsEvent {
  AnalyticsEvent({
    required this.name,
    required this.sessionId,
    required this.deviceId,
    this.userId,
    this.userRole,
    this.screenName,
    Map<String, Object?>? properties,
    DateTime? occurredAt,
    String? eventId,
  })  : eventId = eventId ?? generateEventId(),
        occurredAt = occurredAt ?? DateTime.now().toUtc(),
        properties = properties ?? const {};

  final String eventId;
  final String name;
  final DateTime occurredAt;
  final String sessionId;
  final String deviceId;
  final String? userId;
  final String? userRole;
  final String? screenName;
  final Map<String, Object?> properties;

  static String get _platform {
    try {
      return Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other');
    } catch (_) {
      return 'other';
    }
  }

  Map<String, Object?> toJson() => {
        'eventId': eventId,
        'name': name,
        'occurredAt': occurredAt.toIso8601String(),
        'sessionId': sessionId,
        'deviceId': deviceId,
        'userId': userId,
        'userRole': userRole,
        'screenName': screenName,
        'platform': _platform,
        'properties': properties,
      };

  static AnalyticsEvent? fromJson(Map<String, dynamic> json) {
    try {
      return AnalyticsEvent(
        eventId: json['eventId'] as String?,
        name: json['name'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        sessionId: json['sessionId'] as String,
        deviceId: json['deviceId'] as String,
        userId: json['userId'] as String?,
        userRole: json['userRole'] as String?,
        screenName: json['screenName'] as String?,
        properties: (json['properties'] as Map?)?.cast<String, Object?>() ?? const {},
      );
    } catch (_) {
      // Malformed persisted row (schema drift across app versions) — drop
      // it rather than crash the whole queue load.
      return null;
    }
  }
}
