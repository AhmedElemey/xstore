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

  Map<String, Object?> toJson({
    String? fallbackUserId,
    String? fallbackUserRole,
    String? fallbackScreenName,
  }) {
    final uid = _nonEmpty(userId) ?? _nonEmpty(fallbackUserId);
    final role = _nonEmpty(userRole) ?? _nonEmpty(fallbackUserRole);
    final screen = _nonEmpty(screenName) ??
        _nonEmpty(fallbackScreenName) ??
        '/';
    return {
      'eventId': eventId,
      'name': name,
      // Live ingest DTO binds `EventName` (camelCase `eventName`), not
      // `name`. Sending both keeps the original handoff key and satisfies
      // the collector's [Required] EventName.
      'eventName': name,
      'occurredAt': occurredAt.toIso8601String(),
      'timestamp': occurredAt.toIso8601String(),
      'sessionId': sessionId,
      'deviceId': deviceId,
      if (uid != null) 'userId': uid,
      if (role != null) 'userRole': role,
      'screenName': screen,
      'platform': _platform,
      'properties': _wireProperties(properties),
    };
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Collector binds properties as a string dictionary; nums/bools in the
  /// JSON object fail that bind, leave Properties null, and trip
  /// "missing required fields" on every event in the batch.
  static Map<String, String> _wireProperties(Map<String, Object?> properties) {
    final out = <String, String>{};
    properties.forEach((key, value) {
      if (value == null) return;
      out[key] = switch (value) {
        String s => s,
        bool b => b ? 'true' : 'false',
        num n => n.toString(),
        _ => value.toString(),
      };
    });
    return out;
  }

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
