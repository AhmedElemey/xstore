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

/// CONFIRMED route (Postman collection; live probe 2026-09-24 answers 401
/// unauthenticated, not 404, so it is deployed):
///
///   POST /api/reports/vendor
///   Body: {"vendorId": 1, "orderId": 1, "reason": "Fraud", "comment": "..."}
///
/// Ids go as JSON numbers, matching the collection and `POST /api/orders`'
/// `listingId`, rather than relying on the server's quoted-number leniency.
/// The collection only shows
/// "Fraud" (and "Harassment" on the sibling user report); the other reason
/// names are unconfirmed until an authenticated submit is probed.
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
          'vendorId': int.tryParse(vendorId) ?? vendorId,
          'orderId': int.tryParse(orderId) ?? orderId,
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
