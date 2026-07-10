import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only request/response logger. Redacts auth headers and known
/// sensitive body fields (passwords, tokens, OTP codes) so secrets never
/// end up in device logs.
class LoggingInterceptor extends Interceptor {
  static const _startTimeKey = '_logging_interceptor_start_time';

  static const _redactedHeaderKeys = {
    'authorization',
    'x-auth-token',
    'cookie',
    'set-cookie',
  };

  static const _redactedBodyKeys = {
    'password',
    'confirmpassword',
    'token',
    'accesstoken',
    'idtoken',
    'refreshtoken',
    'firebaseidtoken',
    'otpcode',
    'smscode',
  };

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now();
    final buffer = StringBuffer()
      ..writeln('┌─ REQUEST ${options.method} ${options.uri}')
      ..writeln('│ headers: ${_redact(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ query: ${_redact(options.queryParameters)}');
    }
    if (options.data != null) {
      buffer.writeln('│ body: ${_pretty(_redact(options.data))}');
    }
    buffer.write('└─');
    debugPrint(buffer.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final ms = _elapsedMs(response.requestOptions);
    final buffer = StringBuffer()
      ..writeln(
        '┌─ RESPONSE ${response.requestOptions.method} '
        '${response.requestOptions.uri} → ${response.statusCode}'
        '${ms != null ? ' (${ms}ms)' : ''}',
      )
      ..writeln('│ body: ${_pretty(_redact(response.data))}')
      ..write('└─');
    debugPrint(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ms = _elapsedMs(err.requestOptions);
    final buffer = StringBuffer()
      ..writeln(
        '┌─ ERROR ${err.requestOptions.method} ${err.requestOptions.uri} '
        '→ ${err.response?.statusCode ?? err.type}'
        '${ms != null ? ' (${ms}ms)' : ''}',
      )
      ..writeln('│ message: ${err.message}');
    if (err.response?.data != null) {
      buffer.writeln('│ body: ${_pretty(_redact(err.response!.data))}');
    }
    buffer.write('└─');
    debugPrint(buffer.toString());
    handler.next(err);
  }

  int? _elapsedMs(RequestOptions options) {
    final start = options.extra[_startTimeKey] as DateTime?;
    return start == null ? null : DateTime.now().difference(start).inMilliseconds;
  }

  String _pretty(dynamic data) {
    try {
      return _encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  dynamic _redact(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final isSensitive = _redactedHeaderKeys.contains(key.toString().toLowerCase()) ||
            _redactedBodyKeys.contains(key.toString().toLowerCase());
        return MapEntry(key, isSensitive ? '***REDACTED***' : _redact(value));
      });
    }
    if (data is List) {
      return data.map(_redact).toList();
    }
    return data;
  }
}
