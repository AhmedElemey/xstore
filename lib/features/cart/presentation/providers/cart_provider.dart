import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_item_entity.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/place_order_params.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import 'cart_dependencies.dart';
import 'cart_state.dart';

part 'cart_provider.g.dart';

extension CartStateX on CartState {
  int get itemCount => items.length;

  int get selectedCount => selectedItemIds.length;

  Iterable<CartItemEntity> get selectedAvailableItems =>
      items.where((e) => selectedItemIds.contains(e.id) && e.isAvailable);

  List<CartVendorGroup> get vendorGroups {
    final order = <String>[];
    final byVendor = <String, List<CartItemEntity>>{};
    for (final i in items) {
      if (!byVendor.containsKey(i.vendorId)) {
        order.add(i.vendorId);
        byVendor[i.vendorId] = [];
      }
      byVendor[i.vendorId]!.add(i);
    }
    return order.map((vid) {
      final list = byVendor[vid]!;
      final f = list.first;
      final sub = list.fold<double>(0, (a, b) => a + b.price * b.quantity);
      return CartVendorGroup(
        vendorId: f.vendorId,
        vendorName: f.vendorName,
        vendorStoreName: f.vendorStoreName,
        vendorAvatar: f.vendorAvatar,
        vendorRating: f.vendorRating,
        vendorVerified: f.vendorVerified,
        items: list,
        groupSubtotal: sub,
      );
    }).toList();
  }
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  // Bumped whenever the auth-listener below resets state on logout. This
  // provider is keepAlive, so it outlives any single screen — an async
  // mutator (addFromListing, placeOrder, ...) that's still in flight when
  // logout resets state would otherwise silently resurrect the previous
  // user's cart when its own `await` resolves and writes `state =`.
  // Mutators capture `_epoch` before their await and skip the write if it
  // no longer matches, same shape as the `_disposed` guard in
  // checkout_provider.dart / explore_provider.dart (there tied to widget
  // disposal instead of a logout reset).
  var _epoch = 0;

