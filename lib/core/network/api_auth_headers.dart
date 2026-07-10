import 'package:dio/dio.dart';

/// CONFIRMED against a live backend (was previously an unverified
/// assumption — see git history for the old theory, which was wrong): the
/// static Basic license key is sent on EVERY request, public or
/// authenticated alike, and is set once as a default header in
/// `dio_provider.dart`. Per-user auth is a completely separate
/// `X-Auth-Token: <token>` header (NOT `Authorization: Bearer <token>`),
/// injected automatically by `dio_provider.dart`'s interceptor whenever a
/// token is stored.
///
/// [public] and [authenticated] are now functionally identical (both are
/// no-ops — the real headers are set centrally in `dio_provider.dart`) but
/// are kept as distinct call sites throughout the codebase to document
/// *intent* per endpoint (whether it conceptually requires a signed-in
/// user), even though nothing here enforces that anymore.
abstract final class ApiAuthHeaders {
  static const String basicLicenseKey =
      'Basic MTEzMTk3Njg6NjAtZGF5ZnJlZXRyaWFs';

  /// Endpoints that don't require a signed-in user (register / login /
  /// forgot-password / reference-data GET). No-op — see class doc.
  static Options public() => Options();

  /// Endpoints that require a signed-in user. No-op — see class doc.
  static Options authenticated() => Options();
}
