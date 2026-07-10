import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
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

  @override
  Future<ProductDetailEntity> fetchProductDetail(String listingId) async {
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
    try {
      await _dio.delete<void>(
        ApiEndpoints.apiListingReview(listingId, reviewId),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
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
    final loc = (json['locationLine'] ??
            json['location'] ??
            _locationFromParts(json))
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
      stockQuantity: stock?.toInt() ?? 99,
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
    final city = json['city']?.toString() ?? '';
    final wilaya = json['wilaya']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';
    final parts = [city, wilaya, country].where((e) => e.isNotEmpty).join(', ');
    return parts.isEmpty ? '' : '📍 $parts';
  }

  ProductSellerEntity? _parseFlatSeller(Map<String, dynamic> json) {
    final userId = json['userId'];
    if (userId == null) return null;
    return ProductSellerEntity(
      id: userId.toString(),
      name: (json['userName'] ?? '').toString(),
      avatarUrl: (json['userAvatar'] ?? '').toString(),
      rating: _num(json['rating']),
      salesCount: 0,
      verified: false,
    );
  }

  ProductSellerEntity? _parseSeller(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    return ProductSellerEntity(
      id: (m['id'] ?? m['vendorId'] ?? '').toString(),
      name: (m['name'] ?? m['displayName'] ?? '').toString(),
      avatarUrl: (m['avatarUrl'] ?? m['avatar'] ?? '').toString(),
      rating: _num(m['rating'] ?? m['averageRating']),
      salesCount:
          _int(m['salesCount'] ?? m['totalSales'] ?? m['sales'], fallback: 230),
      verified: m['verified'] == true || m['isVerified'] == true,
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
      stockQuantity: _int(m['stockQuantity'] ?? m['stock'], fallback: 99),
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

  double _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  int _int(Object? v, {required int fallback}) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }
}
