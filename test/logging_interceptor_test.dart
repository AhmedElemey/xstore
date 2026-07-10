import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/logging_interceptor.dart';

void main() {
  late List<String> logs;
  late DebugPrintCallback originalDebugPrint;
  late LoggingInterceptor interceptor;

  setUp(() {
    logs = [];
    originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    interceptor = LoggingInterceptor();
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
  });

  test('onRequest redacts Authorization header and sensitive body fields', () {
    final options = RequestOptions(
      path: '/auth/login',
      method: 'POST',
      headers: {
        'Authorization': 'Bearer secret-token',
        'X-Auth-Token': 'per-user-session-token',
        'Accept': 'application/json',
      },
      data: {
        'email': 'a@b.com',
        'password': 'hunter2',
        'token': 'abc123',
      },
    );

    interceptor.onRequest(options, RequestInterceptorHandler());

    final output = logs.join('\n');
    expect(output, isNot(contains('secret-token')));
    expect(output, isNot(contains('per-user-session-token')));
    expect(output, isNot(contains('hunter2')));
    expect(output, isNot(contains('abc123')));
    expect(output, contains('***REDACTED***'));
    expect(output, contains('a@b.com'));
  });

  test('onResponse redacts sensitive fields in the response body', () {
    final requestOptions = RequestOptions(path: '/auth/login', method: 'POST');
    final response = Response(
      requestOptions: requestOptions,
      statusCode: 200,
      data: {
        'id': 'user-1',
        'token': 'super-secret-session-token',
        'idToken': 'firebase-secret',
      },
    );

    interceptor.onResponse(response, ResponseInterceptorHandler());

    final output = logs.join('\n');
    expect(output, isNot(contains('super-secret-session-token')));
    expect(output, isNot(contains('firebase-secret')));
    expect(output, contains('user-1'));
    expect(output, contains('***REDACTED***'));
  });

  test('onError redacts sensitive fields in the error response body', () {
    final requestOptions = RequestOptions(path: '/auth/social', method: 'POST');
    final err = DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 401,
        data: {'message': 'invalid', 'refreshToken': 'do-not-log-me'},
      ),
    );

    final handler = ErrorInterceptorHandler();
    // `next()` always rejects the handler's internal completer (that's how
    // dio propagates errors along the interceptor chain) — nothing here
    // needs to consume it, so mark it ignored to avoid an unhandled-error
    // report in the test zone.
    // ignore: invalid_use_of_protected_member
    handler.future.ignore();
    interceptor.onError(err, handler);

    final output = logs.join('\n');
    expect(output, isNot(contains('do-not-log-me')));
    expect(output, contains('***REDACTED***'));
  });
}
