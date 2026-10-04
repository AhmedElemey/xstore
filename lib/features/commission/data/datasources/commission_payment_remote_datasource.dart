import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/commission_payment_method.dart';

/// General Settings key holding the pay-to accounts, e.g.
/// `{"InstaPay": "xstore@instapay", "VodafoneCash": "01000000000"}`.
const kCommissionPaymentAccountsSettingKey = 'commission_payment_accounts';

/// PROPOSED contract (not yet built) — full spec in
/// docs_business/backend/11_COMMISSION_PAYMENT_REQUESTS_HANDOFF.md:
///
///   POST /api/vendor/commission-payments   (multipart/form-data)
///     method       InstaPay | VodafoneCash | OrangeCash | EtisalatCash
///     amountEgp    decimal > 0
///     receiptImage file
///   → 201 { id, status: "Pending", ... }
///
/// Live: the pay-to accounts are a General Setting, read from
///
///   GET /api/general-settings?search=commission_payment_accounts
///   → { items: [{ key, value: "<JSON keyed by method wire name>", ... }] }
class CommissionPaymentRemoteDataSource {
  CommissionPaymentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<CommissionPaymentMethod, String>> getPayToAccounts() async {
    if (MockConfig.useMock) return MockConfig.simulate(const {});
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.generalSettings,
        queryParameters: {'search': kCommissionPaymentAccountsSettingKey},
      );
      return parsePayToAccounts(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

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
      await _dio.post<dynamic>(
        ApiEndpoints.vendorCommissionPayments,
        data: FormData.fromMap({
          'method': method.wireName,
          'amountEgp': amountEgp.toString(),
          'receiptImage': await MultipartFile.fromFile(
            receiptImagePath,
            filename: receiptImagePath.split('/').last,
          ),
        }),
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

/// Reads the `commission_payment_accounts` setting tolerantly: the body may
/// be the settings search page (`{items: [...]}` or a bare list, where only the
/// row with exactly this key counts — `search` also matches other keys), a
/// single `{key, value}` row, or the value itself, optionally inside the
/// `{data: ...}` Result envelope; the value may be a JSON string or an object.
/// Blank entries and unknown methods are dropped.
Map<CommissionPaymentMethod, String> parsePayToAccounts(dynamic body) {
  dynamic value = body;
  if (value is Map && value.containsKey('data')) value = value['data'];
  if (value is Map && value['items'] is List) value = value['items'];
  if (value is List) {
    value = value
        .whereType<Map>()
        .where((row) => row['key'] == kCommissionPaymentAccountsSettingKey)
        .firstOrNull;
  }
  if (value is Map && value.containsKey('value')) value = value['value'];
  if (value is String) {
    try {
      value = jsonDecode(value);
    } on FormatException {
      return const {};
    }
  }
  if (value is! Map) return const {};

  final accounts = <CommissionPaymentMethod, String>{};
  for (final entry in value.entries) {
    final method = CommissionPaymentMethod.fromWire(entry.key?.toString());
    final account = entry.value?.toString().trim() ?? '';
    if (method != null && account.isNotEmpty) accounts[method] = account;
  }
  return accounts;
}
