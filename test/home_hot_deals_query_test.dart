import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/home/data/datasources/home_remote_datasource.dart';
import 'package:xstore/features/home/data/repositories/home_repository_impl.dart';

Map<String, dynamic> _listing(int id, {double? compareAt, int? stock}) => {
  'id': id,
  'title': 'Item $id',
  'price': 100.0,
  'compareAtPrice': ?compareAt,
  'stockQuantity': ?stock,
  'status': 2,
};

/// Answers `/api/home` and `/api/listings`, recording each query.
class _Interceptor extends Interceptor {
  _Interceptor({required this.home, required this.listings});

  final dynamic home;
  final dynamic Function(Map<String, dynamic> query) listings;
  final listingQueries = <Map<String, dynamic>>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == '/api/home') {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: home),
      );
      return;
    }
    listingQueries.add(options.queryParameters);
    final data = listings(options.queryParameters);
    if (data is DioException) {
      handler.reject(data.copyWith(requestOptions: options));
      return;
    }
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: data),
    );
  }
}

void main() {
  final skip = MockConfig.useMock
      ? 'MOCK=true short-circuits the request'
      : null;

  test('empty home hotDeals asks the server for isHotDeal listings', () async {
    final interceptor = _Interceptor(
      home: {'hotDeals': <dynamic>[]},
      listings: (_) => {
        'items': [_listing(1, compareAt: 200)],
      },
    );
    final dio = Dio()..interceptors.add(interceptor);

    final deals = await HomeRemoteDataSourceImpl(dio).fetchHotDeals();

    expect(interceptor.listingQueries, [
      {'page': 1, 'pageSize': 40, 'isHotDeal': true},
    ]);
    expect(deals.map((d) => d.id), ['1']);
    expect(deals.single.discountPercent, 50);
  }, skip: skip);

  test('no flagged deals falls back to deriving from compareAtPrice', () async {
    final interceptor = _Interceptor(
      home: {'hotDeals': <dynamic>[]},
      listings: (query) => query.containsKey('isHotDeal')
          ? {'items': <dynamic>[]}
          : {
              'items': [
                _listing(1, compareAt: 120),
                _listing(2, compareAt: 200),
              ],
            },
    );
    final dio = Dio()..interceptors.add(interceptor);

    final deals = await HomeRemoteDataSourceImpl(dio).fetchHotDeals();

    expect(interceptor.listingQueries, [
      {'page': 1, 'pageSize': 40, 'isHotDeal': true},
      {'page': 1, 'pageSize': 40},
    ]);
    // Biggest discount first.
    expect(deals.map((d) => d.id), ['2', '1']);
  }, skip: skip);

  test(
    'a rejected isHotDeal param still falls back to the plain query',
    () async {
      final interceptor = _Interceptor(
        home: {'hotDeals': <dynamic>[]},
        listings: (query) => query.containsKey('isHotDeal')
            ? DioException(
                requestOptions: RequestOptions(),
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: RequestOptions(),
                  statusCode: 400,
                ),
              )
            : {
                'items': [_listing(3, compareAt: 150)],
              },
      );
      final dio = Dio()..interceptors.add(interceptor);

      final deals = await HomeRemoteDataSourceImpl(dio).fetchHotDeals();

      expect(deals.map((d) => d.id), ['3']);
    },
    skip: skip,
  );

  // Orbit moved the aggregate-first logic into the repository
  // (`getHomeFeed`); the datasource's `fetchHotDeals` is only the fallback.
  test('home hotDeals are used without querying listings', () async {
    final interceptor = _Interceptor(
      home: {
        'hotDeals': [_listing(9, compareAt: 200)],
      },
      listings: (_) => {'items': <dynamic>[]},
    );
    final dio = Dio()..interceptors.add(interceptor);

    final feed = (await HomeRepositoryImpl(
      HomeRemoteDataSourceImpl(dio),
    ).getHomeFeed()).getOrElse((_) => throw StateError('feed failed'));

    expect(interceptor.listingQueries, isEmpty);
    expect(feed.hotDeals.map((d) => d.id), ['9']);
  }, skip: skip);
}
