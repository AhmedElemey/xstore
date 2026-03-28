import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/wishlist_item_entity.dart';

abstract interface class WishlistRemoteDataSource {
  Future<List<WishlistItemEntity>> getWishlist(String consumerId);

  Future<WishlistItemEntity> addToWishlist({
    required String consumerId,
    required String listingId,
  });

  Future<void> removeFromWishlist({
    required String consumerId,
    required String listingId,
  });

  Future<void> clearWishlist(String consumerId);

  WishlistItemEntity entityFromCartItem(CartItemEntity item);

  WishlistItemEntity buildFromListingId(String listingId, {String? wishId});

  Future<WishlistItemEntity> upsertItem(WishlistItemEntity item);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static final List<WishlistItemEntity> _items = [];

  String _vendorIdForListing(String listingId) {
    const v2 = {'listing_003', 'listing_016', 'listing_002', 'listing_007', 'listing_010'};
    return v2.contains(listingId) ? 'vendor_002' : 'vendor_001';
  }

  (String name, String store, String avatar, bool verified) _vendorDisplay(
    String vendorId,
  ) {
    if (vendorId == 'vendor_002') {
      return ('Karim Merabet', 'Oran Fashion Hub', MockImages.avatar(4), false);
    }
    return (
      mockVendorUser.name,
      mockVendorUser.storeName ?? mockVendorUser.name,
      MockImages.avatar(1),
      true,
    );
  }

  int? _priceDrop(double price, double? previousPrice) {
    if (previousPrice == null || previousPrice <= 0) return null;
    if (price >= previousPrice) return null;
    return (((previousPrice - price) / previousPrice) * 100).round();
  }

  WishlistItemEntity _withComputedDrop(WishlistItemEntity e) {
    final p = e.previousPrice;
    final drop = _priceDrop(e.price, p);
    return e.copyWith(priceDropPercent: drop);
  }

  void _ensureMockSeed() {
    if (!MockConfig.useMock) return;
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    _items.addAll([
      WishlistItemEntity(
        id: 'wish_001',
        listingId: 'listing_001',
        listingName: 'iPhone 15 Pro 256GB',
        listingImages: MockImages.productImages(10),
        listingSlug: 'listing_001',
        vendorId: 'vendor_001',
        vendorName: mockVendorUser.name,
        vendorStoreName: mockVendorUser.storeName ?? mockVendorUser.name,
        vendorAvatar: MockImages.avatar(1),
        isVendorVerified: true,
        price: 185000,
        compareAtPrice: 220000,
        previousPrice: 200000,
        priceDropPercent: 7,
        category: 'Electronics',
        condition: 'Like New',
        rating: 4.8,
        reviewCount: 124,
        stockQuantity: 3,
        isAvailable: true,
        isInCart: false,
        shippingAvailable: true,
        shippingCost: 0,
        addedAt: now.subtract(const Duration(days: 3)),
        lastPriceCheckAt: now,
      ),
      WishlistItemEntity(
        id: 'wish_002',
        listingId: 'listing_005',
        listingName: 'MacBook Pro M3 14"',
        listingImages: MockImages.productImages(50),
        listingSlug: 'listing_005',
        vendorId: 'vendor_001',
        vendorName: mockVendorUser.name,
        vendorStoreName: mockVendorUser.storeName ?? mockVendorUser.name,
        vendorAvatar: MockImages.avatar(1),
        isVendorVerified: true,
        price: 280000,
        compareAtPrice: 320000,
        previousPrice: 280000,
        priceDropPercent: null,
        category: 'Electronics',
        condition: 'Like New',
        rating: 4.9,
        reviewCount: 56,
        stockQuantity: 1,
        isAvailable: true,
        isInCart: true,
        shippingAvailable: true,
        shippingCost: 0,
        addedAt: now.subtract(const Duration(days: 7)),
        lastPriceCheckAt: now,
      ),
      WishlistItemEntity(
        id: 'wish_003',
        listingId: 'listing_009',
        listingName: 'PS5 Console + 2 Controllers',
        listingImages: MockImages.productImages(90),
        listingSlug: 'listing_009',
        vendorId: 'vendor_001',
        vendorName: mockVendorUser.name,
        vendorStoreName: mockVendorUser.storeName ?? mockVendorUser.name,
        vendorAvatar: MockImages.avatar(1),
        isVendorVerified: true,
        price: 95000,
        compareAtPrice: 110000,
        previousPrice: 110000,
        priceDropPercent: 14,
        category: 'Electronics',
        condition: 'Like New',
        rating: 4.9,
        reviewCount: 312,
        stockQuantity: 2,
        isAvailable: true,
        isInCart: true,
        shippingAvailable: true,
        shippingCost: 0,
        addedAt: now.subtract(const Duration(days: 1)),
        lastPriceCheckAt: now,
      ),
      WishlistItemEntity(
        id: 'wish_004',
        listingId: 'listing_003',
        listingName: 'Nike Air Max 270',
        listingImages: MockImages.productImages(30),
        listingSlug: 'listing_003',
        vendorId: 'vendor_002',
        vendorName: 'Karim Merabet',
        vendorStoreName: 'Oran Fashion Hub',
        vendorAvatar: MockImages.avatar(4),
        isVendorVerified: false,
        price: 12500,
        compareAtPrice: 18000,
        previousPrice: 14000,
        priceDropPercent: 11,
        category: 'Fashion',
        condition: 'New',
        rating: 4.5,
        reviewCount: 203,
        stockQuantity: 0,
        isAvailable: false,
        isInCart: false,
        shippingAvailable: true,
        shippingCost: 500,
        addedAt: now.subtract(const Duration(days: 14)),
        lastPriceCheckAt: now,
      ),
      WishlistItemEntity(
        id: 'wish_005',
        listingId: 'listing_013',
        listingName: 'AirPods Pro 2nd Gen',
        listingImages: MockImages.productImages(130),
        listingSlug: 'listing_013',
        vendorId: 'vendor_002',
        vendorName: 'Karim Merabet',
        vendorStoreName: 'Oran Fashion Hub',
        vendorAvatar: MockImages.avatar(4),
        isVendorVerified: false,
        price: 32000,
        compareAtPrice: 38000,
        previousPrice: 32000,
        priceDropPercent: null,
        category: 'Electronics',
        condition: 'New',
        rating: 4.8,
        reviewCount: 201,
        stockQuantity: 8,
        isAvailable: true,
        isInCart: false,
        shippingAvailable: true,
        shippingCost: 0,
        addedAt: now.subtract(const Duration(days: 5)),
        lastPriceCheckAt: now,
      ),
    ]);
  }

