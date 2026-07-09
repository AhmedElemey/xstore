import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_reference_data.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/city_model.dart';

abstract interface class CityRemoteDataSource {
  Future<({List<CityModel> items, int totalCount})> getCities({
    required int page,
    required int pageSize,
  });

  Future<CityModel> getCityById(int id);
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  CityRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({List<CityModel> items, int totalCount})> getCities({
    required int page,
    required int pageSize,
  }) async {
    if (MockConfig.useMock) {
      final all = MockReferenceData.cities;
      final start = page * pageSize;
      final slice =
          start >= all.length ? <CityModel>[] : all.skip(start).take(pageSize).toList();
      return MockConfig.simulate((items: slice, totalCount: all.length));
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.cities,
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      // ASSUMPTION: pagination envelope is {"items": [...], "totalCount": N}.
      // Not confirmed against a live response — verify once backend reachable.
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems
          .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e as Map)))
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
  Future<CityModel> getCityById(int id) async {
    if (MockConfig.useMock) {
      final city = MockReferenceData.cities.where((c) => c.id == id).firstOrNull;
      if (city == null) throw const ServerException('City not found');
      return MockConfig.simulate(city);
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.cities}/$id',
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return CityModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
