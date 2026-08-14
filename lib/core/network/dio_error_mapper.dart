import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import 'app_error_messages.dart';

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
      final serverMessage = _serverErrorMessage(e.response?.data);
      if (code == 401 || code == 403) {
        // CONFIRMED (live probe, 2026-08-14): POST /api/listings 403s with
        // this exact text when the vendor's store has no saved lat/lng —
        // a distinct, actionable case (route to the location step) rather
        // than a generic "unauthorized".
        if (serverMessage != null &&
            serverMessage.toLowerCase().contains('store location')) {
          return const ServerException(storeLocationRequiredErrorCode);
        }
        return UnauthorizedException(serverMessage ?? e.message);
      }
      if (code == 429) {
        return const ServerException(rateLimitErrorCode);
      }
      if (code == 400 || code == 422) {
        // CONFIRMED (live probe, 2026-08-14): POST /api/orders 400s with
        // this exact text for a consumer who hasn't verified their phone —
        // a distinct, actionable case the app should route to phone
        // verification rather than show as a generic failure.
        if (serverMessage != null &&
            serverMessage.toLowerCase().contains('verify your phone')) {
          return const ServerException(phoneNotVerifiedErrorCode);
        }
        final message =
            _validationMessage(e.response?.data) ?? serverMessage;
        if (message != null) return ServerException(message);
      }
      return ServerException(_friendlyServerMessage(code, serverMessage) ?? e.message);
    default:
      return ServerException(e.message);
  }
}

/// Reads a human-readable message from common xStore API error bodies:
/// `{"error": "..."}`, `{"message": "..."}`, `{"error": {"message": "..."}}`,
/// or the CONFIRMED (live probe, 2026-08-14) envelope
/// `{"isSuccess": false, "data": null, "errorEn": "...", "errorAr": "..."}`.
/// `errorEn` is checked first since the mapper has no locale context here.
String? _serverErrorMessage(Object? data) {
  if (data is! Map) return null;
  final errorEn = data['errorEn'];
  if (errorEn is String && errorEn.isNotEmpty) return errorEn;
  final error = data['error'];
  if (error is String && error.isNotEmpty) return error;
  if (error is Map) {
    final nested = error['message'];
    if (nested is String && nested.isNotEmpty) return nested;
  }
  final message = data['message'];
  if (message is String && message.isNotEmpty) return message;
  final errorAr = data['errorAr'];
  if (errorAr is String && errorAr.isNotEmpty) return errorAr;
  return null;
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

/// ASP.NET EF Core SaveChanges failures return opaque boilerplate — replace
/// with actionable text the listing/checkout UI can show as-is.
String? _friendlyServerMessage(int? code, String? serverMessage) {
  if (serverMessage == null || serverMessage.isEmpty) return serverMessage;
  if (serverMessage.contains('saving the entity changes')) {
    return 'The server could not save your changes. Please try again later.';
  }
  return serverMessage;
}
