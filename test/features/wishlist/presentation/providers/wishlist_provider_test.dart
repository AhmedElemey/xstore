// Regression test for: the "Price Dropped" wishlist filter showed "No price
// dropped items" even for a card that visibly rendered a struck-through
// price. Root cause — `priceDropCount`/the `priceDropped` filter/the
// `priceDrop` sort all keyed off `priceDropPercent` alone, a field the
// backend has to compute and may omit, while the card's strikethrough
// (wishlist_item_card.dart's `strike`) ALSO accepts `previousPrice` on its
// own. `WishlistItemEntity.effectiveDropPercent` now backs every one of
// these consumers, falling back to computing the percentage from
// `previousPrice` vs `price` when the backend doesn't send
// `priceDropPercent` — without touching `compareAtPrice`, which is a
// vendor-set markdown unrelated to "the price dropped since you saved it"
// (see `WishlistSortOption.biggestDiscount`, which is deliberately the
// separate, compareAtPrice-only concept).
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:xstore/features/wishlist/presentation/providers/wishlist_state.dart';

class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);
  final Map<String, Object? Function(RequestOptions options)> _routes;
  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = _routes[_key(options)];
    if (route == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('unscripted request: ${_key(options)}'),
        ),
      );
      return;
    }
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: route(options)),
    );
  }
}

Dio _fakeDio(Map<String, Object? Function(RequestOptions)> routes) {
  final d = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

/// A wishlist item whose price genuinely dropped since it was saved
/// (previousPrice > price) but whose backend response — plausibly, since
/// it's a derived field the backend may not always compute — omits
/// `priceDropPercent` entirely.
Map<String, dynamic> _droppedItemMissingPercent() => {
  'id': 'wish_1',
  'listingId': '9001',
  'listingName': 'Wireless Earbuds',
  'listingImages': <String>[],
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'price': 400,
  'previousPrice': 500,
  'category': 'Electronics',
  'condition': 'New',
  'isAvailable': true,
  'isInCart': false,
  'addedAt': '2026-08-01T00:00:00.000Z',
  'lastPriceCheckAt': '2026-09-01T00:00:00.000Z',
};

Map<String, dynamic> _steadyPriceItem() => {
  'id': 'wish_2',
  'listingId': '9002',
  'listingName': 'Bluetooth Speaker',
  'listingImages': <String>[],
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'price': 300,
  'category': 'Electronics',
  'condition': 'New',
  'isAvailable': true,
  'isInCart': false,
  'addedAt': '2026-08-01T00:00:00.000Z',
  'lastPriceCheckAt': '2026-09-01T00:00:00.000Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'a price drop the backend tracked via previousPrice, but did not also '
    'summarize as priceDropPercent, still counts as "Price Dropped"',
    skip: MockConfig.useMock,
    () async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.wishlist}/consumer_1': (_) => [
          _droppedItemMissingPercent(),
          _steadyPriceItem(),
        ],
      });
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);
      container.listen(wishlistProvider, (_, __) {});
      await container.read(authProvider.future);

      await container.read(wishlistProvider.notifier).fetchWishlist();

      final state = container.read(wishlistProvider);
      expect(state.priceDropCount, 1);

      container.read(wishlistProvider.notifier).applyFilter(
            WishlistFilter.priceDropped,
          );

      final filtered = container.read(wishlistProvider).filteredItems;
      expect(filtered, hasLength(1));
      expect(filtered.single.listingId, '9001');
    },
  );
}
