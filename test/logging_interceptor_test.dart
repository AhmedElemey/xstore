import 'dart:async';

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

  List<String> capturePrint(void Function() body) {
    final printed = <String>[];
    runZoned(
      body,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printed.add(line);
        },
      ),
    );
    return printed;
  }

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

  test('onRequest redacts Amplitude api_key in the JSON body', () {
    final options = RequestOptions(
      path: '/2/httpapi',
      method: 'POST',
      data: {
        'api_key': 'amplitude-project-write-key',
        'events': [
          {'event_type': 'app_open'},
        ],
      },
    );

    interceptor.onRequest(options, RequestInterceptorHandler());

    final output = logs.join('\n');
    expect(output, isNot(contains('amplitude-project-write-key')));
    expect(output, contains('***REDACTED***'));
    expect(output, contains('app_open'));
  });

  test('onResponse redacts sensitive fields in the response body', () {
    final requestOptions = RequestOptions(path: '/auth/login', method: 'POST');
    final response = Response(
      requestOptions: requestOptions,
      statusCode: 200,
      data: {
        'id': 'user-1',
        'token': 'super-secret-session-token',
        'refreshToken': 'do-not-log-me',
      },
    );

    interceptor.onResponse(response, ResponseInterceptorHandler());

    final output = logs.join('\n');
    expect(output, isNot(contains('super-secret-session-token')));
    expect(output, isNot(contains('do-not-log-me')));
    expect(output, contains('user-1'));
    expect(output, contains('***REDACTED***'));
  });

  test('onRequest expands FormData fields for debug logging', () {
    final options = RequestOptions(
      path: '/api/auth/update-profile',
      method: 'PUT',
      data: FormData.fromMap({
        'birthDate': '1990-03-20',
        'storeDescription': 'Test desc',
        'userImage': MultipartFile.fromString('x', filename: 'a.jpg'),
      }),
    );

    interceptor.onRequest(options, RequestInterceptorHandler());

    final output = logs.join('\n');
    expect(output, contains('birthDate'));
    expect(output, contains('1990-03-20'));
    expect(output, contains('storeDescription'));
    expect(output, contains('Test desc'));
    expect(output, contains('<file:a.jpg>'));
  });

  test('onRequest never prints the Google idToken, only the clientId', () {
    final idToken = 'eyJhbGciOiJSUzI1NiJ9.${'A' * 1600}.sig';
    final options = RequestOptions(
      path: '/api/auth/google/check-user',
      method: 'POST',
      data: {
        'idToken': idToken,
        'clientId': 'web-client.apps.googleusercontent.com',
      },
    );

    final printed = capturePrint(() {
      interceptor.onRequest(options, RequestInterceptorHandler());
    });

    expect(printed.join(), isNot(contains('A' * 100)));
    expect(logs.join(), isNot(contains('A' * 100)));
    expect(logs.first, contains('***REDACTED***'));
    expect(printed, contains('web-client.apps.googleusercontent.com'));
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
