// Focused test for the map-pin address picker's effect on order placement
// (XST-102): a delivery address pinned via showMapAddressPicker
// (lib/shared/widgets/map_address_picker.dart) carries its own lat/lng on
// OrderAddress, and CartRemoteDataSourceImpl.placeOrder must send THOSE
// coordinates on `POST /api/orders` — not the device's last-known GPS fix
// (AppLocationCache) — since the two can legitimately differ (ordering for
// an address other than where the phone currently is). An address with no
// pin (saved before the picker existed, or typed without dropping one)
// keeps falling back to AppLocationCache exactly as before this feature.
//
// Mirrors test/checkout_order_flow_test.dart's non-widget provider-level
// harness (real Checkout/Cart notifiers + repository/datasource stack,
// only the Dio transport is faked) rather than driving the full
// CheckoutScreen UI, since this test is about the wire payload, not the
// address-sheet UI itself (covered separately by
// checkout_add_address_sheet_test.dart).

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/utils/app_location_cache.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_provider.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_state.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/profile/domain/entities/profile_entity.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_state.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object data, int statusCode) => ResponseBody.fromString(
  jsonEncode(data),
  statusCode,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Dio _fakeDio(_ScriptedAdapter adapter) =>
    Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
      ..httpClientAdapter = adapter;

UserEntity _consumer() => UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

CartItemEntity _seedItem() => CartItemEntity(
  id: 'cart_item_1',
  listingId: '501',
  listingName: 'Test Listing',
  listingImage: '',
  vendorId: 'vendor_1',
  vendorName: 'Test Vendor',
  vendorStoreName: 'Test Store',
  price: 100,
  quantity: 1,
  maxQuantity: 5,
  category: 'electronics',
  condition: 'New',
  addedAt: DateTime(2026, 1, 1),
);

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity _user;
  @override
  Future<UserEntity?> build() async => _user;
}

class _SeededCart extends Cart {
  _SeededCart({required this.items});
  final List<CartItemEntity> items;

  @override
  CartState build() {
    final ids = items.map((e) => e.id).toSet();
    final subtotal = items.fold<double>(
      0,
      (sum, e) => sum + e.price * e.quantity,
    );
    return CartState(
      items: items,
      selectedItemIds: ids,
      consumerId: 'consumer_1',
      subtotal: subtotal,
      total: subtotal,
    );
  }
}

/// Seeds Checkout with one saved address carrying a map-picked pin — a
/// coordinate clearly different from AppLocationCache's Cairo fallback, so
/// a test asserting on it can't pass by accident.
class _SeededPinnedAddressCheckout extends Checkout {
  @override
  CheckoutState build() {
    final s = super.build();
    return s.copyWith(
      savedAddresses: const [
        OrderAddress(
          fullName: 'Test Buyer',
          phone: '01012345678',
          street: '1 Test Street',
          city: 'Alexandria',
          wilaya: 'Alexandria',
          isDefault: true,
          latitude: 31.2001,
          longitude: 29.9187,
        ),
      ],
      selectedAddressIndex: 0,
    );
  }
}

/// Seeds Checkout with one saved address with no pin — the pre-existing
/// shape, still supported.
class _SeededUnpinnedAddressCheckout extends Checkout {
  @override
  CheckoutState build() {
    final s = super.build();
    return s.copyWith(
      savedAddresses: const [
        OrderAddress(
          fullName: 'Test Buyer',
          phone: '01012345678',
          street: '1 Test Street',
          city: 'Cairo',
          wilaya: 'Cairo',
          isDefault: true,
        ),
      ],
      selectedAddressIndex: 0,
    );
  }
}

class _VerifiedProfile extends ProfileNotifier {
  @override
  ProfileState build() {
    super.build();
    return ProfileState(
      profile: ProfileEntity(
        user: _consumer(),
        isEmailVerified: true,
        isPhoneVerified: true,
      ),
    );
  }
}

List<Override> _overrides({
  required Dio dio,
  required Checkout Function() checkout,
}) => [
  authProvider.overrideWith(() => _FakeAuth(_consumer())),
  dioProvider.overrideWithValue(dio),
  cartProvider.overrideWith(() => _SeededCart(items: [_seedItem()])),
  profileNotifierProvider.overrideWith(() => _VerifiedProfile()),
  checkoutProvider.overrideWith(checkout),
];

Future<ProviderContainer> _buildContainer(List<Override> overrides) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  container.listen(checkoutProvider, (_, __) {});
  await container.read(analyticsServiceProvider).ready;
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AppLocationCache.debugReset();
  });

  test(
    // Requires MOCK=false (default) — exercises CartRemoteDataSourceImpl's
    // live-order-creation branch, not its mock fixture branch.
    'a map-pinned delivery address sends its own coordinates, not AppLocationCache',
    skip: MockConfig.useMock,
    () async {
      Map<String, dynamic>? sentBody;
      final adapter = _ScriptedAdapter((options) async {
        sentBody = Map<String, dynamic>.from(options.data as Map);
        return _jsonBody({'id': 9001, 'status': 'pending'}, 201);
      });
      final container = await _buildContainer(
        _overrides(
          dio: _fakeDio(adapter),
          checkout: () => _SeededPinnedAddressCheckout(),
        ),
      );

      final order = await container
          .read(checkoutProvider.notifier)
          .placeOrder();

      expect(order, isNotNull);
      expect(sentBody, isNotNull);
      expect(sentBody!['latitude'], 31.2001);
      expect(sentBody!['longitude'], 29.9187);
      // Sanity check the pin is genuinely different from the fallback —
      // otherwise this assertion could pass even if the pin were ignored.
      expect(sentBody!['latitude'], isNot(AppLocationCache.fallbackLatitude));
    },
  );

  test(
    'an address with no pin still falls back to AppLocationCache',
    skip: MockConfig.useMock,
    () async {
      Map<String, dynamic>? sentBody;
      final adapter = _ScriptedAdapter((options) async {
        sentBody = Map<String, dynamic>.from(options.data as Map);
        return _jsonBody({'id': 9002, 'status': 'pending'}, 201);
      });
      final container = await _buildContainer(
        _overrides(
          dio: _fakeDio(adapter),
          checkout: () => _SeededUnpinnedAddressCheckout(),
        ),
      );

      final order = await container
          .read(checkoutProvider.notifier)
          .placeOrder();

      expect(order, isNotNull);
      expect(sentBody, isNotNull);
      expect(sentBody!['latitude'], AppLocationCache.fallbackLatitude);
      expect(sentBody!['longitude'], AppLocationCache.fallbackLongitude);
    },
  );
}
