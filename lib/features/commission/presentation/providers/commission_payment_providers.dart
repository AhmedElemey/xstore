import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../general_settings/domain/entities/app_settings.dart';
import '../../../general_settings/presentation/providers/general_settings_provider.dart';
import '../../data/datasources/commission_payment_remote_datasource.dart';
import '../../data/repositories/commission_payment_repository_impl.dart';
import '../../domain/entities/commission_payment_method.dart';
import '../../domain/repositories/commission_payment_repository.dart';

part 'commission_payment_providers.g.dart';

@Riverpod(keepAlive: true)
CommissionPaymentRepository commissionPaymentRepository(
  CommissionPaymentRepositoryRef ref,
) {
  return CommissionPaymentRepositoryImpl(
    CommissionPaymentRemoteDataSource(ref.watch(dioProvider)),
  );
}

/// General Settings key holding each method's pay-to handle.
const _handleKeys = {
  CommissionPaymentMethod.instaPay: 'instapay_handle',
  CommissionPaymentMethod.vodafoneCash: 'vodafone_cash_handle',
  CommissionPaymentMethod.orangeCash: 'orange_cash_handle',
  CommissionPaymentMethod.etisalatCash: 'etisalat_cash_handle',
};

/// Pay-to accounts for the payment screens, derived from the cached General
/// Settings. Blank handles are left out ("not set up"). With a cache this is
/// always data; the error state is a failed first-launch fetch (Retry
/// re-runs [generalSettingsProvider]).
@riverpod
AsyncValue<Map<CommissionPaymentMethod, String>> commissionPayToAccounts(
  CommissionPayToAccountsRef ref,
) {
  return ref.watch(generalSettingsProvider).whenData(_payToAccounts);
}

Map<CommissionPaymentMethod, String> _payToAccounts(AppSettings settings) {
  final accounts = <CommissionPaymentMethod, String>{};
  for (final MapEntry(key: method, value: key) in _handleKeys.entries) {
    final handle = settings.raw(key)?.trim() ?? '';
    if (handle.isNotEmpty) accounts[method] = handle;
  }
  return accounts;
}
