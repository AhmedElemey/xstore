import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_endpoints.dart';
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

  Future<WishlistItemEntity> buildFromListingId(String listingId, {String? wishId});

  Future<WishlistItemEntity> upsertItem(WishlistItemEntity item);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl(this._dio);

  final Dio _dio;
  static const _wishlistPath = '/wishlist';

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
    try {
      final response = await _dio.get<List<dynamic>>('$_wishlistPath/$consumerId');
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => _fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch wishlist');
    }
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
      final e = await buildFromListingId(listingId, wishId: id);
      _items.add(e);
      return _withComputedDrop(e);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_wishlistPath/$consumerId/items',
        data: {'listingId': listingId},
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty wishlist response');
      return _fromMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to add wishlist item');
    }
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
    try {
      await _dio.delete<void>('$_wishlistPath/$consumerId/items/$listingId');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to remove wishlist item');
    }
  }

  @override
  Future<void> clearWishlist(String consumerId) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _items.clear();
      return;
    }
    try {
      await _dio.delete<void>('$_wishlistPath/$consumerId');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to clear wishlist');
    }
  }

  @override
  WishlistItemEntity entityFromCartItem(CartItemEntity item) {
    final now = DateTime.now();
    final prev = item.price;
    return WishlistItemEntity(
      id: 'wish_${now.microsecondsSinceEpoch}',
      listingId: item.listingId,
      listingName: item.listingName,
      listingImages: item.listingImage.isNotEmpty ? [item.listingImage] : const [],
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
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_wishlistPath/items/${item.listingId}',
        data: _toMap(item),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty wishlist response');
      return _fromMap(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to save wishlist item');
    }
  }

  @override
  Future<WishlistItemEntity> buildFromListingId(String listingId, {String? wishId}) async {
    if (MockConfig.useMock) {
      return _buildFromListingIdMock(listingId, wishId: wishId);
    }
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiEndpoints.listingDetail(listingId));
      final raw = response.data;
      if (raw == null) throw const ServerException('Empty listing response');
      return _fromListingPayload(raw, wishId: wishId);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load listing');
    }
  }

  WishlistItemEntity _buildFromListingIdMock(String listingId, {String? wishId}) {
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

  Map<String, dynamic> _listingPayloadRoot(Map<String, dynamic> json) {
    final nested = json['listing'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  WishlistItemEntity _fromListingPayload(Map<String, dynamic> json, {String? wishId}) {
    final root = _listingPayloadRoot(json);
    final listingId = (root['id'] ?? '').toString();
    final now = DateTime.now();
    final id = wishId ?? 'wish_${now.microsecondsSinceEpoch}';

    final sellerRaw = root['seller'] ?? root['vendor'] ?? json['seller'];
    final seller =
        sellerRaw is Map ? Map<String, dynamic>.from(sellerRaw) : <String, dynamic>{};

    final vid = (root['vendorId'] ?? root['sellerId'] ?? seller['id'] ?? '')
        .toString();
    final vendorName =
        (seller['name'] ?? seller['displayName'] ?? '').toString();
    final store =
        (seller['storeName'] ?? seller['businessName'] ?? vendorName).toString();
    final avatar = (seller['avatarUrl'] ?? seller['avatar'] ?? '').toString();

    final imgs = root['imageUrls'];
    final listingImages = imgs is List && imgs.isNotEmpty
        ? imgs.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : [
            if ((root['imageUrl'] ?? '').toString().isNotEmpty)
              root['imageUrl'].toString(),
          ];

    final price = _num(root['price']);
    final compareRaw = root['compareAtPrice'] ?? root['compare_at_price'];
    final compare = compareRaw == null ? null : _num(compareRaw);

    final catRaw = root['categoryLabel'] ?? root['category'];
    final category = catRaw is String
        ? catRaw
        : catRaw is Map && catRaw['name'] is String
            ? catRaw['name'] as String
            : catRaw?.toString() ?? '';

    final condRaw = root['conditionLabel'] ?? root['condition'];
    final condition =
        condRaw is String ? condRaw : condRaw?.toString() ?? '';

    final rating = _num(root['rating'] ?? root['averageRating']);

    final reviewCountRaw = root['reviewCount'];
    final reviewsList = root['reviews'];
    final reviewCount = reviewCountRaw is num
        ? reviewCountRaw.toInt()
        : int.tryParse(reviewCountRaw?.toString() ?? '') ??
            (reviewsList is List ? reviewsList.length : 0);

    final stockRaw = root['stockQuantity'] ?? root['stock'] ?? root['quantity'];
    final stock =
        stockRaw is num ? stockRaw.toInt() : int.tryParse(stockRaw?.toString() ?? '') ?? 1;

    final shipAvail =
        json['shippingAvailable'] != false && root['shippingAvailable'] != false;
    final shippingCost = shipAvail ? (price >= 20000 ? 0.0 : 500.0) : 0.0;

    return WishlistItemEntity(
      id: id,
      listingId: listingId,
      listingName: (root['title'] ?? root['name'] ?? '').toString(),
      listingImages: listingImages,
      listingSlug: (root['slug'] ?? listingId).toString(),
      vendorId: vid.isEmpty ? 'vendor_unknown' : vid,
      vendorName: vendorName.isEmpty ? '—' : vendorName,
      vendorStoreName: store.isEmpty ? vendorName : store,
      vendorAvatar: avatar,
      isVendorVerified:
          seller['verified'] == true || seller['isVerified'] == true,
      price: price,
      compareAtPrice: compare,
      previousPrice: price,
      priceDropPercent: null,
      category: category,
      condition: condition,
      rating: rating == 0 ? 4.7 : rating,
      reviewCount: reviewCount,
      stockQuantity: stock,
      isAvailable: root['isAvailable'] != false,
      isInCart: false,
      shippingAvailable: shipAvail,
      shippingCost: shippingCost,
      addedAt: now,
      lastPriceCheckAt: now,
    );
  }

  WishlistItemEntity _fromMap(Map<String, dynamic> json) {
    final images = (json['listingImages'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    return WishlistItemEntity(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listingId'] ?? '').toString(),
      listingName: (json['listingName'] ?? '').toString(),
      listingImages: images,
      listingSlug: (json['listingSlug'] ?? '').toString(),
      vendorId: (json['vendorId'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? '').toString(),
      vendorStoreName: (json['vendorStoreName'] ?? '').toString(),
      vendorAvatar: (json['vendorAvatar'] ?? '').toString(),
      isVendorVerified: json['isVendorVerified'] != false,
      price: _num(json['price']),
      compareAtPrice:
          json['compareAtPrice'] == null ? null : _num(json['compareAtPrice']),
      previousPrice:
          json['previousPrice'] == null ? null : _num(json['previousPrice']),
      priceDropPercent: (json['priceDropPercent'] as num?)?.toInt(),
      category: (json['category'] ?? '').toString(),
      condition: (json['condition'] ?? '').toString(),
      rating: _num(json['rating']),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 1,
      isAvailable: json['isAvailable'] != false,
      isInCart: json['isInCart'] == true,
      shippingAvailable: json['shippingAvailable'] != false,
      shippingCost: _num(json['shippingCost']),
      addedAt:
          DateTime.tryParse((json['addedAt'] ?? '').toString()) ?? DateTime.now(),
      lastPriceCheckAt:
          DateTime.tryParse((json['lastPriceCheckAt'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(WishlistItemEntity item) => {
        'id': item.id,
        'listingId': item.listingId,
        'listingName': item.listingName,
        'listingImages': item.listingImages,
        'listingSlug': item.listingSlug,
        'vendorId': item.vendorId,
        'vendorName': item.vendorName,
        'vendorStoreName': item.vendorStoreName,
        'vendorAvatar': item.vendorAvatar,
        'isVendorVerified': item.isVendorVerified,
        'price': item.price,
        'compareAtPrice': item.compareAtPrice,
        'previousPrice': item.previousPrice,
        'priceDropPercent': item.priceDropPercent,
        'category': item.category,
        'condition': item.condition,
        'rating': item.rating,
        'reviewCount': item.reviewCount,
        'stockQuantity': item.stockQuantity,
        'isAvailable': item.isAvailable,
        'isInCart': item.isInCart,
        'shippingAvailable': item.shippingAvailable,
        'shippingCost': item.shippingCost,
        'addedAt': item.addedAt.toIso8601String(),
        'lastPriceCheckAt': item.lastPriceCheckAt.toIso8601String(),
      };

  double _num(Object? value) => (value as num?)?.toDouble() ?? 0;
}
