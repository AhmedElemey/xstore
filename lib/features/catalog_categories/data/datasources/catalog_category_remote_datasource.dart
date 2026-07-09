import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_reference_data.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/catalog_category_model.dart';

abstract interface class CatalogCategoryRemoteDataSource {
  Future<List<CatalogCategoryModel>> getCategories();

  Future<CatalogCategoryModel> getCategoryById(int id);
}

class CatalogCategoryRemoteDataSourceImpl
    implements CatalogCategoryRemoteDataSource {
  CatalogCategoryRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CatalogCategoryModel>> getCategories() async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(MockReferenceData.catalogCategories);
    }
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.catalogCategories,
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      // ASSUMPTION: bare list response (no pagination envelope) per spec.
      final rawItems = data is List
          ? data
          : (data is Map ? data['items'] as List<dynamic>? : null) ?? [];
      return rawItems
          .map((e) => CatalogCategoryModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<CatalogCategoryModel> getCategoryById(int id) async {
    if (MockConfig.useMock) {
      final category = MockReferenceData.catalogCategories
          .where((c) => c.id == id)
          .firstOrNull;
      if (category == null) {
        throw const ServerException('Category not found');
      }
      return MockConfig.simulate(category);
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.catalogCategories}/$id',
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return CatalogCategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
