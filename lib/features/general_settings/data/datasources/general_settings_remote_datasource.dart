import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_general_settings.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/app_settings.dart';

/// CONFIRMED live: `GET /api/general-settings?page=1&pageSize=20` (public)
/// -> `{items: [{id, key, value, dataType, ...}], totalCount, page, pageSize,
/// totalPages}`.
class GeneralSettingsRemoteDataSource {
  GeneralSettingsRemoteDataSource(this._dio);

  final Dio _dio;

  static const pageSize = 20;

  /// Fetches every page and merges them, so no key silently goes missing.
  Future<AppSettings> fetchAll() async {
    if (MockConfig.useMock) return mockAppSettings;
    try {
      final items = <dynamic>[];
      var page = 1;
      var totalPages = 1;
      do {
        final response = await _dio.get<dynamic>(
          ApiEndpoints.generalSettings,
          queryParameters: {'page': page, 'pageSize': pageSize},
          options: ApiAuthHeaders.public(),
        );
        final body = response.data;
        if (body is! Map || body['items'] is! List) {
          throw const FormatException('Unexpected general settings body');
        }
        items.addAll(body['items'] as List);
        totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
        page++;
      } while (page <= totalPages);
      return AppSettings.fromItems(items);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
