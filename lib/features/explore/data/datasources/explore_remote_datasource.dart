import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/search_result_model.dart';

abstract interface class ExploreRemoteDataSource {
  Future<List<SearchResultModel>> searchListings(
    String query,
    int page, {
    double? minPrice,
    double? maxPrice,
    String? condition,
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
  }) async {
    try {
      // GET /api/listings supports keyword/categoryId/minPrice/maxPrice/
      // condition/sortBy/page/pageSize. minPrice/maxPrice/condition are
      // sent server-side; category (label-based multi-select), rating,
      // location and shipping filters stay client-side in
      // explore_provider.dart, and sortBy stays client-side because its
      // accepted tokens are unconfirmed.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListings,
        queryParameters: {
          if (query.trim().isNotEmpty) 'keyword': query.trim(),
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (condition != null && condition.isNotEmpty)
            'condition': condition,
          'page': page,
          'pageSize': pageSize,
        },
        options: ApiAuthHeaders.public(),
      );
      final maps = _unwrapObjectList(response.data);
      final models =
          maps.map(SearchResultModel.fromListingLike).toList(growable: false);

      /// If fewer than a full page arrives, callers treat it as last page via length.
      return models;
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
      final titles = _unwrapObjectList(response.data)
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
