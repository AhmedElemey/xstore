import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/json_list_unwrap.dart';
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
    String? wishlistItemId,
  });

  Future<void> clearWishlist(String consumerId);

  Future<WishlistItemEntity> buildFromListingId(
    String listingId, {
    String? wishId,
  });
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<WishlistItemEntity>> getWishlist(String consumerId) async {
    try {
      // Live GET uses the same `{isSuccess, data}` envelope as add/remove
      // errors. Older probes also returned a bare array — accept both.
      final response = await _dio.get<dynamic>(
        '${ApiEndpoints.wishlist}/$consumerId',
        options: ApiAuthHeaders.authenticated(),
      );
      return [for (final e in unwrapJsonObjectList(response.data)) _fromMap(e)];
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
      final listingKey = int.tryParse(listingId) ?? listingId;
      final response = await _dio.post<dynamic>(
        ApiEndpoints.wishlistItems(consumerId),
        data: {'listingId': listingKey},
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty wishlist response');
      return _itemFromAddResponse(data, listingId: listingId);
    } on DioException catch (e) {
      // Live unique-index 409 after a remove that did not actually delete
      // (wrong path id, or a soft-delete the unique still sees). The row
      // is already saved — return it so the heart stays on.
      if (e.response?.statusCode == 409) {
        return _existingWishlistItem(consumerId, listingId);
      }
      throw mapDioException(e);
    }
  }

  @override
  Future<void> removeFromWishlist({
    required String consumerId,
    required String listingId,
    String? wishlistItemId,
  }) async {
    final ids = <String>[];
    void addId(String? raw) {
      final id = raw?.trim() ?? '';
      if (id.isEmpty || id.startsWith('wish_') || ids.contains(id)) return;
      ids.add(id);
    }

    // Live DELETE `{id}` is the wishlist row in some builds and the
    // listing in others. Try both when they differ; 404 means "already
    // gone" and we continue.
    addId(wishlistItemId);
    addId(listingId);
    if (ids.isEmpty) return;
    var anyOk = false;
    Object? lastError;
    for (final id in ids) {
      try {
        await _dio.delete<void>(
          ApiEndpoints.wishlistItem(consumerId, id),
          options: ApiAuthHeaders.authenticated(),
        );
        anyOk = true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) continue;
        lastError = mapDioException(e);
      }
    }
    if (anyOk) return;
    if (lastError != null) throw lastError;
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
  Future<WishlistItemEntity> buildFromListingId(
    String listingId, {
    String? wishId,
  }) async {
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

  WishlistItemEntity _fromListingPayload(
    Map<String, dynamic> json, {
    String? wishId,
  }) {
    final root = _listingPayloadRoot(json);
    final listingId = (root['id'] ?? '').toString();
    final now = DateTime.now();
    final id = wishId ?? 'wish_${now.microsecondsSinceEpoch}';

    final sellerRaw = root['seller'] ?? root['vendor'] ?? json['seller'];
    final seller = sellerRaw is Map
        ? Map<String, dynamic>.from(sellerRaw)
        : <String, dynamic>{};

    // CONFIRMED: real listing payloads send flat userId/userName, not a
    // nested seller/vendor object — checked here alongside the nested
    // fallback for resilience.
    final vid =
        (root['vendorId'] ??
                root['sellerId'] ??
                root['userId'] ??
                seller['id'] ??
                '')
            .toString();
    final vendorName =
        (seller['name'] ?? seller['displayName'] ?? root['userName'] ?? '')
            .toString();
    final store = (seller['storeName'] ?? seller['businessName'] ?? vendorName)
        .toString();
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
    final condition = condRaw is String ? condRaw : condRaw?.toString() ?? '';

    final ratingRaw = root['rating'] ?? root['averageRating'];
    // Missing/zero rating means "no reviews yet" — never fabricate a score.
    final rating = ratingRaw == null ? null : _num(ratingRaw);

    final reviewCountRaw = root['reviewCount'];
    final reviewsList = root['reviews'];
    final reviewCount = reviewCountRaw is num
        ? reviewCountRaw.toInt()
        : int.tryParse(reviewCountRaw?.toString() ?? '') ??
              (reviewsList is List ? reviewsList.length : 0);

    final stockRaw = root['stockQuantity'] ?? root['stock'] ?? root['quantity'];
    final stock = stockRaw is num
        ? stockRaw.toInt()
        : int.tryParse(stockRaw?.toString() ?? '') ?? 1;

    final shipAvail =
        json['shippingAvailable'] != false &&
        root['shippingAvailable'] != false;
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
      rating: (rating != null && rating > 0) ? rating : null,
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

  Future<WishlistItemEntity> _existingWishlistItem(
    String consumerId,
    String listingId,
  ) async {
    try {
      final want = listingId.trim();
      for (final e in await getWishlist(consumerId)) {
        if (e.listingId == want || e.id == want) return e;
      }
    } catch (_) {}
    return buildFromListingId(listingId);
  }

  WishlistItemEntity _itemFromAddResponse(
    dynamic data, {
    required String listingId,
  }) {
    final item = _fromMap(_unwrapObject(data));
    if (item.listingId.isNotEmpty) return item;
    return item.copyWith(listingId: listingId);
  }

  Map<String, dynamic> _unwrapObject(dynamic data) {
    if (data is! Map) return const {};
    final m = Map<String, dynamic>.from(data);
    final nested = m['data'] ?? m['Data'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return m;
  }

  String _mapString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v =
          json[key] ??
          json[key.isEmpty
              ? key
              : '${key[0].toUpperCase()}${key.substring(1)}'];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  WishlistItemEntity _fromMap(Map<String, dynamic> json) {
    final nestedListing = json['listing'];
    final listing = nestedListing is Map
        ? Map<String, dynamic>.from(nestedListing)
        : const <String, dynamic>{};
    var listingId = _mapString(json, ['listingId']);
    if (listingId.isEmpty) {
      listingId = _mapString(listing, ['id', 'listingId']);
    }
    final imagesRaw =
        json['listingImages'] ??
        listing['imageUrls'] ??
        listing['images'] ??
        json['imageUrls'];
    final images = imagesRaw is List
        ? imagesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];
    var listingName = _mapString(json, ['listingName']);
    if (listingName.isEmpty) {
      listingName = _mapString(listing, ['title', 'titleEn', 'name']);
    }
    var listingSlug = _mapString(json, ['listingSlug']);
    if (listingSlug.isEmpty) {
      listingSlug = _mapString(listing, ['slug']);
    }
    var vendorId = _mapString(json, ['vendorId']);
    if (vendorId.isEmpty) {
      vendorId = _mapString(listing, ['vendorId', 'userId', 'sellerId']);
    }
    var vendorName = _mapString(json, ['vendorName']);
    if (vendorName.isEmpty) {
      vendorName = _mapString(listing, ['userName', 'vendorName']);
    }
    var vendorStoreName = _mapString(json, ['vendorStoreName']);
    if (vendorStoreName.isEmpty) {
      vendorStoreName = _mapString(listing, ['storeName', 'userName']);
    }
    var vendorAvatar = _mapString(json, ['vendorAvatar']);
    if (vendorAvatar.isEmpty) {
      vendorAvatar = _mapString(listing, ['userAvatar', 'vendorAvatar']);
    }
    var category = _mapString(json, ['category']);
    if (category.isEmpty) {
      category = _mapString(listing, [
        'category',
        'categoryLabel',
        'categoryNameEn',
      ]);
    }
    var condition = _mapString(json, ['condition']);
    if (condition.isEmpty) {
      condition = _mapString(listing, ['condition', 'conditionLabel']);
    }
    final ratingRaw =
        json['rating'] ?? listing['rating'] ?? listing['averageRating'];
    final rating = ratingRaw == null || _num(ratingRaw) <= 0
        ? null
        : _num(ratingRaw);
    return WishlistItemEntity(
      id: _mapString(json, ['id']),
      listingId: listingId,
      listingName: listingName,
      listingImages: images,
      listingSlug: listingSlug,
      vendorId: vendorId,
      vendorName: vendorName,
      vendorStoreName: vendorStoreName,
      vendorAvatar: vendorAvatar,
      isVendorVerified: json['isVendorVerified'] != false,
      price: _num(json['price'] ?? listing['price']),
      compareAtPrice:
          json['compareAtPrice'] == null && listing['compareAtPrice'] == null
          ? null
          : _num(json['compareAtPrice'] ?? listing['compareAtPrice']),
      previousPrice: json['previousPrice'] == null
          ? null
          : _num(json['previousPrice']),
      priceDropPercent: (json['priceDropPercent'] as num?)?.toInt(),
      category: category,
      condition: condition,
      rating: rating,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      stockQuantity:
          (json['stockQuantity'] as num?)?.toInt() ??
          (listing['stockQuantity'] as num?)?.toInt() ??
          1,
      isAvailable: json['isAvailable'] != false,
      isInCart: json['isInCart'] == true,
      shippingAvailable:
          json['shippingAvailable'] != false &&
          listing['shippingAvailable'] != false,
      shippingCost: _num(json['shippingCost']),
      addedAt:
          DateTime.tryParse((json['addedAt'] ?? '').toString()) ??
          DateTime.now(),
      lastPriceCheckAt:
          DateTime.tryParse((json['lastPriceCheckAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  double _num(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
