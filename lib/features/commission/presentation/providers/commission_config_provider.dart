import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';

part 'commission_config_provider.g.dart';

/// Fallback flat commission fee (EGP per order), used while
/// [vendorCommissionSnapshot] is loading, failed, the session has no
/// vendor identity, or the backend echoes 0 (SystemSetting seed is 0
/// until an admin PUTs `/api/admin/system-settings`). Mock mode included
/// — mock has no real backend truth. A positive admin-configured value
/// from [vendorCommissionSnapshot] wins.
const double kStarterCommissionFeeEgp = 2.0;

/// Fallback weekly vendor owed-balance thresholds (EGP) — see
/// [kStarterCommissionFeeEgp] for when these apply instead of the real,
/// admin-configured values.
const double kCommissionWarnThresholdEgp = 100.0;
const double kCommissionPauseThresholdEgp = 200.0;

/// The vendor's commission fee + wallet-alert flags.
///
/// The admin-configured source of truth is `SystemSetting`
/// (`commissionValueOnOrder`/`warnThresholdEgp`/`pauseThresholdEgp`) and
/// the vendor's own `VendorCommissionWallet` row — but both are only
/// exposed through `PUT/GET /api/admin/system-settings` and
/// `PUT /api/users/{id}/commission/settle`, which are
/// `[Authorize(Roles = "ADMINISTRATOR, SUPERADMIN")]` (confirmed against
/// backend source 2026-08-15) — a vendor session cannot call either. The
/// only vendor-accessible echo of these values is the
/// `GET /api/vendor/orders` envelope (`OrderStatsEntity`), so this reuses
/// the existing vendor-order-stats fetch rather than adding a dead-on-arrival
/// call to the admin routes. Plain autoDispose (not cached) — the
/// exceeds-threshold flags can change mid-session (e.g. a new delivered
/// order pushes the vendor over the pause limit) and gate listing
/// publishing, so staleness here is a correctness risk, not just a UX one.
@riverpod
Future<OrderStatsEntity?> vendorCommissionSnapshot(
  VendorCommissionSnapshotRef ref,
) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null || user.role != UserRole.vendor) return null;

  final result = await ref.watch(getVendorOrderStatsUseCaseProvider)(user.id);
  return result.fold((_) => null, (stats) => stats);
}

@riverpod
double commissionFeeEgpForCategory(
  CommissionFeeEgpForCategoryRef ref,
  int? categoryId,
) {
  final snapshot = ref.watch(vendorCommissionSnapshotProvider).valueOrNull;
  final fee = snapshot?.commissionValueOnOrder;
  // `??` does not treat 0 as missing. Backend seed / unset SystemSetting
  // is 0, which would otherwise render as "EGP 0.00" (fee not calculated)
  // and skip accrual on the server until an admin sets a positive value.
  if (fee != null && fee > 0) return fee;
  return kStarterCommissionFeeEgp;
}
