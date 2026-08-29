import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/home/data/datasources/home_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value keyed by
/// path — same scripted-Dio approach as the wishlist/cart datasource
/// tests, extended to route by path since fetchHotDeals internally calls
/// fetchHomeAggregate (GET /api/home) before falling back to GET
/// /api/listings.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;
  final List<RequestOptions> requests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
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

Map<String, dynamic> _activeListing({
  String id = 'listing_1',
  double price = 1000,
  double? compareAtPrice,
}) => {
  'id': id,
  'title': 'Test Listing',
  'status': 2,
  'price': price,
  if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
  'imageUrls': ['https://example.test/a.jpg'],
};

void main() {
  late Dio dio;
  late HomeRemoteDataSourceImpl datasource;

  Dio buildDio(Map<String, Object? Function(RequestOptions)> routes) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_RoutedInterceptor(routes));
    return d;
  }

  group('fetchBanners', () {
    test('GETs /api/banners and parses tolerant field-name variants',
        () async {
      dio = buildDio({
        ApiEndpoints.banners: (_) => [
              {
                'id': 'b1',
                'titleEn': 'Season sale',
                'image': 'https://example.test/b1.jpg',
                'link': 'https://example.test/promo',
              },
              {
                'id': 'b2',
                'nameEn': 'New arrivals',
                'imageUrl': 'https://example.test/b2.jpg',
              },
            ],
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchBanners();

      expect(result, hasLength(2));
      expect(result[0].id, 'b1');
      expect(result[0].title, 'Season sale');
      expect(result[0].imageUrl, 'https://example.test/b1.jpg');
      expect(result[0].actionUrl, 'https://example.test/promo');
      expect(result[1].title, 'New arrivals');
    });

    test('drops entries missing id or image instead of crashing', () async {
      dio = buildDio({
        ApiEndpoints.banners: (_) => [
              {'id': '', 'title': 'No id'},
              {'id': 'b1', 'title': 'No image'},
              {'id': 'b2', 'imageUrl': 'https://example.test/ok.jpg'},
            ],
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchBanners();

      expect(result, hasLength(1));
      expect(result.single.id, 'b2');
    });

    test('falls back to the static set on an empty response', () async {
      dio = buildDio({ApiEndpoints.banners: (_) => <dynamic>[]});
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchBanners();

      expect(result, hasLength(2));
      expect(result.map((b) => b.id), ['b1', 'b2']);
    });

    test('falls back to the static set when offline instead of throwing',
        () async {
      dio = buildDio({
        ApiEndpoints.banners: (options) => _offline(options),
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchBanners();

      expect(result, hasLength(2));
    });

    test('throws (does not fall back) on a non-offline server error',
        () async {
      dio = buildDio({
        ApiEndpoints.banners: (options) => _badResponse(options, 500),
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      expect(
        () => datasource.fetchBanners(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('fetchCategories', () {
    test('GETs /api/categories and reads the nameEn/name/nameAr fallback chain',
        () async {
      dio = buildDio({
        ApiEndpoints.catalogCategories: (_) => [
              {'id': 'c1', 'nameEn': 'Electronics'},
              {'id': 'c2', 'name': 'Fashion'},
              {'id': 'c3', 'nameAr': 'منزل'},
            ],
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchCategories();

      expect(result.map((c) => c.name), ['Electronics', 'Fashion', 'منزل']);
    });

    test('falls back to the static set when offline', () async {
      dio = buildDio({
        ApiEndpoints.catalogCategories: (options) => _offline(options),
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchCategories();

      expect(result, hasLength(4));
    });

    test('throws on a non-offline server error', () async {
      dio = buildDio({
        ApiEndpoints.catalogCategories: (options) => _badResponse(options, 500),
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      expect(
        () => datasource.fetchCategories(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('fetchHomeAggregate', () {
    test('parses all four sections from a populated GET /api/home', () async {
      dio = buildDio({
        ApiEndpoints.home: (_) => {
              'banners': [
                {
                  'id': 'b1',
                  'title': 'Sale',
                  'imageUrl': 'https://example.test/b1.jpg',
                },
              ],
              'hotDeals': [_activeListing(id: 'd1', price: 80, compareAtPrice: 100)],
              'newArrivals': [_activeListing(id: 'd2')],
              'recommendedForYou': [_activeListing(id: 'd3')],
            },
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchHomeAggregate();

      expect(result, isNotNull);
      expect(result!.banners.single.id, 'b1');
      expect(result.hotDeals.single.id, 'd1');
      expect(result.hotDeals.single.discountPercent, 20);
      expect(result.newArrivals.single.id, 'd2');
      expect(result.recommendedForYou.single.id, 'd3');
    });

    test('filters out non-active listings from every section', () async {
      dio = buildDio({
        ApiEndpoints.home: (_) => {
              'banners': <dynamic>[],
              'hotDeals': [
                {..._activeListing(id: 'draft'), 'status': 0},
                _activeListing(id: 'live'),
              ],
              'newArrivals': <dynamic>[],
              'recommendedForYou': <dynamic>[],
            },
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchHomeAggregate();

      expect(result!.hotDeals.map((d) => d.id), ['live']);
    });

    test('returns null when every section is empty', () async {
      dio = buildDio({
        ApiEndpoints.home: (_) => {
              'banners': <dynamic>[],
              'hotDeals': <dynamic>[],
              'newArrivals': <dynamic>[],
              'recommendedForYou': <dynamic>[],
            },
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      expect(await datasource.fetchHomeAggregate(), isNull);
    });

    test('returns null (never throws) on any DioException', () async {
      dio = buildDio({
        ApiEndpoints.home: (options) => _badResponse(options, 500),
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      expect(await datasource.fetchHomeAggregate(), isNull);
    });
  });

  group('fetchHotDeals', () {
    test('uses the aggregate\'s hotDeals when present, without calling /api/listings',
        () async {
      var listingsCalled = false;
      final interceptor = _RoutedInterceptor({
        ApiEndpoints.home: (_) => {
              'banners': <dynamic>[],
              'hotDeals': [_activeListing(id: 'from_aggregate')],
              'newArrivals': <dynamic>[],
              'recommendedForYou': <dynamic>[],
            },
        ApiEndpoints.apiListings: (_) {
          listingsCalled = true;
          return <dynamic>[];
        },
      });
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..interceptors.add(interceptor);
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchHotDeals();

      expect(result.single.id, 'from_aggregate');
      expect(
        listingsCalled,
        isFalse,
        reason: 'should not derive from /api/listings when the aggregate has data',
      );
    });

    test('derives from /api/listings sorted by discount when the aggregate is empty',
        () async {
      dio = buildDio({
        ApiEndpoints.home: (_) => {
              'banners': <dynamic>[],
              'hotDeals': <dynamic>[],
              'newArrivals': <dynamic>[],
              'recommendedForYou': <dynamic>[],
            },
        ApiEndpoints.apiListings: (_) => [
              _activeListing(id: 'small_discount', price: 90, compareAtPrice: 100),
              _activeListing(id: 'big_discount', price: 50, compareAtPrice: 100),
              _activeListing(id: 'no_discount', price: 100),
            ],
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchHotDeals();

      expect(result.map((d) => d.id), ['big_discount', 'small_discount', 'no_discount']);
    });

    test('falls back to static deals when offline on the /api/listings derivation',
        () async {
      dio = buildDio({
        ApiEndpoints.home: (options) => _offline(options),
        ApiEndpoints.apiListings: (options) => _offline(options),
      });
      datasource = HomeRemoteDataSourceImpl(dio);

      final result = await datasource.fetchHotDeals();

      expect(result, hasLength(2));
    });
  });
}
