import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_auth_headers.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_error_mapper.dart';

class AppSettingsRemoteDataSource {
  AppSettingsRemoteDataSource(this._dio);

  final Dio _dio;

  /// `GET /api/app-settings` — anonymous, so it works before login. Accepts
  /// the Result envelope (`{isSuccess, data: {...}}`) or a bare map.
  Future<Map<String, Object?>> fetchAll() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.appSettings,
        options: ApiAuthHeaders.public(),
      );
      final body = response.data;
      final data = body is Map && body.containsKey('data')
          ? body['data']
          : body;
      if (data is! Map) {
        throw const ServerException('Unexpected app-settings response');
      }
      return Map<String, Object?>.from(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
