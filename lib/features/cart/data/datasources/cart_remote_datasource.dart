import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/network/json_list_unwrap.dart';
import '../../../../core/network/legacy_route_options.dart';
import '../../../../core/utils/app_location_cache.dart';
import '../../../orders/data/datasources/orders_remote_datasource.dart';
import '../../../orders/data/models/order_item_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_item_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_shipping_rules.dart';
import '../../domain/entities/place_order_params.dart';

abstract interface class CartRemoteDataSource {
  Future<CartEntity> getCart(String consumerId);

  Future<CartEntity> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  });

  Future<CartEntity> removeItem({
    required String consumerId,
    required String itemId,
  });

  Future<CartEntity> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  });

  Future<CartEntity> clearCart(String consumerId);

  Future<CouponEntity> applyCoupon({
    required String code,
    required double eligibleSubtotal,
  });

  Future<CartEntity> removeCoupon(String consumerId);

  Future<OrderEntity> placeOrder(PlaceOrderParams params);

  Future<CartItemEntity> buildLineFromListing(String listingId, int quantity);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._dio, this._orders);

  final Dio _dio;
  final OrdersRemoteDataSource _orders;

  static final List<CartItemEntity> _items = [];
  static CouponEntity? _coupon;
  static String? _couponCodeInput;

  /// Consumer whose saved cart has been restored into [_items] this session.
  static String? _restoredFor;
  static const _savedCartKeyPrefix = 'cart_items_v1_';

  /// Drops the in-memory cart. Called on logout/user switch so cart
  /// contents never survive into the next account. Live mode has no cart
  /// API (`GET`/`POST` `/cart` 404); mock and live share this session store.
  /// The signed-out user's saved copy stays on the device, keyed by their
  /// id, and is restored only when that same user signs back in.
  static void clearSessionCache() {
    _items.clear();
    _coupon = null;
    _couponCodeInput = null;
    _restoredFor = null;
  }

  /// Live mode keeps the cart only on the device (no cart API), so without
  /// this it was lost every time the app was closed. Restores once per
  /// session per consumer. A mutation that lands while the read is pending
  /// can save a snapshot without the restored lines, so after merging, the
  /// restore saves again — that save runs last and holds both.
  Future<void> _restoreSavedCart(String consumerId) async {
    if (MockConfig.useMock || consumerId.isEmpty) return;
    if (_restoredFor == consumerId) return;
    _restoredFor = consumerId;
    var merged = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_savedCartKeyPrefix$consumerId');
      // Signed out (or switched user) while reading: don't resurrect it.
      if (raw == null || _restoredFor != consumerId) return;
      for (final json in (jsonDecode(raw) as List).whereType<Map>()) {
        final item = _savedItemFromJson(Map<String, dynamic>.from(json));
        if (item != null &&
            !_items.any((e) => e.listingId == item.listingId)) {
          _items.add(item);
          merged = true;
        }
      }
    } catch (_) {
      // Fail open: an unreadable saved cart is just an empty cart.
    }
    if (merged) await _saveCart(consumerId);
  }

  Future<void> _saveCart(String consumerId) async {
    if (MockConfig.useMock || consumerId.isEmpty) return;
    // Only the consumer whose cart is loaded may overwrite their saved copy.
    if (_restoredFor != consumerId) return;
    // Snapshot BEFORE the await: a sign-out while prefs load clears _items,
    // and writing that would wipe this user's saved cart.
    final snapshot = jsonEncode(_items.map(_savedItemToJson).toList());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_savedCartKeyPrefix$consumerId', snapshot);
    } catch (_) {
      // Best effort: the in-memory cart is still correct for this session.
    }
  }

  static Map<String, Object?> _savedItemToJson(CartItemEntity e) => {
        'id': e.id,
        'listingId': e.listingId,
        'listingName': e.listingName,
        'listingImage': e.listingImage,
        'listingSlug': e.listingSlug,
        'vendorId': e.vendorId,
        'vendorName': e.vendorName,
        'vendorStoreName': e.vendorStoreName,
        'vendorAvatar': e.vendorAvatar,
        'vendorRating': e.vendorRating,
        'vendorVerified': e.vendorVerified,
        'price': e.price,
        'compareAtPrice': e.compareAtPrice,
        'quantity': e.quantity,
        'maxQuantity': e.maxQuantity,
        'category': e.category,
        'condition': e.condition,
        'shippingAvailable': e.shippingAvailable,
        'shippingCost': e.shippingCost,
        'isAvailable': e.isAvailable,
        'addedAt': e.addedAt.toIso8601String(),
      };

  static CartItemEntity? _savedItemFromJson(Map<String, dynamic> j) {
    final id = j['id'];
    final listingId = j['listingId'];
    final price = j['price'];
    final quantity = j['quantity'];
    if (id is! String || listingId is! String) return null;
    if (price is! num || quantity is! int || quantity < 1) return null;
    String str(String key) => j[key] is String ? j[key] as String : '';
    double? optNum(String key) => (j[key] as num?)?.toDouble();
    return CartItemEntity(
      id: id,
      listingId: listingId,
      listingName: str('listingName'),
      listingImage: str('listingImage'),
      listingSlug: str('listingSlug'),
      vendorId: str('vendorId'),
      vendorName: str('vendorName'),
      vendorStoreName: str('vendorStoreName'),
      vendorAvatar: str('vendorAvatar'),
      vendorRating: optNum('vendorRating'),
      vendorVerified: j['vendorVerified'] == true,
      price: price.toDouble(),
      compareAtPrice: optNum('compareAtPrice'),
      quantity: quantity,
      maxQuantity: j['maxQuantity'] is int ? j['maxQuantity'] as int : quantity,
      category: str('category'),
      condition: str('condition'),
      shippingAvailable: j['shippingAvailable'] == true,
      shippingCost: optNum('shippingCost') ?? 0,
      isAvailable: j['isAvailable'] != false,
      addedAt: DateTime.tryParse(str('addedAt')) ?? DateTime.now(),
    );
  }

  String _vendorIdForListing(String listingId) {
    const v2 = {'listing_003', 'listing_016', 'listing_002'};
    return v2.contains(listingId) ? 'vendor_002' : 'vendor_001';
  }

  (String name, String store, String avatar, double rating, bool verified)
      _vendorDisplay(String vendorId) {
    if (vendorId == 'vendor_002') {
      return (
        'Karim Hassan',
        'Cairo Fashion Hub',
        MockImages.avatar(4),
        4.7,
        true,
      );
    }
    return (
      mockVendorUser.name,
      mockVendorUser.storeName ?? mockVendorUser.name,
      MockImages.avatar(1),
      mockVendorUser.rating ?? 4.8,
      true,
    );
  }

  void _ensureMockSeed() {
    if (!MockConfig.useMock) return;
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    _items.addAll([
      CartItemEntity(
        id: 'cart_item_001',
        listingId: 'listing_009',
        listingName: 'PS5 Console + 2 Controllers',
        listingImage: MockImages.product(90),
        listingSlug: 'listing_009',
        vendorId: 'vendor_001',
        vendorName: mockVendorUser.name,
        vendorStoreName: mockVendorUser.storeName ?? mockVendorUser.name,
        vendorAvatar: MockImages.avatar(1),
        vendorRating: mockVendorUser.rating ?? 4.8,
        vendorVerified: true,
        price: 95000,
        compareAtPrice: 110000,
        quantity: 1,
        maxQuantity: 3,
        category: 'Electronics',
        condition: 'Like New',
        shippingAvailable: true,
        shippingCost: 0,
        isAvailable: true,
        addedAt: now.subtract(const Duration(hours: 2)),
      ),
      CartItemEntity(
        id: 'cart_item_002',
        listingId: 'listing_003',
        listingName: 'Nike Air Max 270',
        listingImage: MockImages.product(30),
        listingSlug: 'listing_003',
        vendorId: 'vendor_002',
        vendorName: 'Karim Hassan',
        vendorStoreName: 'Cairo Fashion Hub',
        vendorAvatar: MockImages.avatar(4),
        vendorRating: 4.7,
        vendorVerified: true,
        price: 12500,
        compareAtPrice: 18000,
        quantity: 2,
        maxQuantity: 5,
        category: 'Fashion',
        condition: 'New',
        shippingAvailable: true,
        shippingCost: 500,
        isAvailable: true,
        addedAt: now.subtract(const Duration(days: 1)),
      ),
      CartItemEntity(
        id: 'cart_item_003',
        listingId: 'listing_016',
        listingName: 'Parfum Chanel No.5 100ml',
        listingImage: MockImages.product(60),
        listingSlug: 'listing_016',
        vendorId: 'vendor_002',
        vendorName: 'Karim Hassan',
        vendorStoreName: 'Cairo Fashion Hub',
        vendorAvatar: MockImages.avatar(4),
        vendorRating: 4.7,
        vendorVerified: true,
        price: 28000,
        compareAtPrice: null,
        quantity: 1,
        maxQuantity: 2,
        category: 'Beauty',
        condition: 'New',
        shippingAvailable: true,
        shippingCost: 0,
        isAvailable: false,
        addedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  CartEntity _snapshot(String consumerId) {
    _ensureMockSeed();
    final sub = _items.fold<double>(0, (a, b) => a + b.price * b.quantity);
    final ship = _items.fold<double>(0, (a, b) => a + b.shippingCost);
    return CartEntity(
      id: 'cart_main',
      consumerId: consumerId,
      items: List<CartItemEntity>.from(_items),
      selectedItemIds: {},
      couponCode: _couponCodeInput,
      coupon: _coupon,
      subtotal: sub,
      shippingTotal: ship,
      discount: 0,
      total: sub + ship,
      itemCount: _items.length,
    );
  }

  CartItemEntity _fromListing(String listingId, int quantity, {String? cartItemId}) {
    final m = mockListingModels.firstWhere((e) => e.id == listingId);
    final vid = _vendorIdForListing(listingId);
    final vd = _vendorDisplay(vid);
    final compare = mockCompareAtByListingId[listingId];
    final img = m.imageUrls.isNotEmpty ? m.imageUrls.first : MockImages.product(20);
    final id = cartItemId ?? 'cart_item_${DateTime.now().microsecondsSinceEpoch}';
    return CartItemEntity(
      id: id,
      listingId: m.id,
      listingName: m.title,
      listingImage: img,
      listingSlug: m.id,
      vendorId: vid,
      vendorName: vd.$1,
      vendorStoreName: vd.$2,
      vendorAvatar: vd.$3,
      vendorRating: vd.$4,
      vendorVerified: vd.$5,
      price: m.price,
      compareAtPrice: compare,
      quantity: quantity,
      maxQuantity: 10,
      category: m.categoryLabel,
      condition: m.conditionLabel,
      shippingAvailable: true,
      shippingCost: cartLineShippingCost(
        shippingAvailable: true,
        listingShippingCost: m.shippingCost,
      ),
      isAvailable: true,
      addedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _listingPayloadRoot(Map<String, dynamic> json) {
    final nested = json['listing'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  CartItemEntity _fromListingPayload(
    Map<String, dynamic> json,
    int quantity, {
    String? cartItemId,
  }) {
    final root = _listingPayloadRoot(json);
    final id = cartItemId ?? 'cart_item_${DateTime.now().microsecondsSinceEpoch}';
    final listingId = (root['id'] ?? '').toString();

    final price = jsonDouble(root['price']);

    final sellerRaw = root['seller'] ?? root['vendor'] ?? json['seller'] ?? json['vendor'];
    final seller = sellerRaw is Map ? Map<String, dynamic>.from(sellerRaw) : <String, dynamic>{};

    final vid = (root['vendorId'] ??
            root['sellerId'] ??
            seller['id'] ??
            seller['vendorId'] ??
            '')
        .toString();

    final vendorName = (seller['name'] ?? seller['displayName'] ?? '').toString();
    final storeName =
        (seller['storeName'] ?? seller['businessName'] ?? vendorName).toString();
    final avatar = (seller['avatarUrl'] ?? seller['avatar'] ?? '').toString();
    final sellerRatingRaw = seller['rating'] ?? seller['averageRating'];
    // Missing/zero rating means "no reviews yet" — never fabricate a score.
    final sellerRating =
        sellerRatingRaw == null ? null : jsonDouble(sellerRatingRaw);
    final verified = seller['verified'] == true || seller['isVerified'] == true;

    final imgs = root['imageUrls'];
    final listingImage = imgs is List && imgs.isNotEmpty
        ? imgs.first?.toString() ?? ''
        : (root['imageUrl'] ?? '').toString();

    final compareRaw = root['compareAtPrice'] ?? root['compare_at_price'];
    final compare = compareRaw == null ? null : jsonDouble(compareRaw);

    final catRaw = root['categoryLabel'] ?? root['category'];
    final cat = catRaw is String
        ? catRaw
        : catRaw is Map && catRaw['name'] is String
            ? catRaw['name'] as String
            : catRaw?.toString() ?? '';

    final condRaw = root['conditionLabel'] ?? root['condition'];
    final condition =
        condRaw is String ? condRaw : condRaw?.toString() ?? '';

    // Missing stock is 0 (unavailable) — never an invented number.
    final stock = _intFromJson(
      root['stockQuantity'] ?? root['stock'] ?? root['quantity'],
      0,
    );

    final shipAvail =
        (root['shippingAvailable'] ?? json['shippingAvailable']) == true;
    final shippingCost = cartLineShippingCost(
      shippingAvailable: shipAvail,
      listingShippingCost: jsonDouble(root['shippingCost'] ?? json['shippingCost']),
    );

    return CartItemEntity(
      id: id,
      listingId: listingId,
      listingName: (root['title'] ?? root['name'] ?? '').toString(),
      listingImage: listingImage,
      listingSlug: (root['slug'] ?? listingId).toString(),
      vendorId: vid.isEmpty ? 'vendor_unknown' : vid,
      vendorName: vendorName.isEmpty ? '—' : vendorName,
      vendorStoreName: storeName.isEmpty ? vendorName : storeName,
      vendorAvatar: avatar,
      vendorRating: (sellerRating != null && sellerRating > 0) ? sellerRating : null,
      vendorVerified: verified,
      price: price,
      compareAtPrice: compare,
      quantity: quantity,
      maxQuantity: stock.clamp(1, 999),
      category: cat,
      condition: condition,
      shippingAvailable: shipAvail,
      shippingCost: shippingCost,
      isAvailable: root['isAvailable'] != false && stock > 0,
      addedAt: DateTime.now(),
    );
  }

  int _intFromJson(Object? v, int fallback) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  Future<CartEntity> _localCart(String consumerId) {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_snapshot(consumerId));
    }
    return Future<CartEntity>.value(_snapshot(consumerId));
  }

  @override
  Future<CartEntity> getCart(String consumerId) async {
    await _restoreSavedCart(consumerId);
    return _localCart(consumerId);
  }

  @override
  Future<CartEntity> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  }) async {
    await _restoreSavedCart(consumerId);
    if (MockConfig.useMock) _ensureMockSeed();
    final idx = _items.indexWhere((e) => e.listingId == item.listingId);
    if (idx >= 0) {
      final cur = _items[idx];
      final nextQty = (cur.quantity + item.quantity).clamp(1, cur.maxQuantity);
      _items[idx] = cur.copyWith(quantity: nextQty);
    } else {
      _items.add(item);
    }
    await _saveCart(consumerId);
    return _localCart(consumerId);
  }

  @override
  Future<CartEntity> removeItem({
    required String consumerId,
    required String itemId,
  }) async {
    await _restoreSavedCart(consumerId);
    _items.removeWhere((e) => e.id == itemId);
    await _saveCart(consumerId);
    return _localCart(consumerId);
  }

  @override
  Future<CartEntity> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  }) async {
    await _restoreSavedCart(consumerId);
    final idx = _items.indexWhere((e) => e.id == itemId);
    if (idx >= 0) {
      if (quantity <= 0) {
        _items.removeAt(idx);
      } else {
        final cur = _items[idx];
        _items[idx] = cur.copyWith(
          quantity: quantity.clamp(1, cur.maxQuantity),
        );
      }
    }
    await _saveCart(consumerId);
    return _localCart(consumerId);
  }

  @override
  Future<CartEntity> clearCart(String consumerId) async {
    await _restoreSavedCart(consumerId);
    _items.clear();
    _coupon = null;
    _couponCodeInput = null;
    await _saveCart(consumerId);
    return _localCart(consumerId);
  }

  @override
  Future<CouponEntity> applyCoupon({
    required String code,
    required double eligibleSubtotal,
  }) async {
    if (!MockConfig.useMock) {
      throw CouponException('unavailable');
    }
    await MockConfig.simulate(null);
    final upper = code.trim().toUpperCase();
    if (upper == 'SAVE10') {
      if (eligibleSubtotal < 5000) {
        throw CouponException('minOrder');
      }
      final c = CouponEntity(
        code: upper,
        discountType: DiscountType.percentage,
        discountValue: 10,
        maxDiscount: 5000,
        isValid: true,
        message: '',
      );
      _coupon = c;
      _couponCodeInput = upper;
      return c;
    }
    if (upper == 'FREE500') {
      final c = CouponEntity(
        code: upper,
        discountType: DiscountType.fixed,
        discountValue: 500,
        isValid: true,
        message: 'FREE500',
      );
      _coupon = c;
      _couponCodeInput = upper;
      return c;
    }
    if (upper == 'WELCOME') {
      final c = CouponEntity(
        code: upper,
        discountType: DiscountType.percentage,
        discountValue: 15,
        maxDiscount: 3000,
        isValid: true,
        message: 'WELCOME',
      );
      _coupon = c;
      _couponCodeInput = upper;
      return c;
    }
    throw CouponException('invalid');
  }

  @override
  Future<CartEntity> removeCoupon(String consumerId) {
    _coupon = null;
    _couponCodeInput = null;
    return _localCart(consumerId);
  }

  @override
  Future<OrderEntity> placeOrder(PlaceOrderParams params) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      final first = params.items.isNotEmpty ? params.items.first : null;
      final vid = first?.vendorId ?? 'vendor_001';
      final vd = _vendorDisplay(vid);
      final oid =
          'XS-2024-${(DateTime.now().millisecondsSinceEpoch % 899) + 100}';
      final now = DateTime.now();
      final lines = <OrderItemEntity>[];
      for (var i = 0; i < params.items.length; i++) {
        final c = params.items[i];
        lines.add(
          OrderItemEntity(
            id: 'oi_${c.listingId}_$i',
            listingId: c.listingId,
            listingName: c.listingName,
            listingImage: c.listingImage,
            category: c.category,
            condition: c.condition,
            price: c.price,
            quantity: c.quantity,
            total: c.price * c.quantity,
          ),
        );
      }
      final order = OrderEntity(
        id: oid,
        consumerId: params.consumerId,
        consumerName: mockConsumerUser.name,
        consumerPhone: mockConsumerUser.phoneNumber,
        consumerAvatar: MockImages.avatar(2),
        vendorId: vid,
        vendorName: vd.$1,
        vendorStoreName: vd.$2,
        vendorAvatar: vd.$3,
        vendorRating: vd.$4,
        items: lines,
        status: OrderStatus.pending,
        paymentMethod: params.paymentMethod,
        isPaid: params.paymentMethod != PaymentMethod.cashOnDelivery,
        deliveryAddress: params.deliveryAddress,
        subtotal: params.subtotal,
        shippingCost: params.shippingTotal,
        discount: params.discount,
        total: params.total,
        notes: params.deliveryNote,
        createdAt: now,
        updatedAt: now,
      );
      _items.clear();
      _coupon = null;
      _couponCodeInput = null;
      return order;
    }
    // CONFIRMED (Postman + live probe, 2026-08-14): the backend has no
    // multi-item/cart checkout endpoint — POST /api/orders takes exactly
    // one {listingId, quantity, latitude, longitude}. There is no batch
    // variant, so checkout places one real order per distinct cart line
    // and the confirmation screen shows a combined view built from the
    // already-known cart context (address/payment/totals) plus whatever
    // id/status each created order echoes back. This is a stopgap, not a
    // true atomic multi-item order — see the production-readiness audit
    // for why a real backend cart is the correct long-term fix.
    if (params.items.isEmpty) {
      throw const ServerException('Cart is empty');
    }
    // Check every line BEFORE placing any order: with one order per line,
    // a line found short mid-loop would leave the cart half-ordered.
    final inStock = await Future.wait(params.items.map(_hasStock));
    final short = [
      for (var i = 0; i < params.items.length; i++)
        if (inStock[i] == false) params.items[i],
    ];
    if (short.isNotEmpty) {
      await Future.wait(short.map(_refreshShortLine));
      await _saveCart(params.consumerId);
      throw const ServerException(outOfStockErrorCode);
    }
    final fallbackAddress = OrderAddressModelX.fromEntity(params.deliveryAddress);
    // A map-pinned delivery address (see showMapAddressPicker) carries its
    // own coordinates — prefer those over the device's last-known GPS fix,
    // since the two can legitimately differ (ordering for a different
    // address than the one the phone is currently at). Addresses saved
    // before the picker existed, or typed without dropping a pin, have no
    // lat/lng and fall back to AppLocationCache exactly as before.
    final pinnedLat = params.deliveryAddress.latitude;
    final pinnedLng = params.deliveryAddress.longitude;
    final hasValidPin = pinnedLat != null &&
        pinnedLng != null &&
        AppLocationCache.isInEgypt(pinnedLat, pinnedLng);
    final orderLatitude = hasValidPin ? pinnedLat : AppLocationCache.latitude;
    final orderLongitude = hasValidPin ? pinnedLng : AppLocationCache.longitude;
    final createdOrders = <OrderModel>[];
    Object? lastError;
    for (final item in params.items) {
      try {
        final created = await _orders.createOrder(
          listingId: item.listingId,
          quantity: item.quantity,
          latitude: orderLatitude,
          longitude: orderLongitude,
          fallbackItem: OrderItemModel(
            id: 'oi_${item.listingId}',
            listingId: item.listingId,
            listingName: item.listingName,
            listingImage: item.listingImage,
            category: item.category,
            condition: item.condition,
            price: item.price,
            quantity: item.quantity,
            total: item.price * item.quantity,
          ),
          fallbackAddress: fallbackAddress,
          fallbackPayment: params.paymentMethod,
          notes: params.deliveryNote,
        );
        createdOrders.add(created);
        // Only the line that actually got an order removes itself from
        // the cart — a failed line stays so the customer can retry just
        // that item instead of the whole checkout re-ordering everything
        // (including lines that already succeeded).
        _items.removeWhere((e) => e.id == item.id);
      } catch (e) {
        // One failed line must not discard orders already placed for the
        // others — keep going so every line gets its own outcome instead
        // of the whole checkout aborting on the first failure.
        lastError = e;
      }
    }
    if (createdOrders.isEmpty) {
      // Nothing went through: cart is untouched (every line stayed), so
      // rethrow the real failure and let the whole checkout be retried.
      if (lastError != null) throw lastError;
      throw const ServerException('Cart is empty');
    }
    // Ordered lines left the cart; persist so they don't come back on the
    // next app start.
    await _saveCart(params.consumerId);
    // Combine the per-listing orders into one view for the confirmation
    // screen: real id/status/createdAt from the first created order, full
    // item list from all of them, totals from the already-known cart
    // context (more reliable than summing unconfirmed per-order totals).
    // When a line failed, `items` below naturally reflects only the
    // successes — the caller compares this against what was submitted to
    // tell the customer which line(s) didn't go through.
    final first = createdOrders.first.toEntity();
    _coupon = null;
    _couponCodeInput = null;
    return first.copyWith(
      items: createdOrders.expand((o) => o.items).map((m) => m.toEntity()).toList(),
      subtotal: params.subtotal,
      shippingCost: params.shippingTotal,
      discount: params.discount,
      total: params.total,
      notes: params.deliveryNote,
    );
  }

  /// `true`/`false` from `GET /api/listings/{id}/stock`; a 404 (listing
  /// gone or inactive) is `false`. `null` when the check can't answer
  /// (network, 5xx, unexpected body) — checkout then proceeds and the
  /// order POST stays the backend's final gate, so a stock-endpoint outage
  /// can't block every sale.
  Future<bool?> _hasStock(CartItemEntity line) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiEndpoints.apiListingStock(line.listingId, line.quantity),
        options: LegacyRouteOptions.allowNotFound(),
      );
      if (LegacyRouteOptions.isNotFound(res)) return false;
      final body = res.data;
      final data = body is Map ? body['data'] : body;
      return data is bool ? data : null;
    } on DioException {
      return null;
    }
  }

  /// Re-reads a short line's listing so the cart shows what's really left:
  /// quantity drops to the remaining stock, or the line is marked
  /// unavailable when nothing is left, the listing can't be read, or the
  /// listing still claims enough (the stock check is the authority, and
  /// this stops the same refused quantity from being resubmitted).
  Future<void> _refreshShortLine(CartItemEntity line) async {
    CartItemEntity? fresh;
    try {
      fresh = await buildLineFromListing(line.listingId, line.quantity);
    } on ServerException {
      fresh = null;
    }
    final idx = _items.indexWhere((e) => e.id == line.id);
    if (idx < 0) return;
    final cur = _items[idx];
    final left = fresh != null && fresh.isAvailable ? fresh.maxQuantity : 0;
    _items[idx] = left > 0 && left < cur.quantity
        ? cur.copyWith(quantity: left, maxQuantity: left)
        : cur.copyWith(isAvailable: false);
  }

  /// Used when adding from product — builds line from catalog.
  @override
  Future<CartItemEntity> buildLineFromListing(String listingId, int quantity) async {
    if (MockConfig.useMock) {
      return _fromListing(listingId, quantity);
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.apiListingDetail(listingId),
      );
      final raw = response.data;
      if (raw == null) throw const ServerException('Empty listing response');
      return _fromListingPayload(raw, quantity);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load listing');
    }
  }
}
