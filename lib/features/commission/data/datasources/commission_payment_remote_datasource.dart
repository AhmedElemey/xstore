import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/commission_payment_method.dart';

/// CONFIRMED (backend Postman collection v10; background in
/// docs_business/backend/11_COMMISSION_PAYMENT_REQUESTS_HANDOFF.md):
///
///   POST /api/vendor/commission-payments   (multipart/form-data)
///     method       InstaPay | VodafoneCash | OrangeCash | EtisalatCash
///     amountEgp    decimal > 0
///     receipt      file
///   → 201 { id, status: "Pending", ... }
///
/// The pay-to accounts are not fetched here: they are per-method General
/// Settings keys (`instapay_handle`, `vodafone_cash_handle`,
/// `orange_cash_handle`, `etisalat_cash_handle`) cached at startup, see
/// `commissionPayToAccountsProvider`.
class CommissionPaymentRemoteDataSource {
  CommissionPaymentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> submitPayment({
    required CommissionPaymentMethod method,
    required double amountEgp,
    required String receiptImagePath,
  }) async {
    if (MockConfig.useMock) return MockConfig.simulate(null);
    // The picked file lives in image_picker's cache, which the OS can
    // evict; fail with a clear error instead of a raw FileSystemException.
    if (!File(receiptImagePath).existsSync()) {
      throw const AppException('Receipt image is no longer available.');
    }
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.vendorCommissionPayments,
        data: FormData.fromMap({
          'method': method.wireName,
          'amountEgp': amountEgp.toStringAsFixed(2),
          'receipt': await MultipartFile.fromFile(
            receiptImagePath,
            filename: receiptImagePath.split('/').last,
          ),
        }),
        options: ApiAuthHeaders.authenticated(),
      );
      // A 2xx `{isSuccess: false}` envelope is still a failure.
      final failure = envelopeFailure(response.data);
      if (failure != null) throw failure;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
