import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_reference_data.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/catalog_category_model.dart';

abstract interface class CatalogCategoryRemoteDataSource {
  Future<List<CatalogCategoryModel>> getCategories();
}

class CatalogCategoryRemoteDataSourceImpl
    implements CatalogCategoryRemoteDataSource {
  CatalogCategoryRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CatalogCategoryModel>> getCategories() async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(
        List<CatalogCategoryModel>.from(MockReferenceData.catalogCategories),
      );
    }
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.catalogCategories,
        options: ApiAuthHeaders.public(),
      );
      // CONFIRMED live: usually a bare list. Also accept the app-wide
      // `{items|data}` envelope so a wrapper change doesn't empty the picker.
      // Each top-level row embeds subcategories in `children`. Skip a bad
      // row instead of failing the whole catalog.
      final parsed = <CatalogCategoryModel>[];
      for (final row in _unwrap(response.data)) {
        try {
          final model = CatalogCategoryModel.fromJson(row);
          if (model.id != 0) parsed.add(model);
        } catch (_) {}
      }
      return parsed;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  List<Map<String, dynamic>> _unwrap(dynamic data) {
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return const [];
      try {
        return _unwrap(jsonDecode(trimmed));
      } catch (_) {
        return const [];
      }
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['data'] ?? data['results'];
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
