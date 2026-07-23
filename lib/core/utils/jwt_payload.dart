import 'dart:convert';

/// Reads a user id claim from a JWT access token payload (best-effort).
///
/// Used when get-profile omits `user.id` but the session token carries it.
String? userIdFromJwt(String? token) {
  if (token == null || token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length < 2) return null;
  try {
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded);
    if (map is! Map) return null;
    const keys = [
      'sub',
      'nameid',
      'userId',
      'id',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/userdata',
    ];
    for (final key in keys) {
      final value = map[key];
      if (value != null) {
        final id = value.toString().trim();
        if (id.isNotEmpty) return id;
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}
