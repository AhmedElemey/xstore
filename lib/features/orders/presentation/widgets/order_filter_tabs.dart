import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';

class OrderFilterTabs extends ConsumerWidget {
  const OrderFilterTabs({
    super.key,
    required this.isVendor,
  });

  final bool isVendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersNotifierProvider);
    final notifier = ref.read(ordersNotifierProvider.notifier);
    final filters = notifier.filtersForRole(isVendor);
    final selected = state.selectedFilter;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _chip(
            context,
            label: AppStrings.ordersFilterAll,
            count: notifier.tabCount(null),
            selected: selected == null,
            onTap: () => notifier.applyFilter(null),
            showPulse: false,
          ),
          ...filters.map(
            (f) {
              final pendingPulse =
                  isVendor && f == OrderStatus.pending && notifier.tabCount(f) > 0;
              return Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: _chip(
                  context,
                  label: _filterTitle(f),
                  count: notifier.tabCount(f),
                  selected: selected == f,
                  onTap: () => notifier.applyFilter(f),
                  showPulse: pendingPulse,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _filterTitle(OrderStatus f) => switch (f) {
        OrderStatus.pending => AppStrings.ordersFilterPending,
        OrderStatus.confirmed => AppStrings.ordersFilterConfirmed,
        OrderStatus.processing => AppStrings.ordersFilterProcessing,
        OrderStatus.shipped => AppStrings.ordersFilterShipped,
        OrderStatus.delivered => AppStrings.ordersFilterDelivered,
        OrderStatus.cancelled => AppStrings.ordersFilterCancelled,
        OrderStatus.refunded => AppStrings.ordersFilterRefunded,
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
      color: selected ? AppColors.primary : AppColors.cardBg,
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
                color: selected ? AppColors.white : AppColors.textPrimary,
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
  const RowTight({
    super.key,
    required this.child,
    required this.showPulse,
  });

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

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.scale(
        scale: 1 + 0.02 * math.sin(_c.value * math.pi),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
