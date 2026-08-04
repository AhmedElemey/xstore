import 'package:dio/dio.dart';

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
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.catalogCategories,
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      // CONFIRMED against a live backend: bare list response (no pagination
      // envelope), but each top-level entry embeds its subcategories as a
      // nested `children` array (each child already carries the correct
      // `parentId` back to its parent), not a flat list. Flatten the tree
      // here so the rest of the app can keep using a flat parentId-filtered
      // list.
      final rawItems = data is List
          ? data
          : (data is Map ? data['items'] as List<dynamic>? : null) ?? [];
      return rawItems
          .expand(
            (e) => _flatten(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  List<CatalogCategoryModel> _flatten(Map<String, dynamic> json) {
    final model = CatalogCategoryModel.fromJson(json);
    final children = json['children'];
    if (children is! List || children.isEmpty) return [model];
    return [
      model,
      ...children.expand(
        (c) => _flatten(Map<String, dynamic>.from(c as Map)),
      ),
    ];
  }
}
