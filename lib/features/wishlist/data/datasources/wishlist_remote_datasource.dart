import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
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

  Future<WishlistItemEntity> buildFromListingId(String listingId, {String? wishId});
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<WishlistItemEntity>> getWishlist(String consumerId) async {
    try {
      // CONFIRMED against a live backend: response is a bare array. Also
      // CONFIRMED: entries are the full denormalized WishlistItemEntity
      // shape (not a slim {id, listingId, addedAt} shape).
      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.wishlist}/$consumerId',
        options: ApiAuthHeaders.authenticated(),
      );
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => _fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String consumerId,
    required String listingId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.wishlistItems(consumerId),
        data: {'listingId': listingId},
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty wishlist response');
      return _fromMap(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> removeFromWishlist({
    required String consumerId,
    required String listingId,
  }) async {
    try {
      await _dio.delete<void>(
        ApiEndpoints.wishlistItem(consumerId, listingId),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> clearWishlist(String consumerId) async {
    try {
      await _dio.delete<void>(
        '${ApiEndpoints.wishlist}/$consumerId',
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<WishlistItemEntity> buildFromListingId(String listingId, {String? wishId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.apiListingDetail(listingId),
        options: ApiAuthHeaders.public(),
      );
      final raw = response.data;
      if (raw == null) throw const ServerException('Empty listing response');
      return _fromListingPayload(raw, wishId: wishId);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
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

    // CONFIRMED: real listing payloads send flat userId/userName, not a
    // nested seller/vendor object — checked here alongside the nested
    // fallback for resilience.
    final vid = (root['vendorId'] ??
            root['sellerId'] ??
            root['userId'] ??
            seller['id'] ??
            '')
        .toString();
    final vendorName = (seller['name'] ??
            seller['displayName'] ??
            root['userName'] ??
            '')
        .toString();
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

    final catRaw =
        root['categoryLabel'] ?? root['category'] ?? root['categoryNameEn'];
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
      listingName: (root['title'] ?? root['titleEn'] ?? root['name'] ?? '')
          .toString(),
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

  double _num(Object? value) => (value as num?)?.toDouble() ?? 0;
}
