import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/dio_error_mapper.dart';

DioException _badResponse(int code, Object? data) {
  final req = RequestOptions(path: '/x');
  return DioException.badResponse(
    statusCode: code,
    requestOptions: req,
    response: Response<Object?>(
      requestOptions: req,
      statusCode: code,
      data: data,
    ),
  );
}

void main() {
  tearDown(() => errorMessagesInArabic = false);

  test('bad response without a body never exposes raw Dio text', () {
    for (final code in [400, 404, 500]) {
      final e = _badResponse(code, null);
      expect(e.message, contains('validateStatus'));
      final mapped = mapDioException(e);
      expect(mapped.toString(), isNot(contains('validateStatus')));
      expect(mapped.toString(), isNot(contains('RequestOptions')));
      expect(mapped.toString(), 'Something went wrong. Please try again.');
    }
  });

  test('401 without a body and unknown error types use the friendly text', () {
    expect(
      mapDioException(_badResponse(401, null)).toString(),
      isNot(contains('validateStatus')),
    );
    final unknown = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.unknown,
      message: 'SocketException: raw',
    );
    expect(mapDioException(unknown).toString(), isNot(contains('raw')));
  });

  test('fallback is Arabic when the app is in Arabic', () {
    errorMessagesInArabic = true;
    final text = mapDioException(_badResponse(400, null)).toString();
    expect(text, isNot(contains('validateStatus')));
    expect(text, isNot('Something went wrong. Please try again.'));
  });

  test('server-provided message still wins', () {
    expect(
      mapDioException(_badResponse(500, {'message': 'Boom'})).toString(),
      'Boom',
    );
  });
}
