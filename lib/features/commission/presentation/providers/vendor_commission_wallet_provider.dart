import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';
import '../../domain/entities/commission_breakdown.dart';
import '../../domain/entities/commission_status.dart';
import '../../domain/entities/vendor_commission_wallet.dart';
import 'commission_config_provider.dart';

part 'vendor_commission_wallet_provider.g.dart';

/// There's no backend "outstanding balance" aggregate endpoint yet (see
/// design memory) — this pages through the vendor's orders and sums
/// client-side, same placeholder pattern as the commission rate.
const int _walletOrderScanPageSize = 200;

/// Safety cap so a pathological backend response can't loop forever.
/// 10 × 200 = 2000 orders — far beyond early-launch volume; if a vendor
/// legitimately exceeds this, the backend aggregate endpoint is overdue.
const int _walletOrderScanMaxPages = 10;

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

  // Page through ALL orders — a single page would silently understate the
  // balance for high-volume vendors, and this figure gates publishing.
  // Fail-open on any page failure: a network hiccup shouldn't block a
  // vendor from listing, so we keep whatever was summed so far.
  var outstanding = 0.0;
  for (var page = 1; page <= _walletOrderScanMaxPages; page++) {
    final result = await useCase(
      vendorId: user.id,
      page: page,
      pageSize: _walletOrderScanPageSize,
    );
    final orders = result.fold<List<OrderEntity>?>((_) => null, (o) => o);
    if (orders == null) break;

    outstanding += orders
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

    if (orders.length < _walletOrderScanPageSize) break;
  }

  return VendorCommissionWallet(
    outstandingEgp: outstanding,
    warnThresholdEgp: kCommissionWarnThresholdEgp,
    pauseThresholdEgp: kCommissionPauseThresholdEgp,
  );
}
