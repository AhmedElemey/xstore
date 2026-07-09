import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/search_result_model.dart';

abstract interface class ExploreRemoteDataSource {
  Future<List<SearchResultModel>> searchListings(
    String query,
    int page,
  );

  Future<List<String>> getSuggestions(String query);
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  ExploreRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Same value is used server-side (`pageSize` query param) and client-side (`hasMore` heuristics).
  static const int pageSize = 20;

  @override
  Future<List<SearchResultModel>> searchListings(String query, int page) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final base = query.isEmpty ? 'item' : query.toLowerCase();
      return List.generate(6, (i) {
        final idx = (page - 1) * 6 + i;
        return SearchResultModel(
          id: 'ex_$idx',
          name: '$base ${idx + 1}',
          price: 29.99 + idx * 3,
          compareAtPrice: idx.isEven ? 49.99 + idx : null,
          imageUrl: null,
          condition: idx.isEven ? 'New' : 'Like New',
          category: 'Electronics',
          rating: 4.2 + (idx % 3) * 0.2,
          reviewCount: 12 + idx,
          sellerName: 'Seller $idx',
          isSellerVerified: idx.isEven,
          location: 'Algiers',
          hasShipping: true,
        );
      });
    }
    try {
      // NOTE: category/price/condition/sort filters are applied
      // client-side in explore_provider.dart today, not sent to the
      // server — only keyword/page/pageSize are wired here for now.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.apiListings,
        queryParameters: {
          if (query.trim().isNotEmpty) 'keyword': query.trim(),
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
    try {
      // NOTE: no /api/... equivalent exists in the confirmed backend
      // contract for typeahead suggestions — stays on the legacy path.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.listingSearchSuggestions,
        queryParameters: {'q': query.trim()},
      );
      final data = response.data;
      final list = _unwrapStringList(data);
      if (list.isNotEmpty) return list.take(12).toList();

      /// Allow `{ "items": ["a","b"] }` style payloads.
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        final nested = _unwrapStringList(m['items']);
        return nested.take(12).toList();
      }
      return [];
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

  List<String> _unwrapStringList(dynamic data) {
    if (data is! List) return const [];
    return data.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
  }
}
