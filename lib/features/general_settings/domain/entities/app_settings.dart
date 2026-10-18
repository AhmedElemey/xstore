import 'dart:convert';

import 'package:flutter/foundation.dart';

/// The admin-managed General Settings (`GET /api/general-settings`), keyed by
/// setting key. Every row the backend returns is kept; callers read the keys
/// they need.
@immutable
class AppSettings {
  const AppSettings(this._rows);

  /// Rows as `{key: (value, dataType)}`; both stay as sent so the set can be
  /// cached and compared without loss.
  final Map<String, ({String value, String dataType})> _rows;

  static const empty = AppSettings({});

  bool get isEmpty => _rows.isEmpty;

  /// The value as sent, whatever its `dataType`; null when the key is absent.
  String? raw(String key) => _rows[key]?.value;

  /// The value parsed by `dataType`: String -> String, Boolean -> bool,
  /// Number/Int/Integer/Decimal/Double -> num, Json -> decoded. An unknown
  /// type or an unparseable value reads as the raw string.
  Object? value(String key) {
    final row = _rows[key];
    if (row == null) return null;
    final raw = row.value;
    switch (row.dataType.trim().toLowerCase()) {
      case 'boolean' || 'bool':
        return switch (raw.trim().toLowerCase()) {
          'true' => true,
          'false' => false,
          _ => raw,
        };
      case 'number' || 'int' || 'integer' || 'decimal' || 'double':
        return num.tryParse(raw.trim()) ?? raw;
      case 'json':
        try {
          return jsonDecode(raw);
        } on FormatException {
          return raw;
        }
      default:
        return raw;
    }
  }

  String? string(String key) {
    final v = value(key);
    return v is String ? v : null;
  }

  bool? boolean(String key) {
    final v = value(key);
    return v is bool ? v : null;
  }

  num? number(String key) {
    final v = value(key);
    return v is num ? v : null;
  }

  /// Builds the set from `items` rows (`{key, value, dataType}`); rows
  /// without a key are skipped, a later row overwrites an earlier one.
  factory AppSettings.fromItems(Iterable<dynamic> items) {
    final rows = <String, ({String value, String dataType})>{};
    for (final item in items.whereType<Map>()) {
      final key = item['key']?.toString();
      if (key == null || key.isEmpty) continue;
      rows[key] = (
        value: item['value']?.toString() ?? '',
        dataType: item['dataType']?.toString() ?? 'String',
      );
    }
    return AppSettings(rows);
  }

  /// Cache form: the same `{key, value, dataType}` rows [fromItems] reads.
  String toJson() => jsonEncode([
    for (final e in _rows.entries)
      {'key': e.key, 'value': e.value.value, 'dataType': e.value.dataType},
  ]);

  /// The cached set, or null when [source] is missing/corrupt. A stored `[]`
  /// is a valid empty set; rows of which none parse are corrupt.
  static AppSettings? tryFromJson(String? source) {
    if (source == null) return null;
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return null;
      final settings = AppSettings.fromItems(decoded);
      return decoded.isNotEmpty && settings.isEmpty ? null : settings;
    } on FormatException {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings && mapEquals(_rows, other._rows);

  @override
  int get hashCode => Object.hashAllUnordered(
    _rows.entries.map((e) => Object.hash(e.key, e.value)),
  );
}
