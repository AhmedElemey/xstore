import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/domain/entities/place_order_params.dart';
import 'package:xstore/features/orders/data/models/order_model.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

import '../../../../helpers/stub_orders_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as the wishlist datasource tests
/// and `register_location_payload_test.dart`'s `_CapturingInterceptor`.
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

CartItemEntity _cartItem({
  String id = 'cart_item_1',
  String listingId = 'listing_1',
}) =>
    CartItemEntity(
      id: id,
      listingId: listingId,
      listingName: 'PS5 Console',
      listingImage: 'https://example.test/ps5.jpg',
      vendorId: 'vendor_1',
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      price: 95000,
      quantity: 1,
      maxQuantity: 3,
      category: 'Electronics',
      condition: 'New',
      addedAt: DateTime(2026, 8, 1),
    );

Map<String, dynamic> _fullCartJson() => {
  'id': 'cart_main',
  'consumerId': 'consumer_1',
  'items': [
    {
      'id': 'cart_item_1',
      'listingId': 'listing_1',
      'listingName': 'PS5 Console',
      'listingImage': 'https://example.test/ps5.jpg',
      'listingSlug': 'ps5-console',
      'vendorId': 'vendor_1',
      'vendorName': 'Ahmed',
      'vendorStoreName': 'Ahmed Store',
      'vendorAvatar': 'https://example.test/avatar.jpg',
      'vendorRating': 4.8,
      'vendorVerified': true,
      'price': 95000,
      'compareAtPrice': 110000,
      'quantity': 1,
      'maxQuantity': 3,
      'category': 'Electronics',
      'condition': 'New',
      'shippingAvailable': true,
      'shippingCost': 0,
      'isAvailable': true,
      'addedAt': '2026-08-01T00:00:00.000',
    },
  ],
  'couponCode': 'SAVE10',
  'coupon': {
    'code': 'SAVE10',
    'discountType': 'percentage',
    'discountValue': 10,
    'isValid': true,
    'message': '',
  },
  'subtotal': 95000,
  'shippingTotal': 0,
  'discount': 9500,
  'total': 85500,
  'itemCount': 1,
};

