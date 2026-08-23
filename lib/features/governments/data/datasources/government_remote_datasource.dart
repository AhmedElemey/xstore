import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/json_list_unwrap.dart';
import '../models/government_model.dart';

abstract interface class GovernmentRemoteDataSource {
  Future<({List<GovernmentModel> items, int totalCount})> getGovernments({
    required int page,
    required int pageSize,
  });
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
      // Live 2026-08-23: GET /api/governorates returns a bare JSON array.
      // Older hosts wrapped rows in {"items": [...], "totalCount": N, ...}.
      // Must GET as dynamic — typing the body as Map throws on a list and
      // surfaces as the generic sheet error.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.governments,
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      final items = unwrapJsonObjectList(data)
          .map(GovernmentModel.fromJson)
          .toList();
      final totalCount = data is Map
          ? data['totalCount'] as int? ?? items.length
          : items.length;
      return (items: items, totalCount: totalCount);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
