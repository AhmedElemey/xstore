import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_item_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
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
  CartRemoteDataSourceImpl(this._dio);

  final Dio _dio;
  static const _cartPath = '/cart';

  static final List<CartItemEntity> _items = [];
  static CouponEntity? _coupon;
  static String? _couponCodeInput;

  /// Drops the mock in-memory cart. Called on logout/user switch so cart
  /// contents never survive into the next account (mock mode only — live
  /// mode always fetches from the API).
  static void clearSessionCache() {
    _items.clear();
    _coupon = null;
    _couponCodeInput = null;
  }

  String _vendorIdForListing(String listingId) {
    const v2 = {'listing_003', 'listing_016', 'listing_002'};
    return v2.contains(listingId) ? 'vendor_002' : 'vendor_001';
  }

  (String name, String store, String avatar, double rating, bool verified)
      _vendorDisplay(String vendorId) {
    if (vendorId == 'vendor_002') {
      return (
        'Karim Merabet',
        'Oran Fashion Hub',
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
        vendorName: 'Karim Merabet',
        vendorStoreName: 'Oran Fashion Hub',
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
        vendorName: 'Karim Merabet',
        vendorStoreName: 'Oran Fashion Hub',
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
      shippingCost: m.price >= 20000 ? 0 : 500,
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

    final price = _num(root['price']);

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
    final sellerRating = _num(seller['rating'] ?? seller['averageRating']);
    final verified = seller['verified'] == true || seller['isVerified'] == true;

    final imgs = root['imageUrls'];
    final listingImage = imgs is List && imgs.isNotEmpty
        ? imgs.first?.toString() ?? ''
        : (root['imageUrl'] ?? '').toString();

    final compareRaw = root['compareAtPrice'] ?? root['compare_at_price'];
    final compare = compareRaw == null ? null : _num(compareRaw);

    final catRaw = root['categoryLabel'] ?? root['category'];
    final cat = catRaw is String
        ? catRaw
        : catRaw is Map && catRaw['name'] is String
            ? catRaw['name'] as String
            : catRaw?.toString() ?? '';

    final condRaw = root['conditionLabel'] ?? root['condition'];
    final condition =
        condRaw is String ? condRaw : condRaw?.toString() ?? '';

    final stock = _intFromJson(root['stockQuantity'] ?? root['stock'] ?? root['quantity'], 10).clamp(1, 999);

    final shipAvail =
        json['shippingAvailable'] != false && root['shippingAvailable'] != false;
    final shippingCost = shipAvail ? (price >= 20000 ? 0.0 : 500.0) : 0.0;

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
      vendorRating: sellerRating == 0 ? 4.7 : sellerRating,
      vendorVerified: verified,
      price: price,
      compareAtPrice: compare,
      quantity: quantity,
      maxQuantity: stock,
      category: cat,
      condition: condition,
      shippingAvailable: shipAvail,
      shippingCost: shippingCost,
      isAvailable: root['isAvailable'] != false,
      addedAt: DateTime.now(),
    );
  }

  int _intFromJson(Object? v, int fallback) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  @override
  Future<CartEntity> getCart(String consumerId) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_snapshot(consumerId));
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_cartPath/$consumerId',
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty cart response');
      return _cartFromMap(consumerId, data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch cart');
    }
  }

  @override
  Future<CartEntity> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  }) async {
    if (MockConfig.useMock) {
      _ensureMockSeed();
      final idx = _items.indexWhere((e) => e.listingId == item.listingId);
      if (idx >= 0) {
        final cur = _items[idx];
        final nextQty = (cur.quantity + item.quantity).clamp(1, cur.maxQuantity);
        _items[idx] = cur.copyWith(quantity: nextQty);
      } else {
        _items.add(item);
      }
      return MockConfig.simulate(_snapshot(consumerId));
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_cartPath/$consumerId/items',
        data: _cartItemToMap(item),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty cart response');
      return _cartFromMap(consumerId, data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update cart');
    }
  }

  @override
  Future<CartEntity> removeItem({
    required String consumerId,
    required String itemId,
  }) async {
    if (MockConfig.useMock) {
      _items.removeWhere((e) => e.id == itemId);
      return MockConfig.simulate(_snapshot(consumerId));
    }
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_cartPath/$consumerId/items/$itemId',
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty cart response');
      return _cartFromMap(consumerId, data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to remove cart item');
    }
  }

  @override
  Future<CartEntity> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  }) async {
    if (MockConfig.useMock) {
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
      return MockConfig.simulate(_snapshot(consumerId));
    }
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_cartPath/$consumerId/items/$itemId',
        data: {'quantity': quantity},
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty cart response');
      return _cartFromMap(consumerId, data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update item quantity');
    }
  }

  @override
  Future<CartEntity> clearCart(String consumerId) async {
    if (MockConfig.useMock) {
      _items.clear();
      _coupon = null;
      _couponCodeInput = null;
      return MockConfig.simulate(_snapshot(consumerId));
    }
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_cartPath/$consumerId',
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty cart response');
      return _cartFromMap(consumerId, data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to clear cart');
    }
  }

  @override
  Future<CouponEntity> applyCoupon({
    required String code,
    required double eligibleSubtotal,
  }) async {
    if (MockConfig.useMock) {
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
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_cartPath/coupons/apply',
        data: {'code': code.trim(), 'eligibleSubtotal': eligibleSubtotal},
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty coupon response');
      return _couponFromMap(data);
    } on DioException catch (e) {
      throw CouponException(e.message ?? 'invalid');
    }
  }

  @override
  Future<CartEntity> removeCoupon(String consumerId) async {
    if (MockConfig.useMock) {
      _coupon = null;
      _couponCodeInput = null;
      return MockConfig.simulate(_snapshot(consumerId));
    }
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_cartPath/$consumerId/coupon',
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty cart response');
      return _cartFromMap(consumerId, data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to remove coupon');
    }
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
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/orders',
        data: _placeOrderPayload(params),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty order response');
      return _orderFromMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to place order');
    }
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

  CartEntity _cartFromMap(String consumerId, Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => _cartItemFromMap(Map<String, dynamic>.from(e)))
        .toList();
    return CartEntity(
      id: (json['id'] ?? 'cart_$consumerId').toString(),
      consumerId: (json['consumerId'] ?? consumerId).toString(),
      items: items,
      selectedItemIds: {},
      couponCode: json['couponCode'] as String?,
      coupon: json['coupon'] is Map<String, dynamic>
          ? _couponFromMap(json['coupon'] as Map<String, dynamic>)
          : null,
      subtotal: _num(json['subtotal']),
      shippingTotal: _num(json['shippingTotal']),
      discount: _num(json['discount']),
      total: _num(json['total']),
      itemCount: (json['itemCount'] as num?)?.toInt() ?? items.length,
    );
  }

  CartItemEntity _cartItemFromMap(Map<String, dynamic> json) {
    return CartItemEntity(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listingId'] ?? '').toString(),
      listingName: (json['listingName'] ?? '').toString(),
      listingImage: (json['listingImage'] ?? '').toString(),
      listingSlug: (json['listingSlug'] ?? '').toString(),
      vendorId: (json['vendorId'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? '').toString(),
      vendorStoreName: (json['vendorStoreName'] ?? '').toString(),
      vendorAvatar: (json['vendorAvatar'] ?? '').toString(),
      vendorRating: _num(json['vendorRating']),
      vendorVerified: json['vendorVerified'] != false,
      price: _num(json['price']),
      compareAtPrice: json['compareAtPrice'] == null
          ? null
          : _num(json['compareAtPrice']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      maxQuantity: (json['maxQuantity'] as num?)?.toInt() ?? 1,
      category: (json['category'] ?? '').toString(),
      condition: (json['condition'] ?? '').toString(),
      shippingAvailable: json['shippingAvailable'] != false,
      shippingCost: _num(json['shippingCost']),
      isAvailable: json['isAvailable'] != false,
      addedAt:
          DateTime.tryParse((json['addedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  CouponEntity _couponFromMap(Map<String, dynamic> json) {
    final type = (json['discountType'] ?? '').toString().toLowerCase();
    return CouponEntity(
      code: (json['code'] ?? '').toString(),
      discountType: type == 'fixed'
          ? DiscountType.fixed
          : DiscountType.percentage,
      discountValue: _num(json['discountValue']),
      minOrderAmount: json['minOrderAmount'] == null
          ? null
          : _num(json['minOrderAmount']),
      maxDiscount:
          json['maxDiscount'] == null ? null : _num(json['maxDiscount']),
      isValid: json['isValid'] != false,
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> _cartItemToMap(CartItemEntity item) => {
        'id': item.id,
        'listingId': item.listingId,
        'listingName': item.listingName,
        'listingImage': item.listingImage,
        'listingSlug': item.listingSlug,
        'vendorId': item.vendorId,
        'vendorName': item.vendorName,
        'vendorStoreName': item.vendorStoreName,
        'vendorAvatar': item.vendorAvatar,
        'vendorRating': item.vendorRating,
        'vendorVerified': item.vendorVerified,
        'price': item.price,
        'compareAtPrice': item.compareAtPrice,
        'quantity': item.quantity,
        'maxQuantity': item.maxQuantity,
        'category': item.category,
        'condition': item.condition,
        'shippingAvailable': item.shippingAvailable,
        'shippingCost': item.shippingCost,
        'isAvailable': item.isAvailable,
      };

  Map<String, dynamic> _placeOrderPayload(PlaceOrderParams params) => {
        'consumerId': params.consumerId,
        'deliveryAddress': {
          'fullName': params.deliveryAddress.fullName,
          'phone': params.deliveryAddress.phone,
          'street': params.deliveryAddress.street,
          'city': params.deliveryAddress.city,
          'wilaya': params.deliveryAddress.wilaya,
          'postalCode': params.deliveryAddress.postalCode,
        },
        'paymentMethod': params.paymentMethod.name,
        'items': params.items
            .map(
              (e) => {
                'listingId': e.listingId,
                'listingName': e.listingName,
                'listingImage': e.listingImage,
                'category': e.category,
                'condition': e.condition,
                'price': e.price,
                'quantity': e.quantity,
                'total': e.price * e.quantity,
              },
            )
            .toList(),
        'subtotal': params.subtotal,
        'shippingTotal': params.shippingTotal,
        'discount': params.discount,
        'total': params.total,
        'deliveryNote': params.deliveryNote,
      };

  OrderEntity _orderFromMap(Map<String, dynamic> json) {
    final address = Map<String, dynamic>.from(
      (json['deliveryAddress'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final status = (json['status'] ?? '').toString().toLowerCase();
    final payment = (json['paymentMethod'] ?? '').toString().toLowerCase();
    return OrderEntity(
      id: (json['id'] ?? '').toString(),
      consumerId: (json['consumerId'] ?? '').toString(),
      consumerName: (json['consumerName'] ?? '').toString(),
      consumerPhone: (json['consumerPhone'] ?? '').toString(),
      consumerAvatar: (json['consumerAvatar'] ?? '').toString(),
      vendorId: (json['vendorId'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? '').toString(),
      vendorStoreName: (json['vendorStoreName'] ?? '').toString(),
      vendorAvatar: (json['vendorAvatar'] ?? '').toString(),
      vendorRating: _num(json['vendorRating']),
      items: items
          .map(
            (e) => OrderItemEntity(
              id: (e['id'] ?? '').toString(),
              listingId: (e['listingId'] ?? '').toString(),
              listingName: (e['listingName'] ?? '').toString(),
              listingImage: (e['listingImage'] ?? '').toString(),
              category: (e['category'] ?? '').toString(),
              condition: (e['condition'] ?? '').toString(),
              price: _num(e['price']),
              quantity: (e['quantity'] as num?)?.toInt() ?? 1,
              total: _num(e['total']),
            ),
          )
          .toList(),
      status: switch (status) {
        'confirmed' => OrderStatus.confirmed,
        'processing' => OrderStatus.processing,
        'shipped' => OrderStatus.shipped,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        'refunded' => OrderStatus.refunded,
        _ => OrderStatus.pending,
      },
      paymentMethod: switch (payment) {
        'cibcard' => PaymentMethod.cibCard,
        'dahabicard' => PaymentMethod.dahabiCard,
        'baridimob' => PaymentMethod.baridimob,
        _ => PaymentMethod.cashOnDelivery,
      },
      isPaid: json['isPaid'] == true,
      deliveryAddress: OrderAddress(
        fullName: (address['fullName'] ?? '').toString(),
        phone: (address['phone'] ?? '').toString(),
        street: (address['street'] ?? '').toString(),
        city: (address['city'] ?? '').toString(),
        wilaya: (address['wilaya'] ?? '').toString(),
        postalCode: address['postalCode'] as String?,
      ),
      subtotal: _num(json['subtotal']),
      shippingCost: _num(json['shippingCost']),
      discount: _num(json['discount']),
      total: _num(json['total']),
      trackingNumber: json['trackingNumber'] as String?,
      courierName: json['courierName'] as String?,
      trackingLocation: json['trackingLocation'] as String?,
      estimatedDelivery: DateTime.tryParse(
        (json['estimatedDelivery'] ?? '').toString(),
      ),
      cancelReason: json['cancelReason'] as String?,
      notes: json['notes'] as String?,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      confirmedAt:
          DateTime.tryParse((json['confirmedAt'] ?? '').toString()),
      shippedAt: DateTime.tryParse((json['shippedAt'] ?? '').toString()),
      deliveredAt: DateTime.tryParse((json['deliveredAt'] ?? '').toString()),
      cancelledAt: DateTime.tryParse((json['cancelledAt'] ?? '').toString()),
    );
  }

  double _num(Object? value) => (value as num?)?.toDouble() ?? 0;
}
