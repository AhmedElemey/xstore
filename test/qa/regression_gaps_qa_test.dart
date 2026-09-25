// QA suite (2026-09-24): regression tests for the gaps a mutation run found
// in the previous test suite. Each group names the planted bug ("mutant")
// that no previous test caught; these tests fail if that bug comes back.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/token_refresh_interceptor.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/domain/entities/place_order_params.dart';
import 'package:xstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:xstore/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_provider.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

import 'support/scripted_adapter.dart';

const _consumer = UserEntity(
  id: '6',
  name: 'QA Consumer',
  email: 'qa@example.com',
  phoneNumber: '01012345678',
);

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;

  @override
  Future<UserEntity?> build() async => _user;

  void signOut() => state = const AsyncData(null);
}

/// Analytics is irrelevant to these assertions; never touch Firebase.
class _NoopAnalytics implements AnalyticsService {
  @override
  void track(String name, {Map<String, Object?> properties = const {}}) {}

  @override
  Future<void> get ready => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

CartItemEntity _item(
  String id, {
  required String listingId,
  double price = 100,
  int qty = 1,
  double shipping = 0,
}) =>
    CartItemEntity(
      id: id,
      listingId: listingId,
      listingName: id,
      listingImage: '',
      vendorId: 'v1',
      vendorName: 'v1',
      vendorStoreName: 'v1',
      price: price,
      quantity: qty,
      maxQuantity: 10,
      category: 'c',
      condition: 'new',
      shippingAvailable: shipping > 0,
      shippingCost: shipping,
      addedAt: DateTime(2026),
    );

CartEntity _cart(List<CartItemEntity> items) =>
    CartEntity(id: 'cart', consumerId: _consumer.id, items: items);

/// getCart answers from [next] (or waits on [gate] when set); placeOrder
/// counts calls and waits on [orderGate].
class _FakeCartRepo implements CartRepository {
  List<CartItemEntity> next = const [];
  Completer<void>? gate;
  Completer<void>? orderGate;
  int placeOrderCalls = 0;

