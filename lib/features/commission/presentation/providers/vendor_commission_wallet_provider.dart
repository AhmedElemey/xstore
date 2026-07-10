import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';
import '../../../orders/presentation/widgets/order_price_breakdown.dart';
import '../../domain/entities/commission_breakdown.dart';
import '../../domain/entities/commission_status.dart';
import '../../domain/entities/vendor_commission_wallet.dart';
import 'commission_config_provider.dart';

part 'vendor_commission_wallet_provider.g.dart';

/// Large enough to cover a vendor's full order history under mock data and
/// realistic early-launch volume. There's no backend "outstanding balance"
/// aggregate endpoint yet (see design memory) — this fetches everything and
/// sums client-side, same placeholder pattern as the commission rate.
const int _walletOrderScanPageSize = 200;

@riverpod
Future<VendorCommissionWallet> vendorCommissionWallet(
  VendorCommissionWalletRef ref,
) async {
  const empty = VendorCommissionWallet(
    outstandingEgp: 0,
    warnThresholdEgp: kCommissionWarnThresholdEgp,
    pauseThresholdEgp: kCommissionPauseThresholdEgp,
  );

  final user = ref.watch(authProvider).valueOrNull;
  if (user == null || user.role != UserRole.vendor) {
    return empty;
  }

  final useCase = ref.watch(getVendorOrdersUseCaseProvider);
  final rate = ref.watch(commissionRateForCategoryProvider(null));
  final result = await useCase(
    vendorId: user.id,
    page: 1,
    pageSize: _walletOrderScanPageSize,
  );

  return result.fold(
    // Fail-open: a network hiccup shouldn't block a vendor from listing.
    (_) => empty,
    (orders) {
      final outstanding = orders
          .where(
            (o) => commissionStatusForOrder(o.status) == CommissionStatus.due,
          )
          .fold<double>(
            0,
            (sum, o) =>
                sum +
                CommissionBreakdown.forPrice(o.total, ratePercent: rate)
                    .feeAmount,
          );
      return VendorCommissionWallet(
        outstandingEgp: outstanding,
        warnThresholdEgp: kCommissionWarnThresholdEgp,
        pauseThresholdEgp: kCommissionPauseThresholdEgp,
      );
    },
  );
}
