import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Maps a [DioException] to an [AppException], shared across datasources.
///
/// Mirrors the mapping originally inline in `auth_remote_datasource.dart`,
/// plus a 400/422 branch for ASP.NET-style `{"errors": {"Field": ["msg"]}}`
/// validation payloads, joined into a single readable message.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException(
        'Network unavailable. Please check your connection and try again.',
      );
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return UnauthorizedException(e.message);
      }
      if (code == 400 || code == 422) {
        final message = _validationMessage(e.response?.data);
        if (message != null) return ServerException(message);
      }
      return ServerException(e.message);
    default:
      return ServerException(e.message);
  }
}

String? _validationMessage(Object? data) {
  if (data is! Map) return null;
  final errors = data['errors'];
  if (errors is! Map) return null;
  final messages = errors.values
      .expand((v) => v is List ? v.map((x) => x.toString()) : [v.toString()])
      .where((s) => s.isNotEmpty)
      .join('\n');
  return messages.isNotEmpty ? messages : null;
}
