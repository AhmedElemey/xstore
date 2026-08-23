import 'dart:convert';

/// Pulls a list of JSON objects from a live reference-data body.
///
/// Confirmed 2026-08-23: `/api/governorates` and `/api/cities` return a
/// **bare array**. Older seeds wrapped the same rows in
/// `{items|data|results: [...]}`. Accept both so a wrapper flip doesn't
/// empty the picker.
List<Map<String, dynamic>> unwrapJsonObjectList(dynamic data) {
  if (data is String) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return const [];
    try {
      return unwrapJsonObjectList(jsonDecode(trimmed));
    } catch (_) {
      return const [];
    }
  }
  if (data is List) {
    return [
      for (final row in data)
        if (row is Map) Map<String, dynamic>.from(row),
    ];
  }
  if (data is Map) {
    final nested = data['items'] ?? data['data'] ?? data['results'];
    if (nested is List) return unwrapJsonObjectList(nested);
  }
  return const [];
}
