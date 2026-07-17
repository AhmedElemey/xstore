import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';
import '../../domain/courier_order_flow.dart';
import '../../domain/entities/courier_cash_wallet.dart';

part 'courier_cash_wallet_provider.g.dart';

/// Cash-in-hand ceiling (EGP) before a courier must deposit collected COD
/// with xStore. Owner-configurable; no backend config endpoint exists yet,
/// so this constant is the single source of truth until one does (same
/// placeholder pattern as the commission thresholds).
const double kCourierCashHandoverThresholdEgp = 5000.0;

/// No backend "cash in hand" aggregate endpoint exists yet — this pages
/// through the courier's orders and sums client-side, mirroring
/// `vendorCommissionWalletProvider`.
const int _walletOrderScanPageSize = 200;

/// Safety cap so a pathological backend response can't loop forever.
const int _walletOrderScanMaxPages = 10;

@riverpod
Future<CourierCashWallet> courierCashWallet(CourierCashWalletRef ref) async {
  const empty = CourierCashWallet(
    cashInHandEgp: 0,
    handoverThresholdEgp: kCourierCashHandoverThresholdEgp,
  );

  final user = ref.watch(authProvider).valueOrNull;
  if (user == null || user.role != UserRole.courier) {
    return empty;
  }

  final useCase = ref.watch(getCourierOrdersUseCaseProvider);

  // Page through ALL orders — a single page would silently understate a
  // money figure (see review lesson on paginated financial aggregates).
  // Fail-open on a page failure: keep whatever was summed so far.
  final delivered = <OrderEntity>[];
  for (var page = 1; page <= _walletOrderScanMaxPages; page++) {
    final result = await useCase(
      courierId: user.id,
      page: page,
      pageSize: _walletOrderScanPageSize,
    );
    final orders = result.fold<List<OrderEntity>?>((_) => null, (o) => o);
    if (orders == null) break;

    delivered.addAll(orders.where(holdsCollectedCash));

    if (orders.length < _walletOrderScanPageSize) break;
  }

  delivered.sort(
    (a, b) => (b.deliveredAt ?? b.updatedAt).compareTo(
      a.deliveredAt ?? a.updatedAt,
    ),
  );

  return CourierCashWallet(
    cashInHandEgp: delivered.fold<double>(
      0,
      (sum, o) => sum + codAmountToCollect(o),
    ),
    handoverThresholdEgp: kCourierCashHandoverThresholdEgp,
    deliveredCodOrders: delivered,
  );
}
