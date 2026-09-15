import 'package:dio/dio.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/vendor_report_reason.dart';

abstract interface class VendorReportsRemoteDataSource {
  Future<void> submitReport({
    required String vendorId,
    required String orderId,
    required VendorReportReason reason,
    String? comment,
  });
}

/// PROPOSED, not yet built on the backend (as of 2026-09-15) — contract spec
/// for the backend team, mirroring how `ApiEndpoints.analyticsEvents` was
/// staged before that endpoint shipped:
///
///   POST /api/reports/vendor
///   Auth: same X-Auth-Token / Basic license headers as every other
///         authenticated write (attached centrally by dio_provider.dart's
///         request interceptor — no extra header needed here).
///   Body: {
///     "vendorId": (id of the reported vendor),
///     "orderId": (the order establishing the consumer-vendor relationship),
///     "reason": "Fraud" | "PoorProductQuality" | "ItemNotAsDescribed" |
///               "NoResponseFromSeller" | "Harassment" | "Other",
///     "comment": (free text, required by the client when reason is Other)
///   }
///   Response: 201 on success — response body shape not yet defined; this
///   client does not read anything back from it.
///
/// Until this route ships, a live submission fails (404) and the failure
/// is surfaced to the user via the standard `mapDioException` path — that
/// is expected, not a bug, until the backend implements the endpoint.
class VendorReportsRemoteDataSourceImpl implements VendorReportsRemoteDataSource {
  VendorReportsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> submitReport({
    required String vendorId,
    required String orderId,
    required VendorReportReason reason,
    String? comment,
  }) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      return;
    }
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.vendorReports,
        data: {
          'vendorId': vendorId,
          'orderId': orderId,
          'reason': reason.wireName,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
