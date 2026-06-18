import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_item_entity.dart';
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

  bool get hasUnavailable => items.any((e) => !e.isAvailable);

  Iterable<CartItemEntity> get selectedAvailableItems => items.where(
        (e) => selectedItemIds.contains(e.id) && e.isAvailable,
      );

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
      final sub = list.fold<double>(
        0,
        (a, b) => a + b.price * b.quantity,
      );
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

double cartDiscountOnSubtotal(double sub, CouponEntity c) {
  if (!c.isValid) return 0;
  if (c.minOrderAmount != null && sub < c.minOrderAmount!) return 0;
  double d;
  if (c.discountType == DiscountType.percentage) {
    d = sub * (c.discountValue / 100);
    if (c.maxDiscount != null && d > c.maxDiscount!) d = c.maxDiscount!;
  } else {
    d = c.discountValue;
  }
  return d > sub ? sub : d;
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  CartState build() {
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (prev, next) {
      if (next.isLoading) return;
      final user = next.valueOrNull;
      if (user == null) {
        Future.microtask(() => state = const CartState());
      } else if (!user.isVendor) {
        Future.microtask(() => fetchCart());
      }
    });
    return const CartState();
  }

  String? get _consumerId => ref.read(authProvider).valueOrNull?.id;

  void _setFromEntity(CartEntity e, {bool resetSelection = false}) {
    final preferred = {'cart_item_001', 'cart_item_002'};
    final ids = e.items.map((x) => x.id).toSet();
    var sel = state.selectedItemIds;
    if (resetSelection || sel.isEmpty) {
      final pick = preferred.intersection(ids);
      sel = pick.isEmpty
          ? e.items.where((x) => x.isAvailable).map((x) => x.id).toSet()
          : pick;
    } else {
      sel = sel.intersection(ids);
    }
    state = state.copyWith(
      items: e.items,
      coupon: e.coupon,
      couponErrorKey: null,
      selectedItemIds: sel,
    );
    _recomputeTotals();
  }

  void _recomputeTotals() {
    var sub = 0.0;
    var ship = 0.0;
    for (final it in state.selectedAvailableItems) {
      sub += it.price * it.quantity;
      ship += it.shippingCost;
    }
    final c = state.coupon;
    final disc = c != null ? cartDiscountOnSubtotal(sub, c) : 0.0;
    state = state.copyWith(
      subtotal: sub,
      shippingTotal: ship,
      discount: disc,
      total: sub + ship - disc,
    );
  }

  Future<void> fetchCart() async {
    final id = _consumerId;
    if (id == null) return;
    state = state.copyWith(isLoading: true, error: null, consumerId: id);
    final result = await ref.read(getCartUseCaseProvider).call(id);
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
    state = state.copyWith(isUpdating: true, error: null);
    final result = await ref.read(addToCartUseCaseProvider).call(
          consumerId: id,
          listingId: listingId,
          quantity: quantity,
        );
    result.fold(
      (f) => state = state.copyWith(isUpdating: false, error: f.toString()),
      (e) {
        state = state.copyWith(isUpdating: false);
        _setFromEntity(e);
        final newOnes =
            e.items.map((x) => x.id).toSet().difference(prevIds);
        state = state.copyWith(
          selectedItemIds: {...state.selectedItemIds, ...newOnes},
        );
        _recomputeTotals();
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
    final result = await ref.read(removeFromCartUseCaseProvider).call(
          consumerId: id,
          itemId: itemId,
        );
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
      },
    );
  }

  Future<void> undoRemove() async {
    final line = state.lastRemovedItem;
    final id = _consumerId;
    if (line == null || id == null) return;
    state = state.copyWith(isUpdating: true);
    final result = await ref.read(addOrUpdateCartItemUseCaseProvider).call(
          consumerId: id,
          item: line,
        );
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
    final result = await ref.read(updateQuantityUseCaseProvider).call(
          consumerId: id,
          itemId: itemId,
          quantity: quantity,
        );
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
    state = state.copyWith(isUpdating: true, error: null);
    final result = await ref.read(clearCartUseCaseProvider).call(id);
    result.fold(
      (f) => state = state.copyWith(isUpdating: false, error: f.toString()),
      (e) {
        state = state.copyWith(
          isUpdating: false,
          coupon: null,
          couponInput: '',
          selectedItemIds: {},
        );
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

  void selectAll() {
    final next = state.items.map((e) => e.id).toSet();
    state = state.copyWith(selectedItemIds: next);
    _recomputeTotals();
  }

  void deselectAll() {
    state = state.copyWith(selectedItemIds: {});
    _recomputeTotals();
  }

  bool get allSelected =>
      state.items.isNotEmpty &&
      state.selectedItemIds.length == state.items.length;

  void toggleSelectAll() {
    if (allSelected) {
      deselectAll();
    } else {
      selectAll();
    }
  }

  void setCouponInput(String v) {
    state = state.copyWith(couponInput: v, couponErrorKey: null);
  }

  Future<void> applyCoupon() async {
    final id = _consumerId;
    if (id == null) return;
    final code = state.couponInput.trim();
    if (code.isEmpty) return;
    var sub = 0.0;
    for (final it in state.selectedAvailableItems) {
      sub += it.price * it.quantity;
    }
    state = state.copyWith(isCouponLoading: true, couponErrorKey: null);
    final result = await ref.read(applyCouponUseCaseProvider).call(
          consumerId: id,
          code: code,
          eligibleSubtotal: sub,
        );
    var applied = false;
    result.fold(
      (f) {
        final key = switch (f) {
          ValidationFailure(:final message) when message == 'minOrder' =>
            'minOrder',
          ValidationFailure() => 'invalid',
          _ => 'invalid',
        };
        state = state.copyWith(isCouponLoading: false, couponErrorKey: key);
      },
      (_) => applied = true,
    );
    if (applied) {
      await fetchCart();
      state = state.copyWith(isCouponLoading: false);
    }
  }

  Future<void> removeCoupon() async {
    final id = _consumerId;
    if (id == null) return;
    state = state.copyWith(isCouponLoading: true);
    final result = await ref.read(removeCouponUseCaseProvider).call(id);
    var ok = false;
    result.fold(
      (f) => state = state.copyWith(isCouponLoading: false, error: f.toString()),
      (_) => ok = true,
    );
    if (ok) {
      state = state.copyWith(isCouponLoading: false, couponInput: '');
      await fetchCart();
    }
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
    state = state.copyWith(isUpdating: true, error: null);
    final result = await ref.read(placeOrderUseCaseProvider).call(params);
    return result.fold(
      (f) {
        state = state.copyWith(isUpdating: false, error: f.toString());
        return null;
      },
      (order) {
        state = state.copyWith(
          isUpdating: false,
          selectedItemIds: {},
          couponInput: '',
          lastRemovedItem: null,
          lastRemovedIndex: null,
        );
        Future.microtask(fetchCart);
        return order;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
