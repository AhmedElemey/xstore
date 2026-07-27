import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/mock/mock_config.dart';
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

/// Mock-mode page size for the client-side scan (no mock wallet endpoint).
const int _walletOrderScanPageSize = 200;

/// Safety cap so a pathological mock response can't loop forever.
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

  final delivered = <OrderEntity>[];

  if (MockConfig.useMock) {
    // No mock wallet endpoint — page through ALL of the courier's orders and
    // filter client-side. Fail-open: keep whatever was summed so far.
    final useCase = ref.watch(getCourierOrdersUseCaseProvider);
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
  } else {
    // Live: the backend returns the courier's complete delivered-COD set (cash
    // still in hand) in one response, so summing it is authoritative — no
    // page-cap risk. Surface a fetch failure as an error state (a misleading
    // "0 EGP owed" is worse for a money figure than a retry prompt).
    final result =
        await ref.watch(ordersRepositoryProvider).getCourierCashInHandOrders();
    final orders = result.fold<List<OrderEntity>?>((_) => null, (o) => o);
    if (orders == null) {
      throw Exception(result.fold((f) => f.toString(), (_) => 'Unknown error'));
    }
    delivered.addAll(orders);
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
