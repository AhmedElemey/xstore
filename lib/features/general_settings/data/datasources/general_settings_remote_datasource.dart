import 'dart:math';

import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_general_settings.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/app_settings.dart';

/// CONFIRMED live: `GET /api/general-settings?page=1&pageSize=20` (public)
/// -> a bare `[{id, key, value, dataType, ...}]` (since 2026-10-20). The
/// earlier paged `{items, totalCount, page, pageSize, totalPages}` shape is
/// still accepted.
class GeneralSettingsRemoteDataSource {
  GeneralSettingsRemoteDataSource(this._dio);

  final Dio _dio;

  static const pageSize = 20;

  /// Upper bound on pages (20 x 20 = 400 keys) so a bad `totalPages` can't
  /// trigger hundreds of sequential requests.
  static const maxPages = 20;

  /// Fetches every page and merges them, so no key silently goes missing.
  /// A non-empty `items` of which no row parses is malformed (throws); an
  /// empty `items` is a legitimate empty set. [cancelToken] aborts the
  /// in-flight request (timeout / superseded fetch).
  Future<AppSettings> fetchAll({CancelToken? cancelToken}) async {
    if (MockConfig.useMock) return mockAppSettings;
    try {
      final items = <dynamic>[];
      var page = 1;
      var totalPages = 1;
      do {
        final response = await _dio.get<dynamic>(
          ApiEndpoints.generalSettings,
          queryParameters: {'page': page, 'pageSize': pageSize},
          options: ApiAuthHeaders.standalone(),
          cancelToken: cancelToken,
        );
        final body = response.data;
        // Live since 2026-10-20: a bare list of every row, no paging.
        if (body is List) {
          items.addAll(body);
          break;
        }
        if (body is! Map || body['items'] is! List) {
          throw const FormatException('Unexpected general settings body');
        }
        items.addAll(body['items'] as List);
        totalPages = min((body['totalPages'] as num?)?.toInt() ?? 1, maxPages);
        page++;
      } while (page <= totalPages);
      final settings = AppSettings.fromItems(items);
      if (items.isNotEmpty && settings.isEmpty) {
        throw const FormatException('No valid general settings rows');
      }
      return settings;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