  @override
  CartState build() {
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (prev, next) {
      if (next.isLoading) return;
      final user = next.valueOrNull;
      if (user == null) {
        Future.microtask(() {
          CartRemoteDataSourceImpl.clearSessionCache();
          _epoch++;
          state = const CartState();
        });
      } else if (!user.isVendor) {
        Future.microtask(() => fetchCart());
      }
      // fireImmediately: this provider is first built lazily (the dock mounts
      // after the splash), by which point auth has usually already resolved,
      // so a plain listener would never see a change and never fetch.
    }, fireImmediately: true);
    return const CartState();
  }

  String? get _consumerId => ref.read(authProvider).valueOrNull?.id;

  void _setFromEntity(CartEntity e, {bool resetSelection = false}) {
    var sel = state.selectedItemIds;
    if (resetSelection || sel.isEmpty) {
      sel = e.items.where((x) => x.isAvailable).map((x) => x.id).toSet();
    } else {
      sel = sel.intersection(e.items.map((x) => x.id).toSet());
    }
    state = state.copyWith(items: e.items, selectedItemIds: sel);
    _recomputeTotals();
  }

  void _recomputeTotals() {
    var sub = 0.0;
    var ship = 0.0;
    for (final it in state.selectedAvailableItems) {
      sub += it.price * it.quantity;
      ship += it.shippingCost;
    }
    state = state.copyWith(
      subtotal: sub,
      shippingTotal: ship,
      total: sub + ship,
    );
  }

  Future<void> fetchCart() async {
    final id = _consumerId;
    if (id == null) return;
    final epoch = _epoch;
    state = state.copyWith(isLoading: true, error: null, consumerId: id);
    final result = await ref.read(getCartUseCaseProvider).call(id);
    if (_epoch != epoch) return;
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.toString()),
      (e) {
        state = state.copyWith(isLoading: false);
        final firstLoad = state.items.isEmpty;
        _setFromEntity(e, resetSelection: firstLoad);
      },
    );
  }

  Future<void> addFromListing({
    required String listingId,
    required int quantity,
  }) async {
    final id = _consumerId;
    if (id == null || quantity <= 0) return;
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(error: kOfflineErrorCode);
      return;
    }
    final prevIds = state.items.map((x) => x.id).toSet();
    final epoch = _epoch;
    state = state.copyWith(isUpdating: true, error: null);
    final result = await ref
        .read(addToCartUseCaseProvider)
        .call(consumerId: id, listingId: listingId, quantity: quantity);
    if (_epoch != epoch) return;
    result.fold(
      (f) => state = state.copyWith(isUpdating: false, error: f.toString()),
      (e) {
        state = state.copyWith(isUpdating: false);
        _setFromEntity(e);
        final newOnes = e.items.map((x) => x.id).toSet().difference(prevIds);
        state = state.copyWith(
          selectedItemIds: {...state.selectedItemIds, ...newOnes},
        );
        _recomputeTotals();
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvents.addToCart,
              properties: {
                AnalyticsProps.itemId: listingId,
                AnalyticsProps.quantity: quantity,
                AnalyticsProps.cartValueEgp: state.total,
              },
            );
      },
    );
  }

  Future<void> addListingEntity(ListingEntity listing, int quantity) async {
    await addFromListing(listingId: listing.id, quantity: quantity);
  }

  Future<void> reorderFromOrderItems(List<OrderItemEntity> lines) async {
    for (final line in lines) {
      await addFromListing(listingId: line.listingId, quantity: line.quantity);
    }
  }

  Future<void> removeItem(String itemId, {bool skipUndo = false}) async {
    final id = _consumerId;
    if (id == null) return;
    final snapshot = List<CartItemEntity>.from(state.items);
    final selectedSnapshot = Set<String>.from(state.selectedItemIds);
    final idx = snapshot.indexWhere((e) => e.id == itemId);
    if (idx < 0) return;
    final prev = snapshot[idx];
    final optimistic = snapshot.where((e) => e.id != itemId).toList();
    final sel = Set<String>.from(selectedSnapshot)..remove(itemId);
    state = state.copyWith(
      items: optimistic,
      selectedItemIds: sel,
      isUpdating: true,
      error: null,
      lastRemovedItem: skipUndo ? null : prev,
      lastRemovedIndex: skipUndo ? null : idx,
    );
    _recomputeTotals();
    final epoch = _epoch;
    final result = await ref
        .read(removeFromCartUseCaseProvider)
        .call(consumerId: id, itemId: itemId);
    if (_epoch != epoch) return;
    result.fold(
      (f) {
        state = state.copyWith(
          isUpdating: false,
          error: f.toString(),
          items: snapshot,
          selectedItemIds: selectedSnapshot,
          lastRemovedItem: null,
          lastRemovedIndex: null,
        );
        _recomputeTotals();
      },
      (e) {
        state = state.copyWith(
          isUpdating: false,
          lastRemovedItem: skipUndo ? null : prev,
          lastRemovedIndex: skipUndo ? null : idx,
        );
        _setFromEntity(e);
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvents.removeFromCart,
              properties: {
                AnalyticsProps.itemId: prev.listingId,
                AnalyticsProps.quantity: prev.quantity,
                AnalyticsProps.cartValueEgp: state.total,
              },
            );
      },
    );
  }

  Future<void> undoRemove() async {
    final line = state.lastRemovedItem;
    final id = _consumerId;
    if (line == null || id == null) return;
    final epoch = _epoch;
    state = state.copyWith(isUpdating: true);
    final result = await ref
        .read(addOrUpdateCartItemUseCaseProvider)
        .call(consumerId: id, item: line);
    if (_epoch != epoch) return;
    result.fold(
      (f) => state = state.copyWith(isUpdating: false, error: f.toString()),
      (e) {
        state = state.copyWith(
          isUpdating: false,
          lastRemovedItem: null,
          lastRemovedIndex: null,
        );
        _setFromEntity(e);
      },
    );
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final id = _consumerId;
    if (id == null) return;
    final snapshot = state.items;
    state = state.copyWith(isUpdating: true, error: null);
    final optimistic = state.items
        .map(
          (e) => e.id == itemId
              ? e.copyWith(quantity: quantity.clamp(1, e.maxQuantity))
              : e,
        )
        .toList();
    state = state.copyWith(items: optimistic);
    _recomputeTotals();
    final epoch = _epoch;
    final result = await ref
        .read(updateQuantityUseCaseProvider)
        .call(consumerId: id, itemId: itemId, quantity: quantity);
    if (_epoch != epoch) return;
    result.fold(
      (f) {
        state = state.copyWith(
          isUpdating: false,
          items: snapshot,
          error: f.toString(),
        );
        _recomputeTotals();
      },
      (e) {
        state = state.copyWith(isUpdating: false);
        _setFromEntity(e);
      },
    );
  }

  Future<void> clearCart() async {
    final id = _consumerId;
    if (id == null) return;
    final epoch = _epoch;
    state = state.copyWith(isUpdating: true, error: null);
    final result = await ref.read(clearCartUseCaseProvider).call(id);
    if (_epoch != epoch) return;
    result.fold(
      (f) => state = state.copyWith(isUpdating: false, error: f.toString()),
      (e) {
        state = state.copyWith(isUpdating: false, selectedItemIds: {});
        _setFromEntity(e, resetSelection: true);
      },
    );
  }

  void toggleItemSelection(String itemId) {
    final next = Set<String>.from(state.selectedItemIds);
    if (next.contains(itemId)) {
      next.remove(itemId);
    } else {
      next.add(itemId);
    }
    state = state.copyWith(selectedItemIds: next);
    _recomputeTotals();
  }

  Future<void> saveForLater(String itemId) async {
    final idx = state.items.indexWhere((e) => e.id == itemId);
    if (idx < 0) return;
    final item = state.items[idx];
    ref.read(wishlistProvider.notifier).addFromCartItem(item);
    await removeItem(itemId, skipUndo: true);
  }

  Future<OrderEntity?> placeOrder(PlaceOrderParams params) async {
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(error: kOfflineErrorCode);
      return null;
    }
    final epoch = _epoch;
    state = state.copyWith(isUpdating: true, error: null);
    final result = await ref.read(placeOrderUseCaseProvider).call(params);
    if (_epoch != epoch) return null;
    return result.fold(
      (f) {
        state = state.copyWith(isUpdating: false, error: f.toString());
        return null;
      },
      (order) {
        state = state.copyWith(
          isUpdating: false,
          selectedItemIds: {},
          lastRemovedItem: null,
          lastRemovedIndex: null,
        );
        Future.microtask(fetchCart);
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvents.purchase,
              properties: {
                AnalyticsProps.orderId: order.id,
                AnalyticsProps.valueEgp: params.total,
                AnalyticsProps.currency: 'EGP',
                // Spec value is `cod`, not the enum name `cashOnDelivery`.
                AnalyticsProps.paymentType:
                    params.paymentMethod == PaymentMethod.cashOnDelivery
                    ? 'cod'
                    : params.paymentMethod.name,
                AnalyticsProps.itemCount: params.items.length,
              },
            );
        return order;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
