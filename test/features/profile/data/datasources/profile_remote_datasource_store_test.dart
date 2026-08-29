import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';

class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = _routes[options.path];
    if (route == null) throw StateError('unscripted request: ${options.path}');
    final result = route(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

DioException _notFound(RequestOptions options) => DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: 404),
    );

void main() {
  late Dio dio;
  late ProfileRemoteDataSourceImpl datasource;

  Dio buildDio(Map<String, Object? Function(RequestOptions)> routes) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_RoutedInterceptor(routes));
    return d;
  }

  group('other-vendor store routes', () {
    test(
      'GET /users/{id}/store 404 throws instead of an empty fallback profile',
      () async {
        dio = buildDio({
          '${ApiEndpoints.users}/v1/store': _notFound,
        });
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.getVendorStoreProfile('v1'),
          throwsA(isA<ServerException>()),
        );
      },
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
    );

    test(
      'GET /users/{id}/listings 404 throws instead of an empty list',
      () async {
        dio = buildDio({
          '${ApiEndpoints.users}/v1/listings': _notFound,
        });
        datasource = ProfileRemoteDataSourceImpl(dio);

        expect(
          () => datasource.fetchVendorStoreListings(
            sellerId: 'v1',
            page: 0,
            pageSize: 10,
          ),
          throwsA(isA<ServerException>()),
        );
      },
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
    );
  });
}
