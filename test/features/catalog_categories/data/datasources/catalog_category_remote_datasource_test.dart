import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/mock/mock_reference_data.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/catalog_categories/data/datasources/catalog_category_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as the wishlist/store-category
/// datasource tests.
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

Map<String, dynamic> _row({
  Object id = 7,
  String nameEn = 'Automotive',
  String nameAr = 'السيارات',
  List<dynamic>? children,
}) =>
    {
      'id': id,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'children': children ?? <dynamic>[],
    };

void main() {
  late Dio dio;
  late CatalogCategoryRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  final skipMock = MockConfig.useMock
      ? 'MockConfig.useMock short-circuits Dio'
      : false;

  group('getCategories (live Dio path)', () {
    test('GETs /api/categories and unwraps an {items} envelope', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          'items': [
            _row(),
            _row(id: 4, nameEn: 'Beauty', nameAr: 'الجمال'),
          ],
        };
      });
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      final result = await datasource.getCategories();

      expect(captured!.method, 'GET');
      expect(captured!.path, ApiEndpoints.catalogCategories);
      expect(result.map((e) => e.nameEn), ['Automotive', 'Beauty']);
    });

    test('unwraps a {data} envelope', () async {
      dio = buildDio((_) => {
            'data': [_row()],
          });
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      final result = await datasource.getCategories();

      expect(result.single.nameEn, 'Automotive');
    });

    test('unwraps a {results} envelope', () async {
      dio = buildDio((_) => {
            'results': [_row(id: 9, nameEn: 'Books', nameAr: 'كتب')],
          });
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      final result = await datasource.getCategories();

      expect(result.single.id, 9);
      expect(result.single.nameEn, 'Books');
    });

    test('drops rows whose id is 0 (unset backend enum / missing id)',
        () async {
      dio = buildDio(
        (_) => [
          _row(id: 0, nameEn: 'Unset'),
          _row(),
        ],
      );
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      final result = await datasource.getCategories();

      expect(result.map((e) => e.id), [7]);
    });

    test('a null or non-list body yields an empty list', () async {
      dio = buildDio((_) => null);
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(await datasource.getCategories(), isEmpty);

      dio = buildDio((_) => {'totalCount': 0});
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(await datasource.getCategories(), isEmpty);
    });

    test('an empty or malformed JSON string body yields an empty list',
        () async {
      dio = buildDio((_) => '   ');
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(await datasource.getCategories(), isEmpty);

      dio = buildDio((_) => 'not-json');
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(await datasource.getCategories(), isEmpty);
    });

    test('maps a 500 response to a ServerException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getCategories(),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps a 401 response to an UnauthorizedException', () async {
      dio = buildDio((options) => _badResponse(options, 401));
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getCategories(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('maps a connection error to a NetworkException', () async {
      dio = buildDio(_offline);
      datasource = CatalogCategoryRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getCategories(),
        throwsA(isA<NetworkException>()),
      );
    });
  }, skip: skipMock);

  test(
    'returns mock catalog when MOCK=true without hitting Dio',
    skip: MockConfig.useMock ? false : 'Requires --dart-define=MOCK=true',
    () async {
      final ds = CatalogCategoryRemoteDataSourceImpl(Dio());

      final models = await ds.getCategories();

      expect(models, MockReferenceData.catalogCategories);
    },
  );
}
