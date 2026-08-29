import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as the wishlist datasource tests.
class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    final result = _respond(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

DioException _badResponse(
  RequestOptions options,
  int statusCode, {
  Object? data,
}) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
    );

void main() {
  late Dio dio;
  late ProfileRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  group('deleteAccount', () {
    test(
      'DELETEs /api/auth/delete-account with {password, confirmationText}',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return null;
        });
        datasource = ProfileRemoteDataSourceImpl(dio);

        await datasource.deleteAccount(
          password: 'Secret1!',
          confirmationText: 'DELETE',
        );

        expect(captured!.method, 'DELETE');
        expect(captured!.path, ApiEndpoints.deleteAccount);
        expect(captured!.data, {
          'password': 'Secret1!',
          'confirmationText': 'DELETE',
        });
      },
    );

    test(
      'succeeds when the backend returns an empty 200',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio((_) => null);
        datasource = ProfileRemoteDataSourceImpl(dio);

        await expectLater(
          datasource.deleteAccount(
            password: 'Secret1!',
            confirmationText: 'DELETE',
          ),
          completes,
        );
      },
    );

    test(
      'maps a 400 wrong-password body to a ServerException',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio(
          (options) => _badResponse(
            options,
            400,
            data: {
              'isSuccess': false,
              'errorEn': 'Incorrect password.',
            },
          ),
        );
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.deleteAccount(
            password: 'wrong',
            confirmationText: 'DELETE',
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Incorrect password.',
            ),
          ),
        );
      },
    );

    test(
      'maps an already-deleted 400 to a ServerException',
      skip: MockConfig.useMock
          ? 'Requires MOCK=false — MOCK=true short-circuits before Dio'
          : false,
      () async {
        dio = buildDio(
          (options) => _badResponse(
            options,
            400,
            data: {
              'isSuccess': false,
              'errorEn': 'Account already deleted.',
            },
          ),
        );
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.deleteAccount(
            password: 'Secret1!',
            confirmationText: 'DELETE',
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Account already deleted.',
            ),
          ),
        );
      },
    );
  });
}
