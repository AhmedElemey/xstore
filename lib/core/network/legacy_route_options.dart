import 'package:dio/dio.dart';

/// Dio options for legacy routes that may return 404 until the backend ships
/// them. Accepts 404 as a normal response (no [DioException]) and tags the
/// request so [LoggingInterceptor] stays quiet.
abstract final class LegacyRouteOptions {
  static const String suppressNotFoundLogKey = 'suppress_legacy_404_log';

  /// Only 404 is tolerated on top of success statuses. 401/403 must still
  /// throw — TokenRefreshInterceptor refreshes via onError only, so
  /// accepting them here would silently bypass token refresh and render
  /// an expired session as "empty data".
  static Options allowNotFound({Map<String, dynamic>? extra}) => Options(
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) || status == 404),
        extra: {
          suppressNotFoundLogKey: true,
          ...?extra,
        },
      );

  static bool isNotFound(Response<dynamic>? response) =>
      response?.statusCode == 404;
}
