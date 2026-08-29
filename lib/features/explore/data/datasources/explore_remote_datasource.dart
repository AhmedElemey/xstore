import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../listing/data/models/listing_model.dart'
    show isPublicLiveListingStatus;
import '../models/search_result_model.dart';

abstract interface class ExploreRemoteDataSource {
  Future<List<SearchResultModel>> searchListings(
    String query,
    int page, {
    double? minPrice,
    double? maxPrice,
    String? condition,
    int? categoryId,
  });

  Future<List<String>> getSuggestions(String query);
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  ExploreRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Same value is used server-side (`pageSize` query param) and client-side (`hasMore` heuristics).
  static const int pageSize = 20;

  @override
  Future<List<SearchResultModel>> searchListings(
    String query,
    int page, {
    double? minPrice,
    double? maxPrice,
    String? condition,
    int? categoryId,
  }) async {
    try {
      // GET /api/listings supports keyword/categoryId/minPrice/maxPrice/
      // condition/sortBy/page/pageSize. minPrice/maxPrice/condition/
      // categoryId are sent server-side (categoryId only when exactly one
      // category is selected — the endpoint takes a single id, not a list;
      // explore_provider.dart resolves the id and keeps a client-side
      // narrowing pass for the multi-select case). Rating, location and
      // shipping filters stay client-side, and sortBy stays client-side
      // because its accepted tokens are unconfirmed.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListings,
        queryParameters: {
          if (query.trim().isNotEmpty) 'keyword': query.trim(),
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (condition != null && condition.isNotEmpty)
            'condition': condition,
          if (categoryId != null) 'categoryId': categoryId,
          'page': page,
          'pageSize': pageSize,
        },
        options: ApiAuthHeaders.public(),
      );
      var maps = _liveListingMaps(_unwrapObjectList(response.data));

      // GET /api/listings is geo-filtered to stores within 50 km of
      // X-Latitude/X-Longitude. Seeded/dummy vendors often have store
      // coords outside Egypt (or none), so a Cairo consumer gets an empty
      // page even though GET /api/home already returns Active listings.
      // Page 1 only: later pages stay empty rather than repeating home.
      if (maps.isEmpty && page == 1) {
        maps = await _liveListingsFromHome(
          query: query,
          minPrice: minPrice,
          maxPrice: maxPrice,
          condition: condition,
          categoryId: categoryId,
        );
      }

      /// If fewer than a full page arrives, callers treat it as last page via length.
      return maps
          .map(SearchResultModel.fromListingLike)
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (query.isEmpty) return [];
      return [
        '$query phone',
        '$query case',
        '$query charger',
      ];
    }
    final q = query.trim();
    if (q.isEmpty) return [];
    try {
      // The backend has no dedicated typeahead endpoint — derive
      // suggestions from listing titles matching the keyword.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListings,
        queryParameters: {'keyword': q, 'page': 1, 'pageSize': 12},
        options: ApiAuthHeaders.public(),
      );
      var maps = _liveListingMaps(_unwrapObjectList(response.data));
      if (maps.isEmpty) {
        maps = await _liveListingsFromHome(query: q);
      }
      final titles = maps
          .map(
            (e) => (e['title'] ?? e['titleEn'] ?? e['name'] ?? '')
                .toString()
                .trim(),
          )
          .where((t) => t.isNotEmpty)
          .toSet();
      return titles.take(12).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Active listings from GET /api/home when nearby search is empty.
  Future<List<Map<String, dynamic>>> _liveListingsFromHome({
    required String query,
    double? minPrice,
    double? maxPrice,
    String? condition,
    int? categoryId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.home,
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data is! Map) return const [];
      final map = Map<String, dynamic>.from(data);
      final seen = <String>{};
      final out = <Map<String, dynamic>>[];
      for (final key in ['newArrivals', 'recommendedForYou', 'hotDeals']) {
        for (final item in _liveListingMaps(_unwrapObjectList(map[key]))) {
          final id = (item['id'] ?? '').toString();
          if (id.isEmpty || !seen.add(id)) continue;
          out.add(item);
        }
      }
      return out.where((e) {
        if (!_matchesKeyword(e, query)) return false;
        if (minPrice != null && _num(e['price']) < minPrice) return false;
        if (maxPrice != null && _num(e['price']) > maxPrice) return false;
        if (condition != null &&
            condition.isNotEmpty &&
            (e['condition'] ?? '').toString() != condition) {
          return false;
        }
        if (categoryId != null &&
            (e['categoryId'] as num?)?.toInt() != categoryId) {
          return false;
        }
        return true;
      }).toList();
    } on DioException {
      return const [];
    }
  }

  List<Map<String, dynamic>> _liveListingMaps(List<Map<String, dynamic>> raw) {
    return [
      for (final item in raw)
        if (isPublicLiveListingStatus(item['status']) &&
            (item['id'] ?? '').toString().isNotEmpty)
          item,
    ];
  }

  bool _matchesKeyword(Map<String, dynamic> json, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final title = (json['title'] ?? json['titleEn'] ?? json['name'] ?? '')
        .toString()
        .toLowerCase();
    return title.contains(q);
  }

  double _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  List<Map<String, dynamic>> _unwrapObjectList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final items = m['items'] ?? m['data'] ?? m['results'] ?? m['listings'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }
}
