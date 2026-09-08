import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/pulsing_animation_builder.dart';

class OrderFilterTabs extends ConsumerWidget {
  const OrderFilterTabs({super.key, required this.isVendor});

  final bool isVendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      ordersNotifierProvider.select((s) => s.selectedFilter),
    );
    final counts = ref.watch(
      ordersNotifierProvider.select((s) {
        final map = <OrderStatus, int>{};
        for (final order in s.orders) {
          map.update(order.status, (value) => value + 1, ifAbsent: () => 1);
        }
        return (all: s.orders.length, byStatus: map);
      }),
    );
    final notifier = ref.read(ordersNotifierProvider.notifier);
    final filters = notifier.filtersForRole(isVendor);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _chip(
            context,
            label: context.l10n.ordersFilterAll,
            count: counts.all,
            selected: selected == null,
            onTap: () => notifier.applyFilter(null),
            showPulse: false,
          ),
          ...filters.map((f) {
            final pendingPulse =
                isVendor &&
                f == OrderStatus.pending &&
                (counts.byStatus[f] ?? 0) > 0;
            return Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: _chip(
                context,
                label: _filterTitle(context, f),
                count: counts.byStatus[f] ?? 0,
                selected: selected == f,
                onTap: () => notifier.applyFilter(f),
                showPulse: pendingPulse,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _filterTitle(BuildContext context, OrderStatus f) => switch (f) {
    OrderStatus.pending => context.l10n.ordersFilterPending,
    OrderStatus.confirmed => context.l10n.ordersFilterConfirmed,
    OrderStatus.processing => context.l10n.ordersFilterProcessing,
    OrderStatus.shipped => context.l10n.ordersFilterShipped,
    OrderStatus.delivered => context.l10n.ordersFilterDelivered,
    OrderStatus.cancelled => context.l10n.ordersFilterCancelled,
  };

  Widget _chip(
    BuildContext context, {
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
    required bool showPulse,
  }) {
    final child = Material(
      color: selected ? AppColors.primary : context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.x4l),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.x4l),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: RowTight(
            showPulse: showPulse,
            child: Text(
              '$label ($count)',
              style: AppTypography.labelLarge.copyWith(
                color: selected ? AppColors.white : context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
    if (showPulse) {
      return _Pulse(child: child);
    }
    return child;
  }
}

class RowTight extends StatelessWidget {
  const RowTight({super.key, required this.child, required this.showPulse});

  final Widget child;
  final bool showPulse;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPulse) ...[
          const _PulsingDot(),
          const SizedBox(width: AppSpacing.sm),
        ],
        child,
      ],
    );
  }
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PulsingAnimationBuilder(
      duration: const Duration(milliseconds: 1200),
      builder: (context, animation, child) => Transform.scale(
        scale: 1 + 0.02 * math.sin(animation.value * math.pi),
        child: child,
      ),
      child: child,
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot();

  @override
  Widget build(BuildContext context) {
    return PulsingAnimationBuilder(
      duration: const Duration(milliseconds: 900),
      builder: (context, animation, child) => FadeTransition(
        opacity: Tween(begin: 0.45, end: 1.0).animate(animation),
        child: child,
      ),
      child: Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
