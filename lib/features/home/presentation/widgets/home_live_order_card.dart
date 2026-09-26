import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../orders/presentation/widgets/order_status_badge.dart';

/// The shopper's newest in-flight order (anything not delivered or
/// cancelled), or null.
OrderEntity? liveOrderOf(List<OrderEntity> orders) {
  OrderEntity? live;
  for (final order in orders) {
    if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      continue;
    }
    if (live == null || order.createdAt.isAfter(live.createdAt)) live = order;
  }
  return live;
}

/// Orbit "live order" card at the top of Home: status, a 5-stop progress
/// trail and the cash to have ready. Consumers only; hidden when nothing is
/// in flight.
///
/// Reads the existing [ordersNotifierProvider] (same `GET /orders/me` the
/// Orders tab uses). It fetches once when Home opens with no orders loaded,
/// and again after a sign-in, so the card doesn't depend on visiting Orders.
class HomeLiveOrderCard extends ConsumerStatefulWidget {
  const HomeLiveOrderCard({super.key});

  @override
  ConsumerState<HomeLiveOrderCard> createState() => _HomeLiveOrderCardState();
}

class _HomeLiveOrderCardState extends ConsumerState<HomeLiveOrderCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchIfEmpty();
    });
  }

  void _fetchIfEmpty() {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null || user.role != UserRole.consumer) return;
    final orders = ref.read(ordersNotifierProvider);
    if (orders.orders.isNotEmpty || orders.isLoading) return;
    ref.read(ordersNotifierProvider.notifier).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    // A sign-in while Home is open: OrdersNotifier clears itself in a
    // microtask on the user change, so queue the fetch behind that reset.
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (prev, next) {
      if (next.isLoading) return;
      if (prev?.valueOrNull?.id == next.valueOrNull?.id) return;
      Future.microtask(() {
        if (mounted) _fetchIfEmpty();
      });
    });

    final isConsumer = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role == UserRole.consumer),
    );
    final order = isConsumer
        ? ref.watch(ordersNotifierProvider.select((s) => liveOrderOf(s.orders)))
        : null;
    if (order == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: _LiveOrderCard(order: order),
    );
  }
}

class _LiveOrderCard extends StatelessWidget {
  const _LiveOrderCard({required this.order});

  final OrderEntity order;

  static int _step(OrderStatus status) => switch (status) {
        OrderStatus.pending => 0,
        OrderStatus.confirmed => 1,
        OrderStatus.processing => 2,
        OrderStatus.shipped => 3,
        OrderStatus.delivered || OrderStatus.cancelled => 4,
      };

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    final statusLabel = orderStatusLabel(context, order.status);
    final dueInCash =
        order.paymentMethod == PaymentMethod.cashOnDelivery && !order.isPaid;
    final cashColor = context.isDark ? AppColors.cash : AppColors.cashOnLight;
    final radius = BorderRadius.circular(24);

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () => context.push(AppRoutes.orderPath(order.id)),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.16),
                AppColors.nova.withValues(alpha: 0.16),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 30),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _GlowDot(color: accent, size: 8),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      statusLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Text(
                    '#${order.formattedOrderId}',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _OrbitTrail(step: _step(order.status), color: accent),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: dueInCash
                        ? _CashLine(
                            amount: context.formatCurrency(order.total),
                            color: cashColor,
                          )
                        : Text(
                            order.vendorStoreName.isNotEmpty
                                ? order.vendorStoreName
                                : order.vendorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    context.l10n.homeLiveOrderTrack,
                    style: AppTypography.labelLarge.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: accent,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashLine extends StatelessWidget {
  const _CashLine({required this.amount, required this.color});

  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = context.l10n.homeLiveOrderCashReady(amount);
    final at = text.indexOf(amount);
    final base = AppTypography.bodyMedium.copyWith(color: context.textPrimary);
    final money = base.copyWith(
      color: color,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Text.rich(
      at < 0
          ? TextSpan(text: text, style: base)
          : TextSpan(
              style: base,
              children: [
                TextSpan(text: text.substring(0, at)),
                TextSpan(text: amount, style: money),
                TextSpan(text: text.substring(at + amount.length)),
              ],
            ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Five stops (placed → delivered) joined by a trail; stops up to [step] are
/// lit, the current one glows, the leg after it is dashed.
class _OrbitTrail extends StatelessWidget {
  const _OrbitTrail({required this.step, required this.color});

  static const _stops = 5;

  final int step;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final idle = context.textSecondary.withValues(alpha: 0.5);
    final children = <Widget>[];
    for (var i = 0; i < _stops; i++) {
      if (i > 0) {
        children.add(
          Expanded(
            child: Container(
              height: 2,
              color: i <= step ? color : idle.withValues(alpha: 0.35),
            ),
          ),
        );
      }
      if (i == step) {
        children.add(_GlowDot(color: color, size: 16, ring: true));
      } else if (i < step) {
        children.add(_GlowDot(color: color, size: 10, glow: false));
      } else {
        children.add(
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: idle, width: 1.5),
            ),
          ),
        );
      }
    }
    return ExcludeSemantics(child: Row(children: children));
  }
}

class _GlowDot extends StatelessWidget {
  const _GlowDot({
    required this.color,
    required this.size,
    this.glow = true,
    this.ring = false,
  });

  final Color color;
  final double size;
  final bool glow;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ring ? context.textPrimary : color,
        boxShadow: [
          if (ring)
            BoxShadow(color: color.withValues(alpha: 0.35), spreadRadius: 4),
          if (glow)
            BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 10),
        ],
      ),
    );
  }
}
