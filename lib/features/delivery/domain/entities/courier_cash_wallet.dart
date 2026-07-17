import '../../../orders/domain/entities/order_entity.dart';

/// Cash a platform courier is currently holding from COD collections,
/// owed to xStore until handed over. Mirrors the vendor commission wallet:
/// a one-directional owed-balance with an owner-configured threshold.
class CourierCashWallet {
  const CourierCashWallet({
    required this.cashInHandEgp,
    required this.handoverThresholdEgp,
    this.deliveredCodOrders = const [],
  });

  /// Sum of COD totals collected on delivered orders not yet handed over.
  final double cashInHandEgp;

  /// Above this, the courier must deposit cash before taking new COD orders.
  final double handoverThresholdEgp;

  /// The delivered COD orders backing [cashInHandEgp], newest first.
  final List<OrderEntity> deliveredCodOrders;

  bool get handoverDue => cashInHandEgp >= handoverThresholdEgp;
}
