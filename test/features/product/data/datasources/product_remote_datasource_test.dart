import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/product/data/datasources/product_remote_datasource.dart';
import 'package:xstore/features/product/domain/entities/review_write_params.dart';

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

Map<String, dynamic> _minimalListing({String id = 'listing_1'}) => {
  'id': id,
  'title': 'Test Listing',
  'description': 'A listing',
  'price': 500,
};

void main() {
  late Dio dio;
  late ProductRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  // Every group in this file scripts Dio to exercise ProductRemoteDataSourceImpl's
  // LIVE fetch/parse path. Under MOCK=true these methods short-circuit to
  // the mock listing/review fixtures before Dio is ever touched, so these
  // assertions don't hold.
  final skipMock = MockConfig.useMock
      ? 'Requires MOCK=false — exercises the live (non-mock) datasource path'
      : false;

  group('fetchProductDetail', () {
    test('GETs /api/listings/{id} and reads a flat userId/userName/userAvatar seller',
        () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          ..._minimalListing(),
          'userId': 'vendor_9',
          'userName': 'Sara',
          'userAvatar': 'https://example.test/sara.jpg',
          'compareAtPrice': 600,
          'stockQuantity': 3,
        };
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchProductDetail('listing_1');

      expect(captured!.method, 'GET');
      expect(captured!.path, '/api/listings/listing_1');
      expect(result.listing.id, 'listing_1');
      expect(result.compareAtPrice, 600);
      expect(result.stockQuantity, 3);
      expect(result.seller?.id, 'vendor_9');
      expect(result.seller?.name, 'Sara');
    });

    test('reads a nested seller object when present, ignoring the flat fallback',
        () async {
      dio = buildDio((_) => {
        ..._minimalListing(),
        'userId': 'flat_vendor',
        'seller': {
          'id': 'nested_vendor',
          'name': 'Omar',
          'verified': true,
        },
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchProductDetail('listing_1');

      expect(result.seller?.id, 'nested_vendor');
      expect(result.seller?.name, 'Omar');
      expect(result.seller?.verified, isTrue);
    });

    test('unwraps a nested {"listing": {...}} payload', () async {
      dio = buildDio((_) => {'listing': _minimalListing(id: 'listing_5')});
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchProductDetail('listing_5');

      expect(result.listing.id, 'listing_5');
    });

    test('throws ServerException on an empty response body', () async {
      dio = buildDio((_) => null);
      datasource = ProductRemoteDataSourceImpl(dio);

      expect(
        () => datasource.fetchProductDetail('listing_1'),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps a DioException via mapDioException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = ProductRemoteDataSourceImpl(dio);

      expect(
        () => datasource.fetchProductDetail('listing_1'),
        throwsA(isA<ServerException>()),
      );
    });
  }, skip: skipMock);

  group('fetchSimilarProducts', () {
    test('GETs the similar-listings route and excludes the source product',
        () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return [
          _minimalListing(id: 'listing_1'),
          _minimalListing(id: 'listing_2'),
        ];
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchSimilarProducts(
        productId: 'listing_1',
        category: 'Electronics',
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, ApiEndpoints.apiListingSimilar('listing_1'));
      expect(result, hasLength(1));
      expect(result.single.listing.id, 'listing_2');
    });

    test('maps a DioException via mapDioException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = ProductRemoteDataSourceImpl(dio);

      expect(
        () => datasource.fetchSimilarProducts(productId: 'listing_1', category: 'x'),
        throwsA(isA<ServerException>()),
      );
    });
  }, skip: skipMock);

  group('fetchProductReviews', () {
    test('reads the {items, totalCount} envelope when present', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          'items': [
            {
              'id': 'r1',
              'userId': 'u1',
              'userName': 'Jane',
              'rating': 4,
              'comment': 'Good',
            },
          ],
          'totalCount': 25,
        };
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchProductReviews(
        listingId: 'listing_1',
        page: 2,
        pageSize: 10,
      );

      expect(captured!.path, ApiEndpoints.apiListingReviews('listing_1'));
      expect(captured!.queryParameters, {'page': 2, 'pageSize': 10});
      expect(result.items.single.id, 'r1');
      expect(result.totalCount, 25);
      expect(result.page, 2);
      expect(result.pageSize, 10);
    });

    test('falls back to a bare list with totalCount = items.length when there is no envelope',
        () async {
      dio = buildDio((_) => [
        {'id': 'r1', 'userId': 'u1', 'userName': 'Jane', 'rating': 5, 'comment': 'Great'},
        {'id': 'r2', 'userId': 'u2', 'userName': 'Sam', 'rating': 3, 'comment': 'OK'},
      ]);
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchProductReviews(
        listingId: 'listing_1',
        page: 1,
        pageSize: 20,
      );

      expect(result.items, hasLength(2));
      expect(result.totalCount, 2);
    });

    test('returns an empty page for a malformed response instead of crashing',
        () async {
      dio = buildDio((_) => 'not a list or map');
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.fetchProductReviews(
        listingId: 'listing_1',
        page: 1,
        pageSize: 20,
      );

      expect(result.items, isEmpty);
      expect(result.totalCount, 0);
    });

    test('maps a DioException via mapDioException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = ProductRemoteDataSourceImpl(dio);

      expect(
        () => datasource.fetchProductReviews(listingId: 'listing_1', page: 1, pageSize: 20),
        throwsA(isA<ServerException>()),
      );
    });
  }, skip: skipMock);

  group('createReview', () {
    test('POSTs {rating, comment} and parses the created review', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          'id': 'r9',
          'userId': 'u1',
          'userName': 'Jane',
          'rating': 5,
          'comment': 'Loved it',
        };
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.createReview(
        listingId: 'listing_1',
        params: const ReviewWriteParams(rating: 5, comment: 'Loved it'),
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, ApiEndpoints.apiListingReviews('listing_1'));
      expect(captured!.data, {'rating': 5.0, 'comment': 'Loved it'});
      expect(result.id, 'r9');
      expect(result.rating, 5);
    });

    test('throws ServerException on an empty response body', () async {
      dio = buildDio((_) => null);
      datasource = ProductRemoteDataSourceImpl(dio);

      expect(
        () => datasource.createReview(
          listingId: 'listing_1',
          params: const ReviewWriteParams(rating: 4, comment: 'x'),
        ),
        throwsA(isA<ServerException>()),
      );
    });
  }, skip: skipMock);

  group('updateReview', () {
    test('PUTs {rating, comment} to the specific review route', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          'id': 'r9',
          'userId': 'u1',
          'userName': 'Jane',
          'rating': 3,
          'comment': 'Updated',
        };
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      final result = await datasource.updateReview(
        listingId: 'listing_1',
        reviewId: 'r9',
        params: const ReviewWriteParams(rating: 3, comment: 'Updated'),
      );

      expect(captured!.method, 'PUT');
      expect(captured!.path, ApiEndpoints.apiListingReview('listing_1', 'r9'));
      expect(result.comment, 'Updated');
    });
  }, skip: skipMock);

  group('deleteReview', () {
    test('DELETEs the specific review route', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return null;
      });
      datasource = ProductRemoteDataSourceImpl(dio);

      await datasource.deleteReview(listingId: 'listing_1', reviewId: 'r9');

      expect(captured!.method, 'DELETE');
      expect(captured!.path, ApiEndpoints.apiListingReview('listing_1', 'r9'));
    });

    test('maps a DioException via mapDioException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = ProductRemoteDataSourceImpl(dio);

      expect(
        () => datasource.deleteReview(listingId: 'listing_1', reviewId: 'r9'),
        throwsA(isA<ServerException>()),
      );
    });
  }, skip: skipMock);
}
