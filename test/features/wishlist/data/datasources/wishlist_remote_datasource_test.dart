import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/features/wishlist/data/datasources/wishlist_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as
/// `test/features/auth/register_location_payload_test.dart`'s
/// `_CapturingInterceptor`, generalized to also script error responses so
/// the `mapDioException` paths can be exercised.
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

Map<String, dynamic> _fullWishlistItemJson({
  String id = 'wish_1',
  String listingId = 'listing_1',
  num rating = 4.5,
}) => {
  'id': id,
  'listingId': listingId,
  'listingName': 'Leather Jacket',
  'listingImages': ['https://example.test/a.jpg', 'https://example.test/b.jpg'],
  'listingSlug': 'leather-jacket',
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'vendorAvatar': 'https://example.test/avatar.jpg',
  'isVendorVerified': true,
  'price': 15000,
  'compareAtPrice': 18000,
  'previousPrice': 16000,
  'priceDropPercent': 10,
  'category': 'Fashion',
  'condition': 'New',
  'rating': rating,
  'reviewCount': 12,
  'stockQuantity': 3,
  'isAvailable': true,
  'isInCart': false,
  'shippingAvailable': true,
  'shippingCost': 500,
  'addedAt': '2026-08-01T10:00:00.000Z',
  'lastPriceCheckAt': '2026-08-20T10:00:00.000Z',
};

