import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
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

  CartItemEntity buildLineFromListing(String listingId, int quantity);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static final List<CartItemEntity> _items = [];
  static CouponEntity? _coupon;
  static String? _couponCodeInput;

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

  @override
  Future<CartEntity> getCart(String consumerId) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_snapshot(consumerId));
    }
    final _ = _dio;
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<CartEntity> clearCart(String consumerId) async {
    if (MockConfig.useMock) {
      _items.clear();
      _coupon = null;
      _couponCodeInput = null;
      return MockConfig.simulate(_snapshot(consumerId));
    }
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<CartEntity> removeCoupon(String consumerId) async {
    if (MockConfig.useMock) {
      _coupon = null;
      _couponCodeInput = null;
      return MockConfig.simulate(_snapshot(consumerId));
    }
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  /// Used when adding from product — builds line from catalog.
  @override
  CartItemEntity buildLineFromListing(String listingId, int quantity) {
    return _fromListing(listingId, quantity);
  }
}
