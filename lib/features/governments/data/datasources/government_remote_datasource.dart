import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/government_model.dart';

abstract interface class GovernmentRemoteDataSource {
  Future<({List<GovernmentModel> items, int totalCount})> getGovernments({
    required int page,
    required int pageSize,
  });

  Future<GovernmentModel> getGovernmentById(int id);
}

class GovernmentRemoteDataSourceImpl implements GovernmentRemoteDataSource {
  GovernmentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({List<GovernmentModel> items, int totalCount})> getGovernments({
    required int page,
    required int pageSize,
  }) async {
    try {
      // CONFIRMED against a live backend: pagination envelope is
      // {"items": [...], "totalCount": N, "page", "pageSize", "totalPages"}.
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.governments,
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems
          .map((e) =>
              GovernmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return (
        items: items,
        totalCount: data['totalCount'] as int? ?? items.length,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<GovernmentModel> getGovernmentById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.governments}/$id',
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return GovernmentModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
