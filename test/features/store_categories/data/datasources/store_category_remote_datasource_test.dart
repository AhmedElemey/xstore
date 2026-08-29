import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/store_categories/data/datasources/store_category_remote_datasource.dart';

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

DioException _badResponse(RequestOptions options, int statusCode) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: statusCode),
    );

DioException _offline(RequestOptions options) => DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );

void main() {
  late Dio dio;
  late StoreCategoryRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  group('getStoreCategories', () {
    test(
      'GETs /api/storecategories and parses the {items, totalCount} envelope',
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return {
            'items': [
              {'id': 1, 'nameEn': 'Electronics', 'nameAr': 'إلكترونيات'},
              {'id': 2, 'nameEn': 'Fashion', 'nameAr': 'أزياء'},
            ],
            'totalCount': 12,
            'page': 1,
            'pageSize': 2,
            'totalPages': 6,
          };
        });
        datasource = StoreCategoryRemoteDataSourceImpl(dio);

        final result = await datasource.getStoreCategories(
          page: 1,
          pageSize: 2,
        );

        expect(captured!.method, 'GET');
        expect(captured!.path, ApiEndpoints.storeCategories);
        expect(captured!.queryParameters, {'page': 1, 'pageSize': 2});
        expect(result.items, hasLength(2));
        expect(result.items.first.id, 1);
        expect(result.items.first.nameEn, 'Electronics');
        expect(result.items.first.nameAr, 'إلكترونيات');
        expect(result.items.last.nameEn, 'Fashion');
        expect(result.totalCount, 12);
      },
    );

    test('falls back to items.length when totalCount is omitted', () async {
      dio = buildDio(
        (_) => {
          'items': [
            {'id': 3, 'nameEn': 'Home', 'nameAr': 'منزل'},
          ],
        },
      );
      datasource = StoreCategoryRemoteDataSourceImpl(dio);

      final result = await datasource.getStoreCategories(page: 1, pageSize: 20);

      expect(result.items.single.nameEn, 'Home');
      expect(result.totalCount, 1);
    });

    test('treats a missing items key as an empty list', () async {
      dio = buildDio((_) => {'totalCount': 0});
      datasource = StoreCategoryRemoteDataSourceImpl(dio);

      final result = await datasource.getStoreCategories(page: 1, pageSize: 20);

      expect(result.items, isEmpty);
      expect(result.totalCount, 0);
    });

    test('throws ServerException on a null response body', () async {
      dio = buildDio((_) => null);
      datasource = StoreCategoryRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getStoreCategories(page: 1, pageSize: 20),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps a 500 response to a ServerException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = StoreCategoryRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getStoreCategories(page: 1, pageSize: 20),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps a connection error to a NetworkException', () async {
      dio = buildDio(_offline);
      datasource = StoreCategoryRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getStoreCategories(page: 1, pageSize: 20),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
