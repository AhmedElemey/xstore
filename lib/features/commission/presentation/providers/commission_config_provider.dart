import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';

part 'commission_config_provider.g.dart';

/// Flat platform fee (EGP per order). Product rule: always 2 EGP — not a
/// percentage of price, and not [OrderStatsEntity.commissionValueOnOrder]
/// (that field is 0 when unset, so `??` cannot treat it as "use the
/// fallback").
const double kStarterCommissionFeeEgp = 2.0;

/// Fallback weekly vendor owed-balance thresholds (EGP) used while
/// [vendorCommissionSnapshot] is loading or has no values.
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

/// Flat 2 EGP regardless of [categoryId]. The family argument is kept so
/// existing call sites compile; the fee is not per-category.
@riverpod
double commissionFeeEgpForCategory(
  CommissionFeeEgpForCategoryRef ref,
  int? categoryId,
) {
  return kStarterCommissionFeeEgp;
}
