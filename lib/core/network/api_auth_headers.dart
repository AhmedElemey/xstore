import 'package:dio/dio.dart';

/// Static app/tenant license key used on PUBLIC endpoints only (register,
/// login, forgot-password, and GET on reference-data lookups).
///
/// ASSUMPTION (confirm with backend dev): this Basic key is not a per-user
/// credential — HTTP only allows one `Authorization` header value, and the
/// Postman collection shows this same key on every request including
/// clearly user-scoped ones (GET Profile, My Listings), while login/register
/// separately return a `token` unused elsewhere in the collection. The only
/// coherent reading is: this key authenticates PUBLIC endpoints, and is
/// REPLACED by `Authorization: Bearer <token>` on authenticated endpoints
/// (see [authenticated] and the guard in `dio_provider.dart`). If this is
/// wrong, authenticated calls will fail with a clear 401 — that is the
/// signal to revisit this assumption.
abstract final class ApiAuthHeaders {
  static const String _basicLicenseKey =
      'Basic MTEzMTk3Njg6NjAtZGF5ZnJlZXRyaWFs';

  /// Use on calls that do NOT require a signed-in user (register / login /
  /// forgot-password / reference-data GET).
  static Options public() => Options(
        headers: {'Authorization': _basicLicenseKey},
      );

  /// Use on authenticated/user-specific endpoints. No explicit header here —
  /// dio_provider's interceptor injects `Authorization: Bearer <token>`
  /// automatically when a token is stored.
  static Options authenticated() => Options();
}
