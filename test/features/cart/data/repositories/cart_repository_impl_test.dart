import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/domain/entities/place_order_params.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

import '../../../../helpers/stub_cart_remote_datasource.dart';
import '../../../../helpers/stub_orders_repository.dart';

CartEntity _cart(String consumerId, {List<CartItemEntity> items = const []}) =>
    CartEntity(id: 'cart_stub', consumerId: consumerId, items: items);

CartItemEntity _item({String id = 'cart_item_1', String listingId = 'listing_1'}) =>
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

OrderEntity _order(String consumerId) => OrderEntity(
      id: 'order_1',
      consumerId: consumerId,
      consumerName: 'Jane',
      consumerPhone: '0100',
      vendorId: 'vendor_1',
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      items: const [],
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryAddress: const OrderAddress(
        fullName: 'Jane',
        phone: '0100',
        street: 'St',
        city: 'Cairo',
        wilaya: 'Cairo',
      ),
      subtotal: 95000,
      shippingCost: 0,
      discount: 0,
      total: 95000,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

PlaceOrderParams _params(String consumerId) => PlaceOrderParams(
      consumerId: consumerId,
      items: [_item()],
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
    );

/// [StubOrdersRepository] always returns Right(unit) from
/// registerCheckoutOrder — this override lets placeOrder tests also cover
/// the Left path and verify the call actually happened.
class _OrdersRepoWithRegisterResult extends StubOrdersRepository {
  _OrdersRepoWithRegisterResult(this._result);
  final Either<Failure, Unit> _result;
  OrderEntity? registeredOrder;

  @override
  Future<Either<Failure, Unit>> registerCheckoutOrder(OrderEntity order) async {
    registeredOrder = order;
    return _result;
  }
}

void main() {
  group('getCart', () {
    test('passes through the remote cart as Right', () async {
      final cart = _cart('consumer_1', items: [_item()]);
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onGetCart: (_) async => cart),
        StubOrdersRepository(),
      );

      final result = await repo.getCart('consumer_1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (c) => expect(c.items, hasLength(1)));
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onGetCart: (_) async => throw Exception('boom')),
        StubOrdersRepository(),
      );

      final result = await repo.getCart('consumer_1');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected Left'));
    });
  });

  group('addFromListing', () {
    test('builds the line from the catalog, then adds it to the cart', () async {
      final calls = <String>[];
      final built = _item(listingId: 'listing_9');
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onBuildLineFromListing: (listingId, quantity) async {
            calls.add('build:$listingId:$quantity');
            expect(listingId, 'listing_9');
            expect(quantity, 2);
            return built;
          },
          onAddOrUpdateItem: ({required consumerId, required item}) async {
            calls.add('add:$consumerId:${item.listingId}');
            expect(item, built);
            return _cart(consumerId, items: [built]);
          },
        ),
        StubOrdersRepository(),
      );

      final result = await repo.addFromListing(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
        quantity: 2,
      );

      // build must happen before add, and with the built line (not a
      // fresh one) passed through unchanged.
      expect(calls, ['build:listing_9:2', 'add:consumer_1:listing_9']);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (cart) => expect(cart.items.single.listingId, 'listing_9'),
      );
    });

    test('surfaces a buildLineFromListing failure without calling addOrUpdateItem',
        () async {
      var addCalled = false;
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onBuildLineFromListing: (_, __) async => throw Exception('not found'),
          onAddOrUpdateItem: ({required consumerId, required item}) async {
            addCalled = true;
            return _cart(consumerId);
          },
        ),
        StubOrdersRepository(),
      );

      final result = await repo.addFromListing(
        consumerId: 'consumer_1',
        listingId: 'listing_9',
        quantity: 1,
      );

      expect(result.isLeft(), isTrue);
      expect(addCalled, isFalse);
    });
  });

  group('addOrUpdateItem', () {
    test('passes through as Right', () async {
      final cart = _cart('consumer_1', items: [_item()]);
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onAddOrUpdateItem: ({required consumerId, required item}) async => cart,
        ),
        StubOrdersRepository(),
      );

      final result = await repo.addOrUpdateItem(consumerId: 'consumer_1', item: _item());

      expect(result.isRight(), isTrue);
    });
  });

  group('removeItem', () {
    test('passes the ids through and returns Right', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onRemoveItem: ({required consumerId, required itemId}) async {
            expect(consumerId, 'consumer_1');
            expect(itemId, 'cart_item_1');
            return _cart(consumerId);
          },
        ),
        StubOrdersRepository(),
      );

      final result = await repo.removeItem(consumerId: 'consumer_1', itemId: 'cart_item_1');

      expect(result.isRight(), isTrue);
    });

    test('maps a thrown exception to Failure.server', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onRemoveItem: ({required consumerId, required itemId}) async =>
              throw Exception('boom'),
        ),
        StubOrdersRepository(),
      );

      final result = await repo.removeItem(consumerId: 'consumer_1', itemId: 'cart_item_1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateQuantity', () {
    test('passes the ids/quantity through and returns Right', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onUpdateQuantity: ({required consumerId, required itemId, required quantity}) async {
            expect(quantity, 5);
            return _cart(consumerId);
          },
        ),
        StubOrdersRepository(),
      );

      final result = await repo.updateQuantity(
        consumerId: 'consumer_1',
        itemId: 'cart_item_1',
        quantity: 5,
      );

      expect(result.isRight(), isTrue);
    });
  });

  group('clearCart', () {
    test('returns Right on success', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onClearCart: (_) async => _cart('consumer_1')),
        StubOrdersRepository(),
      );

      final result = await repo.clearCart('consumer_1');

      expect(result.isRight(), isTrue);
    });
  });

  group('applyCoupon', () {
    test('passes through the coupon as Right', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onApplyCoupon: ({required code, required eligibleSubtotal}) async {
            expect(code, 'SAVE10');
            expect(eligibleSubtotal, 6000);
            return const CouponEntity(
              code: 'SAVE10',
              discountType: DiscountType.percentage,
              discountValue: 10,
            );
          },
        ),
        StubOrdersRepository(),
      );

      final result = await repo.applyCoupon(
        consumerId: 'consumer_1',
        code: 'SAVE10',
        eligibleSubtotal: 6000,
      );

      expect(result.isRight(), isTrue);
    });

    test('maps a CouponException to Failure.validation, not Failure.server',
        () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onApplyCoupon: ({required code, required eligibleSubtotal}) async =>
              throw CouponException('invalid'),
        ),
        StubOrdersRepository(),
      );

      final result = await repo.applyCoupon(
        consumerId: 'consumer_1',
        code: 'BAD',
        eligibleSubtotal: 100,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps any other exception to Failure.server', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(
          onApplyCoupon: ({required code, required eligibleSubtotal}) async =>
              throw Exception('network down'),
        ),
        StubOrdersRepository(),
      );

      final result = await repo.applyCoupon(
        consumerId: 'consumer_1',
        code: 'SAVE10',
        eligibleSubtotal: 100,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('removeCoupon', () {
    test('returns Right on success', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onRemoveCoupon: (_) async => _cart('consumer_1')),
        StubOrdersRepository(),
      );

      final result = await repo.removeCoupon('consumer_1');

      expect(result.isRight(), isTrue);
    });
  });

  group('placeOrder', () {
    test('places the order then registers it, returning the order on success',
        () async {
      final order = _order('consumer_1');
      final ordersRepo = _OrdersRepoWithRegisterResult(const Right(unit));
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onPlaceOrder: (params) async => order),
        ordersRepo,
      );

      final result = await repo.placeOrder(_params('consumer_1'));

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (o) => expect(o.id, 'order_1'));
      expect(ordersRepo.registeredOrder?.id, 'order_1');
    });

    test('surfaces the registerCheckoutOrder failure instead of the order',
        () async {
      final order = _order('consumer_1');
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onPlaceOrder: (params) async => order),
        _OrdersRepoWithRegisterResult(Left(Failure.cache('disk full'))),
      );

      final result = await repo.placeOrder(_params('consumer_1'));

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<CacheFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps a thrown exception from placeOrder to Failure.server', () async {
      final repo = CartRepositoryImpl(
        StubCartRemoteDataSource(onPlaceOrder: (params) async => throw Exception('boom')),
        StubOrdersRepository(),
      );

      final result = await repo.placeOrder(_params('consumer_1'));

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
