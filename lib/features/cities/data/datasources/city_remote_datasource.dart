import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/json_list_unwrap.dart';
import '../models/city_model.dart';

abstract interface class CityRemoteDataSource {
  Future<({List<CityModel> items, int totalCount})> getCities({
    required int page,
    required int pageSize,
  });
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  CityRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({List<CityModel> items, int totalCount})> getCities({
    required int page,
    required int pageSize,
  }) async {
    try {
      // Live 2026-08-23: GET /api/cities returns a bare JSON array (all
      // rows; pageSize is ignored). Older hosts used the {items,totalCount}
      // envelope. GET as dynamic so a list body doesn't type-throw.
      final response = await _dio.get<dynamic>(
        ApiEndpoints.cities,
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      final items =
          unwrapJsonObjectList(data).map(CityModel.fromJson).toList();
      final totalCount = data is Map
          ? data['totalCount'] as int? ?? items.length
          : items.length;
      return (items: items, totalCount: totalCount);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