void main() {
  late Dio dio;
  late WishlistRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  group('getWishlist', () {
    test('GETs /api/wishlist/{consumerId} and parses a bare array', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return [
          _fullWishlistItemJson(),
          _fullWishlistItemJson(id: 'wish_2', listingId: 'listing_2'),
        ];
      });
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.getWishlist('consumer_1');

      expect(captured!.method, 'GET');
      expect(captured!.path, '/api/wishlist/consumer_1');
      expect(result, hasLength(2));
      final first = result.first;
      expect(first.id, 'wish_1');
      expect(first.listingId, 'listing_1');
      expect(first.listingName, 'Leather Jacket');
      expect(first.listingImages, [
        'https://example.test/a.jpg',
        'https://example.test/b.jpg',
      ]);
      expect(first.price, 15000);
      expect(first.compareAtPrice, 18000);
      expect(first.priceDropPercent, 10);
      expect(first.rating, 4.5);
      expect(first.reviewCount, 12);
      expect(first.stockQuantity, 3);
      expect(first.addedAt, DateTime.parse('2026-08-01T10:00:00.000Z'));
    });

    test('parses a wrapped {data: []} envelope', () async {
      dio = buildDio(
        (_) => {
          'isSuccess': true,
          'data': [
            _fullWishlistItemJson(),
            _fullWishlistItemJson(id: 'wish_2', listingId: 'listing_2'),
          ],
        },
      );
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.getWishlist('consumer_1');

      expect(result, hasLength(2));
      expect(result.first.listingId, 'listing_1');
    });

    test('treats a zero rating as "no reviews yet" (null)', () async {
      dio = buildDio((_) => [_fullWishlistItemJson(rating: 0)]);
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.getWishlist('consumer_1');

      expect(result.single.rating, isNull);
    });

    test('a null response body yields an empty list', () async {
      dio = buildDio((_) => null);
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.getWishlist('consumer_1');

      expect(result, isEmpty);
    });

    test('maps a 500 response to a ServerException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = WishlistRemoteDataSourceImpl(dio);

      expect(
        () => datasource.getWishlist('consumer_1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('addToWishlist', () {
    test('POSTs {listingId} to /api/wishlist/{consumerId}/items', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return _fullWishlistItemJson(listingId: 'listing_9');
      });
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.addToWishlist(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, '/api/wishlist/consumer_1/items');
      expect(captured!.data, {'listingId': 'listing_9'});
      expect(result.listingId, 'listing_9');
      expect(result.listingName, 'Leather Jacket');
    });

    test('unwraps a {data: item} envelope and keeps listingId', () async {
      dio = buildDio(
        (_) => {
          'isSuccess': true,
          'data': _fullWishlistItemJson(id: '15', listingId: 'listing_9'),
        },
      );
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.addToWishlist(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(result.id, '15');
      expect(result.listingId, 'listing_9');
    });

    test('treats 409 already-in-wishlist as the existing row', () async {
      dio = buildDio((options) {
        if (options.method == 'POST') {
          return DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 409,
              data: {
                'isSuccess': false,
                'data': null,
                'errorEn': 'Item already in wishlist.',
                'statusCode': 409,
              },
            ),
          );
        }
        return [_fullWishlistItemJson(id: '15', listingId: 'listing_9')];
      });
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.addToWishlist(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(result.id, '15');
      expect(result.listingId, 'listing_9');
    });

    test('throws ServerException on an empty response body', () async {
      dio = buildDio((_) => null);
      datasource = WishlistRemoteDataSourceImpl(dio);

      expect(
        () => datasource.addToWishlist(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps a 429 response to a ServerException', () async {
      dio = buildDio((options) => _badResponse(options, 429));
      datasource = WishlistRemoteDataSourceImpl(dio);

      expect(
        () => datasource.addToWishlist(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('removeFromWishlist', () {
    test('DELETEs /api/wishlist/{consumerId}/items/{listingId}', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return null;
      });
      datasource = WishlistRemoteDataSourceImpl(dio);

      await datasource.removeFromWishlist(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
      );

      expect(captured!.method, 'DELETE');
      expect(captured!.path, '/api/wishlist/consumer_1/items/listing_9');
    });

    test(
      'also DELETEs the wishlist row id when it differs from listingId',
      () async {
        final paths = <String>[];
        dio = buildDio((options) {
          paths.add(options.path);
          if (options.path.endsWith('/15')) return null;
          return _badResponse(options, 404);
        });
        datasource = WishlistRemoteDataSourceImpl(dio);

        await datasource.removeFromWishlist(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
          wishlistItemId: '15',
        );

        expect(paths, [
          '/api/wishlist/consumer_1/items/15',
          '/api/wishlist/consumer_1/items/listing_9',
        ]);
      },
    );

    test('maps a 401 response to an UnauthorizedException', () async {
      dio = buildDio((options) => _badResponse(options, 401));
      datasource = WishlistRemoteDataSourceImpl(dio);

      expect(
        () => datasource.removeFromWishlist(
          consumerId: 'consumer_1',
          listingId: 'listing_9',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('clearWishlist', () {
    test('DELETEs /api/wishlist/{consumerId}', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return null;
      });
      datasource = WishlistRemoteDataSourceImpl(dio);

      await datasource.clearWishlist('consumer_1');

      expect(captured!.method, 'DELETE');
      expect(captured!.path, '/api/wishlist/consumer_1');
    });

    test('maps a connection timeout to a NetworkException', () async {
      dio = buildDio(
        (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      datasource = WishlistRemoteDataSourceImpl(dio);

      expect(
        () => datasource.clearWishlist('consumer_1'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('buildFromListingId', () {
    test(
      'GETs /api/listings/{id} and reads a flat (unwrapped) payload',
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return {
            'id': 'listing_9',
            'title': 'Wireless Earbuds',
            'slug': 'wireless-earbuds',
            'imageUrl': 'https://example.test/single.jpg',
            'price': 25000,
            'category': 'Electronics',
            'condition': 'New',
            'userId': 'vendor_42',
            'userName': 'Sara',
            'rating': 4.8,
            'reviewCount': 7,
            'stockQuantity': 5,
            'shippingAvailable': true,
          };
        });
        datasource = WishlistRemoteDataSourceImpl(dio);

        final result = await datasource.buildFromListingId('listing_9');

        expect(captured!.method, 'GET');
        expect(captured!.path, '/api/listings/listing_9');
        expect(result.listingId, 'listing_9');
        expect(result.listingName, 'Wireless Earbuds');
        expect(result.listingImages, ['https://example.test/single.jpg']);
        // Flat userId/userName fallback (no nested seller/vendor object).
        expect(result.vendorId, 'vendor_42');
        expect(result.vendorName, 'Sara');
        expect(result.vendorStoreName, 'Sara');
        expect(result.rating, 4.8);
        // Free shipping above the 20,000 threshold.
        expect(result.shippingCost, 0.0);
        expect(result.id, startsWith('wish_'));
      },
    );

    test('unwraps a nested {"listing": {...}} payload', () async {
      dio = buildDio(
        (_) => {
          'listing': {
            'id': 'listing_5',
            'title': 'Desk Lamp',
            'price': 1000,
            'imageUrl': 'https://example.test/lamp.jpg',
          },
        },
      );
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.buildFromListingId('listing_5');

      expect(result.listingId, 'listing_5');
      expect(result.listingName, 'Desk Lamp');
      // Below the 20,000 free-shipping threshold.
      expect(result.shippingCost, 500.0);
    });

    test('reads vendor/seller details from a nested seller object', () async {
      dio = buildDio(
        (_) => {
          'id': 'listing_7',
          'title': 'Backpack',
          'price': 2000,
          'seller': {
            'id': 'vendor_7',
            'name': 'Omar',
            'storeName': 'Omar Bags',
            'avatarUrl': 'https://example.test/omar.jpg',
            'verified': true,
          },
        },
      );
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.buildFromListingId('listing_7');

      expect(result.vendorId, 'vendor_7');
      expect(result.vendorName, 'Omar');
      expect(result.vendorStoreName, 'Omar Bags');
      expect(result.vendorAvatar, 'https://example.test/omar.jpg');
      expect(result.isVendorVerified, isTrue);
    });

    test('falls back to placeholders when no vendor info is present', () async {
      dio = buildDio(
        (_) => {'id': 'listing_8', 'title': 'Mystery Box', 'price': 500},
      );
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.buildFromListingId('listing_8');

      expect(result.vendorId, 'vendor_unknown');
      expect(result.vendorName, '—');
      expect(result.isVendorVerified, isFalse);
    });

    test('uses the given wishId instead of generating one', () async {
      dio = buildDio((_) => {'id': 'listing_1', 'title': 'X', 'price': 1});
      datasource = WishlistRemoteDataSourceImpl(dio);

      final result = await datasource.buildFromListingId(
        'listing_1',
        wishId: 'wish_fixed',
      );

      expect(result.id, 'wish_fixed');
    });

    test('throws ServerException on an empty response body', () async {
      dio = buildDio((_) => null);
      datasource = WishlistRemoteDataSourceImpl(dio);

      expect(
        () => datasource.buildFromListingId('listing_1'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
