import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:xstore/features/explore/data/models/search_result_model.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';

/// Live GET /api/home listing shape (2026-08-29 probe).
Map<String, dynamic> _liveListing({
  required int id,
  required String title,
  int status = 2,
  String? userName = 'dummy_vendor3@xstore.test',
  String categoryNameEn = 'Electronics',
  String location = 'Giza',
  int condition = 1,
  double price = 250.7,
  int? categoryId = 1,
  bool shippingAvailable = false,
  List<String> imageUrls = const [],
}) =>
    {
      'id': id,
      'userName': userName,
      'title': title,
      'price': price,
      'status': status,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'categoryNameEn': categoryNameEn,
      'condition': condition,
      'location': location,
      'shippingAvailable': shippingAvailable,
      'rating': 0,
      'reviewCount': 0,
    };

class _RoutingInterceptor extends Interceptor {
  _RoutingInterceptor(this.bodies);

  final Map<String, dynamic> bodies;
  final paths = <String>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    paths.add(options.path);
    final data = bodies[options.path];
    if (data == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 404),
        ),
      );
      return;
    }
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: data),
    );
  }
}

void main() {
  group('isPublicLiveListingStatus', () {
    test('Active wire code 2 and "active" are live', () {
      expect(isPublicLiveListingStatus(2), isTrue);
      expect(isPublicLiveListingStatus('2'), isTrue);
      expect(isPublicLiveListingStatus('active'), isTrue);
      expect(isPublicLiveListingStatus(null), isTrue);
      expect(isPublicLiveListingStatus(''), isTrue);
    });

    test('draft/pending/paused/sold/rejected are not live', () {
      expect(isPublicLiveListingStatus(0), isFalse);
      expect(isPublicLiveListingStatus(1), isFalse);
      expect(isPublicLiveListingStatus(3), isFalse);
      expect(isPublicLiveListingStatus(4), isFalse);
      expect(isPublicLiveListingStatus(5), isFalse);
      expect(isPublicLiveListingStatus('pending'), isFalse);
    });
  });

  group('SearchResultModel.fromListingLike live DTO', () {
    test('reads title, categoryNameEn, userName from the live listing shape', () {
      final model = SearchResultModel.fromListingLike(
        _liveListing(
          id: 54,
          title: 'Mechanical Keyboard 40',
          imageUrls: const ['https://picsum.photos/seed/kb/400/400'],
        ),
      );
      expect(model.id, '54');
      expect(model.name, 'Mechanical Keyboard 40');
      expect(model.category, 'Electronics');
      expect(model.sellerName, 'dummy_vendor3@xstore.test');
      expect(model.location, 'Giza');
      expect(model.condition, 'New');
      expect(model.hasShipping, isFalse);
      expect(model.imageUrl, 'https://picsum.photos/seed/kb/400/400');
    });

    test('falls back to titleEn when the flat title is absent', () {
      final model = SearchResultModel.fromListingLike({
        'id': 3,
        'titleEn': 'MacBook Pro 16" M3 Max',
        'price': 89999,
        'status': 2,
        'categoryNameEn': 'Electronics',
      });
      expect(model.name, 'MacBook Pro 16" M3 Max');
    });
  });

  group('ExploreRemoteDataSourceImpl live catalog', () {
    late Dio dio;
    late _RoutingInterceptor interceptor;
    late ExploreRemoteDataSourceImpl datasource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      interceptor = _RoutingInterceptor({
        '/api/listings': {
          'items': <dynamic>[],
          'totalCount': 0,
          'page': 1,
          'pageSize': 20,
        },
        '/api/home': {
          'banners': <dynamic>[],
          'newArrivals': [
            _liveListing(id: 54, title: 'Mechanical Keyboard 40'),
            _liveListing(id: 1, title: 'Pending draft', status: 1),
          ],
          'recommendedForYou': [
            _liveListing(
              id: 2,
              title: 'Sony WH-1000XM5',
              userName: 'store@xstore.test',
            ),
          ],
          'hotDeals': [
            _liveListing(id: 54, title: 'Mechanical Keyboard 40'),
          ],
        },
      });
      dio.interceptors.add(interceptor);
      datasource = ExploreRemoteDataSourceImpl(dio);
    });

    test('empty nearby /api/listings falls back to Active GET /api/home listings',
        () async {
      final results = await datasource.searchListings('', 1);

      expect(interceptor.paths, ['/api/listings', '/api/home']);
      expect(results.map((e) => e.id), ['54', '2']);
      expect(results.map((e) => e.name), [
        'Mechanical Keyboard 40',
        'Sony WH-1000XM5',
      ]);
    });

    test('keyword fallback keeps matching Active titles only', () async {
      final results = await datasource.searchListings('sony', 1);
      expect(results, hasLength(1));
      expect(results.single.name, 'Sony WH-1000XM5');
    });

    test('page 2 of an empty nearby search does not repeat home', () async {
      final results = await datasource.searchListings('', 2);
      expect(interceptor.paths, ['/api/listings']);
      expect(results, isEmpty);
    });

    test('nearby listings are used as-is and home is not fetched', () async {
      interceptor.bodies['/api/listings'] = {
        'items': [
          _liveListing(id: 10, title: 'Nearby phone'),
        ],
        'totalCount': 1,
        'page': 1,
        'pageSize': 20,
      };

      final results = await datasource.searchListings('', 1);
      expect(interceptor.paths, ['/api/listings']);
      expect(results, hasLength(1));
      expect(results.single.name, 'Nearby phone');
    });
  });
}