  @override
  Future<Either<Failure, CartEntity>> getCart(String consumerId) async {
    final items = next; // snapshot what was "on the server" at request time
    if (gate != null) await gate!.future;
    return Right(_cart(items));
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder(
    PlaceOrderParams params,
  ) async {
    placeOrderCalls++;
    if (orderGate != null) await orderGate!.future;
    final now = DateTime(2026);
    return Right(OrderEntity(
      id: 'o$placeOrderCalls',
      consumerId: params.consumerId,
      consumerName: '',
      consumerPhone: '',
      vendorId: 'v1',
      vendorName: 'v1',
      vendorStoreName: 'v1',
      items: const [],
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryAddress: params.deliveryAddress,
      subtotal: params.subtotal,
      shippingCost: params.shippingTotal,
      discount: params.discount,
      total: params.total,
      createdAt: now,
      updatedAt: now,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  // Connectivity/SharedPreferences use platform channels.
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeCartRepo repo;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CartRemoteDataSourceImpl.clearSessionCache();
    repo = _FakeCartRepo();
    container = ProviderContainer(overrides: [
      authProvider.overrideWith(() => _FakeAuth(_consumer)),
      cartRepositoryProvider.overrideWithValue(repo),
      analyticsServiceProvider.overrideWithValue(_NoopAnalytics()),
    ]);
    addTearDown(container.dispose);
    await container.read(authProvider.future);
  });

  group('M02 — the REAL cart total includes shipping', () {
    // The previous cart_totals_test re-implemented the total formula inside
    // the test file, so breaking Cart._recomputeTotals could not fail it.
    test('fetchCart totals = subtotal + shipping - discount', () async {
      repo.next = [
        _item('a', listingId: '1', price: 100, qty: 2, shipping: 5),
        _item('b', listingId: '2', price: 50, shipping: 3),
      ];
      await container.read(cartProvider.notifier).fetchCart();
      final cart = container.read(cartProvider);
      expect(cart.subtotal, 250);
      expect(cart.shippingTotal, 8);
      expect(cart.total, 258);
    });
  });

  group('M03 — logout clears the cart on screen', () {
    test('the previous user\'s items are gone after sign-out', () async {
      repo.next = [_item('a', listingId: '1')];
      await container.read(cartProvider.notifier).fetchCart();
      expect(container.read(cartProvider).items, isNotEmpty);

      (container.read(authProvider.notifier) as _FakeAuth).signOut();
      await _flush();

      expect(container.read(cartProvider).items, isEmpty);
      expect(container.read(cartProvider).total, 0);
    });
  });

  group('M04 — a fetch in flight at logout cannot resurrect the cart', () {
    test('late getCart response after sign-out is discarded', () async {
      repo
        ..next = [_item('a', listingId: '1')]
        ..gate = Completer<void>();
      final inFlight = container.read(cartProvider.notifier).fetchCart();

      (container.read(authProvider.notifier) as _FakeAuth).signOut();
      await _flush();
      repo.gate!.complete();
      await inFlight;

      expect(container.read(cartProvider).items, isEmpty);
    });
  });

  group('Checkout double-submit', () {
    test('a second Place Order while one is in flight places nothing',
        () async {
      repo.next = [_item('a', listingId: '1')];
      await container.read(cartProvider.notifier).fetchCart();
      // Checkout is autoDispose: keep it alive across awaits.
      final sub = container.listen(checkoutProvider, (_, __) {});
      addTearDown(sub.close);
      final checkout = container.read(checkoutProvider.notifier)
        ..addAddress(const OrderAddress(
          fullName: 'QA',
          phone: '01012345678',
          street: '1 Tahrir St',
          city: 'Cairo',
          wilaya: 'Cairo',
        ));

      repo.orderGate = Completer<void>();
      final first = checkout.placeOrder();
      final second = checkout.placeOrder();
      repo.orderGate!.complete();
      await Future.wait([first, second]);

      expect(repo.placeOrderCalls, 1);
    });
  });

  group('M06 — a failed checkout line stays in the cart', () {
    test('one line fails, the other is ordered; the failed one remains',
        () async {
      final server = ScriptedAdapter();
      final dio = scriptedDio(server);
      final ds = CartRemoteDataSourceImpl(dio, OrdersRemoteDataSourceImpl(dio));
      for (final id in ['1', '2']) {
        server.reply('GET', '/api/listings/$id/stock', 200,
            {'isSuccess': true, 'data': true});
      }
      server.on('POST', ApiEndpoints.orders, (req) async {
        final body = req.data as Map;
        return body['listingId'] == 1
            ? const FakeReply(
                200, {'id': 501, 'status': 0, 'listingId': 1, 'quantity': 1})
            : const FakeReply(400, {'errorEn': 'Listing is not active.'});
      });

      final ok = _item('ok', listingId: '1');
      final bad = _item('bad', listingId: '2');
      await ds.addOrUpdateItem(consumerId: _consumer.id, item: ok);
      await ds.addOrUpdateItem(consumerId: _consumer.id, item: bad);

      final order = await ds.placeOrder(PlaceOrderParams(
        consumerId: _consumer.id,
        items: [ok, bad],
        deliveryAddress: const OrderAddress(
          fullName: 'QA',
          phone: '01012345678',
          street: '1 Tahrir St',
          city: 'Cairo',
          wilaya: 'Cairo',
        ),
        paymentMethod: PaymentMethod.cashOnDelivery,
        subtotal: 200,
        shippingTotal: 0,
        discount: 0,
        total: 200,
      ));

      expect(order.items, hasLength(1));
      final left = await ds.getCart(_consumer.id);
      expect(left.items.map((e) => e.id), ['bad']);
    }, skip: MockConfig.useMock ? 'Live checkout path only' : false);
  });

  group('M08 — a refreshed request is retried at most once', () {
    test('a 401 that persists after refresh fails instead of looping',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        PrefsKeys.authToken: 'old',
        PrefsKeys.authRefreshToken: 'r1',
      });
      final server = ScriptedAdapter();
      final dio = scriptedDio(server);
      dio.interceptors.add(TokenRefreshInterceptor(
        dio: dio,
        secureStorage: const FlutterSecureStorage(),
        onRefreshFailed: () async {},
      ));
      server.reply('GET', '/api/x', 401); // still 401 with the new token
      server.reply('POST', ApiEndpoints.refreshToken, 200, {'token': 'new'});

      await expectLater(
        dio.get<dynamic>('/api/x',
            options: Options(headers: {'X-Auth-Token': 'old'})),
        throwsA(isA<DioException>()),
      );
      expect(server.count('GET', '/api/x'), 2); // original + one retry
      expect(server.count('POST', ApiEndpoints.refreshToken), 1);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