  @override
  Future<List<WishlistItemEntity>> getWishlist(String consumerId) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _ensureMockSeed();
      return _items.map(_withComputedDrop).toList();
    }
    final _ = _dio;
    throw UnimplementedError();
  }

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String consumerId,
    required String listingId,
  }) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _ensureMockSeed();
      final existing = _items.indexWhere((e) => e.listingId == listingId);
      if (existing >= 0) {
        return _withComputedDrop(_items[existing]);
      }
      final id = 'wish_${DateTime.now().microsecondsSinceEpoch}';
      final e = buildFromListingId(listingId, wishId: id);
      _items.add(e);
      return _withComputedDrop(e);
    }
    throw UnimplementedError();
  }

  @override
  Future<void> removeFromWishlist({
    required String consumerId,
    required String listingId,
  }) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _items.removeWhere((e) => e.listingId == listingId);
      return;
    }
    throw UnimplementedError();
  }

  @override
  Future<void> clearWishlist(String consumerId) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _items.clear();
      return;
    }
    throw UnimplementedError();
  }

  @override
  WishlistItemEntity entityFromCartItem(CartItemEntity item) {
    final now = DateTime.now();
    final prev = item.price;
    return WishlistItemEntity(
      id: 'wish_${now.microsecondsSinceEpoch}',
      listingId: item.listingId,
      listingName: item.listingName,
      listingImages: item.listingImage.isNotEmpty
          ? [item.listingImage]
          : MockImages.productImages(20),
      listingSlug: item.listingSlug,
      vendorId: item.vendorId,
      vendorName: item.vendorName,
      vendorStoreName: item.vendorStoreName,
      vendorAvatar: item.vendorAvatar,
      isVendorVerified: item.vendorVerified,
      price: item.price,
      compareAtPrice: item.compareAtPrice,
      previousPrice: prev,
      priceDropPercent: null,
      category: item.category,
      condition: item.condition,
      rating: item.vendorRating,
      reviewCount: 0,
      stockQuantity: item.maxQuantity,
      isAvailable: item.isAvailable,
      isInCart: false,
      shippingAvailable: item.shippingAvailable,
      shippingCost: item.shippingCost,
      addedAt: now,
      lastPriceCheckAt: now,
    );
  }

  @override
  Future<WishlistItemEntity> upsertItem(WishlistItemEntity item) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _ensureMockSeed();
      final idx = _items.indexWhere((e) => e.listingId == item.listingId);
      if (idx >= 0) {
        _items[idx] = item;
      } else {
        _items.add(item);
      }
      return _withComputedDrop(
        _items.firstWhere((e) => e.listingId == item.listingId),
      );
    }
    throw UnimplementedError();
  }

  @override
  WishlistItemEntity buildFromListingId(String listingId, {String? wishId}) {
    final m = mockListingModels.firstWhere((e) => e.id == listingId);
    final vid = _vendorIdForListing(listingId);
    final vd = _vendorDisplay(vid);
    final compare = mockCompareAtByListingId[listingId];
    final shipOk = true;
    final shipCost = m.price >= 20000 ? 0.0 : 500.0;
    final now = DateTime.now();
    final id = wishId ?? 'wish_${now.microsecondsSinceEpoch}';
    final stock = listingId == 'listing_003' ? 0 : 10;
    final available = stock > 0;
    return WishlistItemEntity(
      id: id,
      listingId: m.id,
      listingName: m.title,
      listingImages:
          m.imageUrls.isNotEmpty ? m.imageUrls : MockImages.productImages(20),
      listingSlug: m.id,
      vendorId: vid,
      vendorName: vd.$1,
      vendorStoreName: vd.$2,
      vendorAvatar: vd.$3,
      isVendorVerified: vd.$4,
      price: m.price,
      compareAtPrice: compare,
      previousPrice: m.price,
      priceDropPercent: null,
      category: m.categoryLabel,
      condition: m.conditionLabel,
      rating: 4.7,
      reviewCount: m.inquiryCount,
      stockQuantity: stock,
      isAvailable: available,
      isInCart: false,
      shippingAvailable: shipOk,
      shippingCost: shipCost,
      addedAt: now,
      lastPriceCheckAt: now,
    );
  }
}
