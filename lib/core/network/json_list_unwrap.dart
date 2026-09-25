import 'dart:convert';

/// Pulls a list of JSON objects from a live list body.
///
/// Endpoints disagree on shape: `/api/governorates` and `/api/cities` return
/// a **bare array**, others wrap rows in `{items|data|results|listings: [...]}`.
/// Accept all of them so a wrapper flip doesn't empty the screen.
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
    final nested = data['items'] ??
        data['data'] ??
        data['results'] ??
        data['listings'];
    if (nested is List) return unwrapJsonObjectList(nested);
  }
  return const [];
}

/// Reads a JSON number (or numeric string) as a finite double; anything else,
/// including `NaN`/`Infinity` (which `double.tryParse` accepts), reads as 0.
double jsonDouble(Object? value) {
  final d = value is num ? value.toDouble() : double.tryParse('${value ?? ''}');
  return d != null && d.isFinite ? d : 0;
}