void main() {
  late Dio dio;
  late CartRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  setUp(() {
    CartRemoteDataSourceImpl.clearSessionCache();
    dio = buildDio((_) => null);
    datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());
  });

  // Every group below (except removeCoupon, which behaves identically in
  // both modes) exercises the LIVE, non-mock code paths — scripting Dio and
  // asserting no seeded mock data leaks in. Under MOCK=true,
  // `_ensureMockSeed()` populates the same static `_items` list with demo
  // rows on first `getCart`/`buildLineFromListing` call regardless of
  // `clearSessionCache()` in setUp, so these assertions don't hold.
  final skipMock = MockConfig.useMock
      ? 'Requires MOCK=false — exercises the live (non-seeded) datasource path'
      : false;

  group('in-memory cart (live has no /cart API)', () {
    test('getCart returns the empty session snapshot without hitting the network',
        () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return _fullCartJson();
      });
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      final result = await datasource.getCart('consumer_1');

      expect(captured, isNull);
      expect(result.items, isEmpty);
      expect(result.consumerId, 'consumer_1');
    });

    test('addOrUpdateItem stores the line locally and getCart reads it back',
        () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return _fullCartJson();
      });
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      final result = await datasource.getCart('consumer_1');

      expect(captured, isNull);
      expect(result.items, hasLength(1));
      expect(result.items.single.listingId, 'listing_1');
      expect(result.items.single.quantity, 1);
    });

    test('addOrUpdateItem of the same listing increases quantity up to max',
        () async {
      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      final result = await datasource.getCart('consumer_1');
      expect(result.items.single.quantity, 2);
    });

    test('removeItem drops the line from the session snapshot', () async {
      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      await datasource.removeItem(
        consumerId: 'consumer_1',
        itemId: 'cart_item_1',
      );
      final result = await datasource.getCart('consumer_1');
      expect(result.items, isEmpty);
    });

    test('updateQuantity patches the local line', () async {
      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      await datasource.updateQuantity(
        consumerId: 'consumer_1',
        itemId: 'cart_item_1',
        quantity: 3,
      );
      final result = await datasource.getCart('consumer_1');
      expect(result.items.single.quantity, 3);
    });

    test('clearCart empties the session snapshot', () async {
      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      await datasource.clearCart('consumer_1');
      final result = await datasource.getCart('consumer_1');
      expect(result.items, isEmpty);
    });
  }, skip: skipMock);

  group('applyCoupon', () {
    test('live mode rejects coupons without hitting the network', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          'code': 'SAVE10',
          'discountType': 'percentage',
          'discountValue': 10,
          'isValid': true,
          'message': '',
        };
      });
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      expect(
        () => datasource.applyCoupon(code: 'SAVE10', eligibleSubtotal: 6000),
        throwsA(
          isA<CouponException>().having((e) => e.message, 'message', 'unavailable'),
        ),
      );
      expect(captured, isNull);
    });
  }, skip: skipMock);

  group('removeCoupon', () {
    test('clears the local coupon without hitting the network', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return _fullCartJson();
      });
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      await datasource.removeCoupon('consumer_1');
      expect(captured, isNull);
    });
  });

  group('buildLineFromListing', () {
    test('GETs /api/listings/{id} and reads a flat payload', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {
          'id': 'listing_9',
          'title': 'Wireless Earbuds',
          'price': 25000,
          'imageUrl': 'https://example.test/single.jpg',
          'category': 'Electronics',
          'condition': 'New',
          'seller': {
            'id': 'vendor_9',
            'name': 'Sara',
            'storeName': 'Sara Shop',
            'rating': 4.9,
            'verified': true,
          },
        };
      });
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      final result = await datasource.buildLineFromListing('listing_9', 2);

      expect(captured!.method, 'GET');
      expect(captured!.path, '/api/listings/listing_9');
      expect(result.listingId, 'listing_9');
      expect(result.listingName, 'Wireless Earbuds');
      expect(result.listingImage, 'https://example.test/single.jpg');
      expect(result.vendorId, 'vendor_9');
      expect(result.vendorName, 'Sara');
      expect(result.vendorRating, 4.9);
      expect(result.quantity, 2);
      // Free shipping above the 20,000 threshold.
      expect(result.shippingCost, 0.0);
    });

    test('falls back to vendor_unknown / em dash when no seller is present',
        () async {
      dio = buildDio((_) => {'id': 'listing_1', 'title': 'Mystery', 'price': 500});
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      final result = await datasource.buildLineFromListing('listing_1', 1);

      expect(result.vendorId, 'vendor_unknown');
      expect(result.vendorName, '—');
      expect(result.vendorRating, isNull);
      // Below the 20,000 free-shipping threshold.
      expect(result.shippingCost, 500.0);
    });

    test('throws ServerException on an empty response body', () async {
      dio = buildDio((_) => null);
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      expect(
        () => datasource.buildLineFromListing('listing_1', 1),
        throwsA(isA<ServerException>()),
      );
    });
  }, skip: skipMock);

  group('placeOrder', () {
    test('throws ServerException immediately for an empty cart (no orders call)',
        () async {
      dio = buildDio((_) => null);
      datasource = CartRemoteDataSourceImpl(dio, StubOrdersRemoteDataSource());

      expect(
        () => datasource.placeOrder(
          PlaceOrderParams(
            consumerId: 'consumer_1',
            items: const [],
            deliveryAddress: const OrderAddress(
              fullName: 'Jane',
              phone: '0100',
              street: 'St',
              city: 'Cairo',
              wilaya: 'Cairo',
            ),
            paymentMethod: PaymentMethod.cashOnDelivery,
            subtotal: 0,
            shippingTotal: 0,
            discount: 0,
            total: 0,
          ),
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('places one order per cart line and combines them', () async {
      final calls = <String>[];
      dio = buildDio((_) => null);
      final orders = StubOrdersRemoteDataSource(
        onCreateOrder: ({
          required listingId,
          required quantity,
          required latitude,
          required longitude,
          required fallbackItem,
          required fallbackAddress,
          required fallbackPayment,
          notes,
        }) async {
          calls.add(listingId);
          // No real GPS fix in a unit test — AppLocationCache falls back
          // to its Cairo constant.
          expect(latitude, 30.0444);
          expect(longitude, 31.2357);
          expect(fallbackPayment, PaymentMethod.cashOnDelivery);
          expect(notes, 'Ring the bell');
          return OrderModel(
            id: 'order_$listingId',
            consumerId: 'consumer_1',
            consumerName: 'Jane',
            consumerPhone: '0100',
            vendorId: 'vendor_1',
            vendorName: 'Ahmed',
            vendorStoreName: 'Ahmed Store',
            items: [fallbackItem],
            status: OrderStatus.pending,
            paymentMethod: fallbackPayment,
            deliveryAddress: fallbackAddress,
            subtotal: fallbackItem.total,
            shippingCost: 0,
            discount: 0,
            total: fallbackItem.total,
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 1),
          );
        },
      );
      datasource = CartRemoteDataSourceImpl(dio, orders);

      final result = await datasource.placeOrder(
        PlaceOrderParams(
          consumerId: 'consumer_1',
          items: [
            _cartItem(id: 'cart_item_1', listingId: 'listing_1'),
            _cartItem(id: 'cart_item_2', listingId: 'listing_2'),
          ],
          deliveryAddress: const OrderAddress(
            fullName: 'Jane',
            phone: '0100',
            street: 'St',
            city: 'Cairo',
            wilaya: 'Cairo',
          ),
          paymentMethod: PaymentMethod.cashOnDelivery,
          deliveryNote: 'Ring the bell',
          subtotal: 190000,
          shippingTotal: 0,
          discount: 0,
          total: 190000,
        ),
      );

      expect(calls, ['listing_1', 'listing_2']);
      // First created order's id/status/createdAt win; items are the
      // union of every per-listing order's items; totals come from the
      // already-known cart context, not summed from the sub-orders.
      expect(result.id, 'order_listing_1');
      expect(result.items, hasLength(2));
      expect(result.items.map((e) => e.listingId), ['listing_1', 'listing_2']);
      expect(result.subtotal, 190000);
      expect(result.notes, 'Ring the bell');
    });

    test('clears the in-memory cart after a successful live placeOrder',
        () async {
      await datasource.addOrUpdateItem(
        consumerId: 'consumer_1',
        item: _cartItem(),
      );
      expect((await datasource.getCart('consumer_1')).items, hasLength(1));

      final orders = StubOrdersRemoteDataSource(
        onCreateOrder: ({
          required listingId,
          required quantity,
          required latitude,
          required longitude,
          required fallbackItem,
          required fallbackAddress,
          required fallbackPayment,
          notes,
        }) async {
          return OrderModel(
            id: 'order_$listingId',
            consumerId: 'consumer_1',
            consumerName: 'Jane',
            consumerPhone: '0100',
            vendorId: 'vendor_1',
            vendorName: 'Ahmed',
            vendorStoreName: 'Ahmed Store',
            items: [fallbackItem],
            status: OrderStatus.pending,
            paymentMethod: fallbackPayment,
            deliveryAddress: fallbackAddress,
            subtotal: fallbackItem.total,
            shippingCost: 0,
            discount: 0,
            total: fallbackItem.total,
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 1),
          );
        },
      );
      datasource = CartRemoteDataSourceImpl(dio, orders);

      await datasource.placeOrder(
        PlaceOrderParams(
          consumerId: 'consumer_1',
          items: [_cartItem()],
          deliveryAddress: const OrderAddress(
            fullName: 'Jane',
            phone: '0100',
            street: 'St',
            city: 'Cairo',
            wilaya: 'Cairo',
          ),
          paymentMethod: PaymentMethod.cashOnDelivery,
          subtotal: 95000,
          shippingTotal: 0,
          discount: 0,
          total: 95000,
        ),
      );

      expect((await datasource.getCart('consumer_1')).items, isEmpty);
    });
  }, skip: skipMock);
}
