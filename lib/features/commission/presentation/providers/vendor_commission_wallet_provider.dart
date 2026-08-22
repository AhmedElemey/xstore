import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/vendor_commission_wallet.dart';
import 'commission_config_provider.dart';

part 'vendor_commission_wallet_provider.g.dart';

@riverpod
Future<VendorCommissionWallet> vendorCommissionWallet(
  VendorCommissionWalletRef ref,
) async {
  const empty = VendorCommissionWallet(
    exceedsWarnThreshold: false,
    exceedsPauseThreshold: false,
    warnThresholdEgp: kCommissionWarnThresholdEgp,
    pauseThresholdEgp: kCommissionPauseThresholdEgp,
  );

  final user = ref.watch(authProvider).valueOrNull;
  if (user == null || user.role != UserRole.vendor) {
    return empty;
  }

  final snapshot = await ref.watch(vendorCommissionSnapshotProvider.future);
  if (snapshot == null) return empty;

  return VendorCommissionWallet(
    exceedsWarnThreshold: snapshot.exceedsWarnThreshold,
    exceedsPauseThreshold: snapshot.exceedsPauseThreshold,
    warnThresholdEgp: snapshot.warnThresholdEgp ?? kCommissionWarnThresholdEgp,
    pauseThresholdEgp:
        snapshot.pauseThresholdEgp ?? kCommissionPauseThresholdEgp,
  );
}
