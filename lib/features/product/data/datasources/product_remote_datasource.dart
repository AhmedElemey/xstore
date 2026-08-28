import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/mock/mock_listings.dart';
import '../../../../core/mock/mock_reviews.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../home/domain/entities/deal_entity.dart';
import '../../../listing/data/models/listing_model.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/entities/product_seller_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_write_params.dart';

abstract interface class ProductRemoteDataSource {
  Future<ProductDetailEntity> fetchProductDetail(String listingId);

  Future<List<ProductDetailEntity>> fetchSimilarProducts({
    required String productId,
    required String category,
  });

  Future<PaginatedResult<ReviewEntity>> fetchProductReviews({
    required String listingId,
    required int page,
    required int pageSize,
  });

  Future<ReviewEntity> createReview({
    required String listingId,
    required ReviewWriteParams params,
  });

  Future<ReviewEntity> updateReview({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  });

  Future<void> deleteReview({
    required String listingId,
    required String reviewId,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static final Map<String, List<ReviewEntity>> _mockReviewsByListingId = {};

  /// Drops mock reviews added/edited during this session so they don't
  /// survive into the next account on the same device (mock mode only).
  static void clearSessionCache() {
    _mockReviewsByListingId.clear();
  }

  @override
  Future<ProductDetailEntity> fetchProductDetail(String listingId) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_mockProductDetail(listingId));
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.apiListingDetail(listingId),
        options: ApiAuthHeaders.public(),
      );
      final raw = response.data;
      if (raw == null) {
        throw const ServerException('Empty product detail response');
      }
      return _parseProductDetail(raw, listingId);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<ProductDetailEntity>> fetchSimilarProducts({
    required String productId,
    required String category,
  }) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_mockSimilarProducts(productId, category));
    }
    try {
      // Spec's similar-listings endpoint is id-based (not category-based)
      // — `category` is kept in the signature for source compatibility but
      // no longer used to build the request.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListingSimilar(productId),
        options: ApiAuthHeaders.public(),
      );
      final list = _unwrapList(response.data);
      return list
          .map((e) => _similarProduct(Map<String, dynamic>.from(e)))
          .where((e) => e.listing.id != productId)
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<PaginatedResult<ReviewEntity>> fetchProductReviews({
    required String listingId,
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(
        _mockReviewsPage(listingId, page: page, pageSize: pageSize),
      );
    }
    try {
      // ASSUMPTION: envelope is {"items": [...], "totalCount": N} matching
      // cities/governments precedent. Falls back to a bare list with
      // items.length as totalCount if no envelope is present.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListingReviews(listingId),
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        final rawItems = m['items'] as List<dynamic>? ?? [];
        final items = rawItems
            .whereType<Map>()
            .map((e) => _parseReview(Map<String, dynamic>.from(e)))
            .toList();
        return PaginatedResult(
          items: items,
          page: page,
          pageSize: pageSize,
          totalCount: m['totalCount'] as int? ?? items.length,
        );
      }
      final list = _unwrapList(data).map(_parseReview).toList();
      return PaginatedResult(
        items: list,
        page: page,
        pageSize: pageSize,
        totalCount: list.length,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<ReviewEntity> createReview({
    required String listingId,
    required ReviewWriteParams params,
  }) async {
    if (MockConfig.useMock) {
      final review = ReviewEntity(
        id: 'review_${DateTime.now().microsecondsSinceEpoch}',
        userId: mockConsumerUser.id,
        userName: mockConsumerUser.name,
        userAvatar: MockImages.avatar(2),
        rating: params.rating,
        comment: params.comment,
        createdAt: DateTime.now(),
      );
      _mockReviewsForListing(listingId).insert(0, review);
      return MockConfig.simulate(review);
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.apiListingReviews(listingId),
        data: {'rating': params.rating, 'comment': params.comment},
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty review response');
      return _parseReview(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<ReviewEntity> updateReview({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  }) async {
    if (MockConfig.useMock) {
      final list = _mockReviewsForListing(listingId);
      final idx = list.indexWhere((e) => e.id == reviewId);
      final base = idx >= 0
          ? list[idx]
          : ReviewEntity(
              id: reviewId,
              userId: mockConsumerUser.id,
              userName: mockConsumerUser.name,
              userAvatar: MockImages.avatar(2),
              rating: params.rating,
              comment: params.comment,
              createdAt: DateTime.now(),
            );
      final updated = base.copyWith(rating: params.rating, comment: params.comment);
      if (idx >= 0) {
        list[idx] = updated;
      } else {
        list.insert(0, updated);
      }
      return MockConfig.simulate(updated);
    }
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.apiListingReview(listingId, reviewId),
        data: {'rating': params.rating, 'comment': params.comment},
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty review response');
      return _parseReview(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> deleteReview({
    required String listingId,
    required String reviewId,
  }) async {
    if (MockConfig.useMock) {
      _mockReviewsForListing(listingId).removeWhere((e) => e.id == reviewId);
      await MockConfig.simulate<void>(null);
      return;
    }
    try {
      await _dio.delete<void>(
        ApiEndpoints.apiListingReview(listingId, reviewId),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // CONFIRMED against the mock cart seed: listing_002/003/016 belong to
  // vendor_002 (Karim Hassan / Cairo Fashion Hub), everything else to
  // vendor_001 (mockVendorUser) — matches cart_remote_datasource.dart.
  String _mockVendorIdForListing(String listingId) {
    const v2 = {'listing_003', 'listing_016', 'listing_002'};
    return v2.contains(listingId) ? 'vendor_002' : 'vendor_001';
  }

  (String name, String store, String avatar, double rating, bool verified)
      _mockVendorDisplay(String vendorId) {
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

  List<ReviewEntity> _mockReviewsForListing(String listingId) {
    return _mockReviewsByListingId.putIfAbsent(listingId, () {
      final bundle = mockReviewsForListing(listingId);
      if (bundle == null) return <ReviewEntity>[];
      return bundle.reviews
          .map(
            (r) => ReviewEntity(
              id: r.id,
              userId: r.id,
              userName: r.userName,
              userAvatar: r.userAvatarUrl,
              rating: r.stars,
              comment: r.text,
              helpfulCount: r.helpfulCount,
              createdAt: r.date,
            ),
          )
          .toList();
    });
  }

  PaginatedResult<ReviewEntity> _mockReviewsPage(
    String listingId, {
    required int page,
    required int pageSize,
  }) {
    final all = _mockReviewsForListing(listingId);
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, all.length);
    final items = start >= all.length ? <ReviewEntity>[] : all.sublist(start, end);
    return PaginatedResult(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
    );
  }

  ProductDetailEntity _mockProductDetail(String listingId) {
    final m = mockListingModels.firstWhere((e) => e.id == listingId);
    final vid = _mockVendorIdForListing(listingId);
    final vd = _mockVendorDisplay(vid);
    final bundle = mockReviewsForListing(listingId);
    final similar = mockListingModels
        .where((e) => e.id != listingId && e.categoryLabel == m.categoryLabel)
        .take(6)
        .map(_mockDealFromListing)
        .toList();
    return ProductDetailEntity(
      listing: m.toEntity(),
      compareAtPrice: mockCompareAtByListingId[listingId],
      stockQuantity: m.stockQuantity,
      locationLine: vid == 'vendor_002' ? '📍 Giza, Egypt' : '📍 ${mockVendorUser.storeCity ?? 'Cairo'}, Egypt',
      seller: ProductSellerEntity(
        id: vid,
        name: vd.$1,
        avatarUrl: vd.$3,
        rating: vd.$4,
        salesCount: vid == 'vendor_002' ? 340 : mockVendorUser.totalSales,
        verified: vd.$5,
      ),
      specifications: const {},
      reviewSummary: bundle?.summary,
      reviews: bundle?.reviews ?? const [],
      similarProducts: similar,
    );
  }

  List<ProductDetailEntity> _mockSimilarProducts(String productId, String category) {
    final matches = mockListingModels
        .where((e) => e.id != productId && e.categoryLabel == category)
        .toList();
    final pool = matches.isNotEmpty
        ? matches
        : mockListingModels.where((e) => e.id != productId).toList();
    return pool.take(6).map(_mockSimilarProductDetail).toList();
  }

  ProductDetailEntity _mockSimilarProductDetail(ListingModel m) {
    return ProductDetailEntity(
      listing: m.toEntity(),
      compareAtPrice: mockCompareAtByListingId[m.id],
      stockQuantity: m.stockQuantity,
      locationLine: '',
      specifications: const {},
      similarProducts: const [],
      reviews: const [],
      reviewSummary: null,
      seller: null,
    );
  }

  DealEntity _mockDealFromListing(ListingModel m) {
    final compare = mockCompareAtByListingId[m.id];
    final discount =
        compare != null && compare > m.price ? ((compare - m.price) / compare) * 100 : 0.0;
    return DealEntity(
      id: m.id,
      title: m.title,
      price: m.price,
      imageUrl: m.imageUrls.isNotEmpty ? m.imageUrls.first : null,
      discountPercent: discount,
    );
  }

  ProductDetailEntity _parseProductDetail(
    Map<String, dynamic> json,
    String listingId,
  ) {
    final listingMap = _listingMap(json);
    final listing = ListingModel.fromJson(listingMap).toEntity();

    final compare = _num(json['compareAtPrice'] ?? json['compare_at_price']);
    final stock = (json['stockQuantity'] ?? json['stock'] ?? json['quantity'])
        as num?;
    final loc = (json['locationLine'] ?? json['location'] ?? _locationFromParts(json))
        .toString();

    // CONFIRMED against a live backend: listing detail sends flat
    // userId/userName/userAvatar fields, not a nested seller/vendor object.
    final seller = _parseSeller(json['seller'] ?? json['vendor']) ??
        _parseFlatSeller(json);

    final specs = _parseStringMap(json['specifications'] ?? json['specs']);

    final reviewSummary = _parseReviewSummary(
      json['reviewSummary'] ?? json['review_summary'],
    );

    final reviewsRaw = json['reviews'];
    final reviews = reviewsRaw is List
        ? reviewsRaw
            .whereType<Map>()
            .map((e) => _parseProductReview(Map<String, dynamic>.from(e)))
            .toList()
        : <ProductReviewEntity>[];

    final similarRaw = json['similar'];
    final similar = similarRaw is List
        ? similarRaw
            .whereType<Map>()
            .map((e) => _dealFromSimilarEntry(Map<String, dynamic>.from(e)))
            .where((d) => d.id != listingId)
            .toList()
        : <DealEntity>[];

    return ProductDetailEntity(
      listing: listing,
      compareAtPrice: compare,
      stockQuantity: stock?.toInt() ?? 0,
      locationLine: loc,
      seller: seller,
      specifications: specs,
      reviewSummary: reviewSummary,
      reviews: reviews,
      similarProducts: similar,
    );
  }

  Map<String, dynamic> _listingMap(Map<String, dynamic> json) {
    final nested = json['listing'];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    return json;
  }

  String _locationFromParts(Map<String, dynamic> json) {
    String t(dynamic value) => value?.toString().trim() ?? '';

    final userAddress = t(json['detailedAddressByUser']);
    if (userAddress.isNotEmpty) return userAddress;
    final googleAddress = t(json['detailedAddressByGoogleMaps']);
    if (googleAddress.isNotEmpty) return googleAddress;
    final gov = t(json['governorateNameEn']);
    if (gov.isNotEmpty) return gov;
    final govAr = t(json['governorateNameAr']);
    if (govAr.isNotEmpty) return govAr;
    final parts = [t(json['city']), t(json['wilaya']), t(json['country'])]
        .where((e) => e.isNotEmpty)
        .join(', ');
    return parts;
  }

  ProductSellerEntity? _parseFlatSeller(Map<String, dynamic> json) {
    final userId = json['userId'];
    if (userId == null) return null;
    return ProductSellerEntity(
      id: userId.toString(),
      name: (json['userName'] ?? '').toString(),
      avatarUrl: (json['userAvatar'] ?? '').toString(),
      rating: _numOrNull(json['rating']),
      salesCount: _intOrNull(json['salesCount'] ?? json['totalSales'] ?? json['sales']),
      verified: false,
      whatsappNumber: _optWhatsapp(json),
    );
  }

  ProductSellerEntity? _parseSeller(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    return ProductSellerEntity(
      id: (m['id'] ?? m['vendorId'] ?? '').toString(),
      name: (m['name'] ?? m['displayName'] ?? '').toString(),
      avatarUrl: (m['avatarUrl'] ?? m['avatar'] ?? '').toString(),
      rating: _numOrNull(m['rating'] ?? m['averageRating']),
      salesCount: _intOrNull(m['salesCount'] ?? m['totalSales'] ?? m['sales']),
      verified: m['verified'] == true || m['isVerified'] == true,
      whatsappNumber: _optWhatsapp(m),
    );
  }

  ReviewSummaryEntity? _parseReviewSummary(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final avg = _num(m['average'] ?? m['avg']);
    final total =
        (m['totalCount'] ?? m['count'] ?? m['total'] ?? 0) as num?;
    if (total == null || total.toInt() <= 0) {
      return null;
    }
    final starsRaw = m['starCounts'] ?? m['stars'] ?? m['distribution'];
    final starCounts = <int>[0, 0, 0, 0, 0];
    if (starsRaw is List && starsRaw.length >= 5) {
      for (var i = 0; i < 5; i++) {
        final v = starsRaw[i];
        if (v is num) starCounts[i] = v.toInt();
      }
    }
    return ReviewSummaryEntity(
      average: avg,
      totalCount: total.toInt(),
      starCounts: starCounts,
    );
  }

  ProductReviewEntity _parseProductReview(Map<String, dynamic> m) {
    return ProductReviewEntity(
      id: (m['id'] ?? '').toString(),
      userName: (m['userName'] ?? m['author'] ?? m['name'] ?? '').toString(),
      userAvatarUrl:
          (m['userAvatarUrl'] ?? m['avatarUrl'] ?? m['avatar'])?.toString(),
      date: DateTime.tryParse((m['date'] ?? m['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      stars: _num(m['stars'] ?? m['rating']),
      text: (m['text'] ?? m['comment'] ?? m['body'] ?? '').toString(),
      helpfulCount: _int(m['helpfulCount'] ?? m['helpful'], fallback: 0),
    );
  }

  ReviewEntity _parseReview(Map<String, dynamic> m) {
    return ReviewEntity(
      id: (m['id'] ?? '').toString(),
      userId: (m['userId'] ?? m['user_id'] ?? 'user').toString(),
      userName: (m['userName'] ?? m['author'] ?? '').toString(),
      userAvatar: (m['userAvatar'] ?? m['avatarUrl'] ?? m['avatar'])?.toString(),
      rating: _num(m['rating'] ?? m['stars']),
      comment: (m['comment'] ?? m['text'] ?? '').toString(),
      helpfulCount: _int(m['helpfulCount'] ?? m['helpful'], fallback: 0),
      createdAt:
          DateTime.tryParse((m['createdAt'] ?? m['date'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  ProductDetailEntity _similarProduct(Map<String, dynamic> m) {
    final listingJson = _listingMap(m);
    final listing = ListingModel.fromJson(listingJson).toEntity();
    final compare = _num(m['compareAtPrice'] ?? m['compare_at_price']);
    return ProductDetailEntity(
      listing: listing,
      compareAtPrice: compare == 0 ? null : compare,
      stockQuantity: _int(m['stockQuantity'] ?? m['stock'], fallback: 0),
      locationLine: '',
      specifications: const {},
      similarProducts: const [],
      reviews: const [],
      reviewSummary: null,
      seller: null,
    );
  }

  DealEntity _dealFromSimilarEntry(Map<String, dynamic> m) {
    final listingJson = _listingMap(m);
    final listing = ListingModel.fromJson(listingJson).toEntity();
    final compare = _num(m['compareAtPrice'] ?? m['compare_at_price']);
    final discountPct = compare > listing.price && compare > 0
        ? ((compare - listing.price) / compare) * 100
        : _num(m['discountPercent'] ?? m['discount']);
    return DealEntity(
      id: listing.id,
      title: listing.title,
      price: listing.price,
      imageUrl:
          listing.imageUrls.isNotEmpty ? listing.imageUrls.first : null,
      discountPercent: discountPct,
    );
  }

  Map<String, String> _parseStringMap(Object? raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
    );
  }

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final items = map['items'] ??
          map['data'] ??
          map['results'] ??
          map['listings'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  String? _optWhatsapp(Map<String, dynamic> m) {
    for (final key in ['whatsappNumber', 'whatsAppNumber', 'whatsapp']) {
      final v = m[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  double? _numOrNull(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  int? _intOrNull(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  double _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  int _int(Object? v, {required int fallback}) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }
}
