import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/pulsing_animation_builder.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order, this.showTitle = true});

  final OrderEntity order;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final steps = _Step.values;
    final cancelled = o.status == OrderStatus.cancelled;
    final activeIdx = cancelled ? _idxBeforeCancel(o) : _progressIndex(o);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            context.l10n.ordersTimelineHeading,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ...List.generate(steps.length, (i) {
          final s = steps[i];
          final isCancelNode =
              cancelled && i == activeIdx + 1 && i < steps.length;
          final lineDone = i < activeIdx;
          final filled = isCancelNode ? false : (i <= activeIdx);
          final isCurrent = !cancelled && i == activeIdx;
          final date = _dateForStep(o, s);

          return _TimelineRow(
            nodeFilled: isCancelNode ? true : filled,
            isCurrent: isCurrent,
            // Solid trail up to the current node, dashed beyond it. A
            // cancelled order's trail runs solid into the cancel node.
            solidBelow: lineDone || (cancelled && i == activeIdx),
            isCancelNode: isCancelNode,
            isLast: i == steps.length - 1,
            label: isCancelNode
                ? context.l10n.ordersFilterCancelled
                : s.label(context),
            // A reached step without a known time (older orders, or one
            // confirmed before this session) shows no subtitle, not "Pending".
            subtitle: isCancelNode
                ? (o.cancelReason ?? context.l10n.statusSubtitleCancelled)
                : date != null
                ? '${context.formatMediumDate(date)} · ${context.formatTime(date)}'
                : (filled ? null : context.l10n.ordersTimelinePending),
            cancelReason: isCancelNode ? o.cancelReason : null,
          );
        }),
      ],
    );
  }

  /// Last fully completed step index (0-based) for non-cancelled orders.
  int _progressIndex(OrderEntity o) => switch (o.status) {
    OrderStatus.pending => 0,
    OrderStatus.confirmed => 1,
    OrderStatus.processing => 2,
    OrderStatus.shipped => 3,
    OrderStatus.delivered => 4,
    OrderStatus.cancelled => 0,
  };

  int _idxBeforeCancel(OrderEntity o) {
    if (o.shippedAt != null) return 3;
    if (o.confirmedAt != null) return 1;
    return 0;
  }

  DateTime? _dateForStep(OrderEntity o, _Step s) {
    switch (s) {
      case _Step.placed:
        return o.createdAt;
      case _Step.confirmed:
        return o.confirmedAt;
      case _Step.processing:
        return o.processingAt ??
            (o.status == OrderStatus.processing ? o.updatedAt : null);
      case _Step.shipped:
        return o.shippedAt;
      case _Step.delivered:
        return o.deliveredAt;
    }
  }
}

enum _Step {
  placed,
  confirmed,
  processing,
  shipped,
  delivered;

  String label(BuildContext context) => switch (this) {
    _Step.placed => context.l10n.ordersTimelinePlaced,
    _Step.confirmed => context.l10n.ordersTimelineConfirmed,
    _Step.processing => context.l10n.ordersTimelineProcessing,
    _Step.shipped => context.l10n.ordersTimelineShipped,
    _Step.delivered => context.l10n.ordersTimelineDelivered,
  };
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.nodeFilled,
    required this.isCurrent,
    required this.solidBelow,
    required this.isCancelNode,
    required this.isLast,
    required this.label,
    this.subtitle,
    this.cancelReason,
  });

  final bool nodeFilled;
  final bool isCurrent;
  final bool solidBelow;
  final bool isCancelNode;
  final bool isLast;
  final String label;
  final String? subtitle;
  final String? cancelReason;

  @override
  Widget build(BuildContext context) {
    // Orbit node-and-trail: brand-filled nodes behind, a glowing light node
    // for the current step, hollow rings ahead.
    final brand = context.isDark ? AppColors.primaryLight : AppColors.primary;
    final faint = (context.isDark ? AppColors.darkTextLabel : AppColors.primary)
        .withValues(alpha: 0.45);
    final trail = isCancelNode ? AppColors.error : brand;
    final labelColor = isCancelNode
        ? AppColors.error
        : isCurrent
        ? context.linkColor
        : nodeFilled
        ? context.textPrimary
        : context.labelColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                if (isCurrent && !isCancelNode)
                  PulsingAnimationBuilder(
                    duration: const Duration(milliseconds: 1100),
                    builder: (context, animation, child) {
                      final scale =
                          1 + 0.12 * math.sin(animation.value * math.pi);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? context.textPrimary
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brand.withValues(alpha: 0.28),
                            spreadRadius: 5,
                          ),
                          BoxShadow(color: brand, blurRadius: 18),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: 14,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCancelNode
                          ? AppColors.error
                          : nodeFilled
                          ? brand
                          : AppColors.transparent,
                      shape: BoxShape.circle,
                      border: nodeFilled || isCancelNode
                          ? null
                          : Border.all(color: faint, width: 2),
                    ),
                    child: isCancelNode
                        ? const Icon(
                            Icons.close,
                            size: 10,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _LinePainter(
                        solid: solidBelow,
                        solidColor: trail,
                        dashColor: faint,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: labelColor,
                    ),
                  ),
                  if (subtitle case final subtitle?)
                    Text(
                      subtitle,
                      style: AppTypography.labelMedium.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                  if (isCancelNode && cancelReason != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${context.l10n.ordersCancelReasonSection}: $cancelReason',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({
    required this.solid,
    required this.solidColor,
    required this.dashColor,
  });

  final bool solid;
  final Color solidColor;
  final Color dashColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = solid ? solidColor : dashColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final mid = size.width / 2;
    if (!solid) {
      const dash = 4.0;
      double y = 0;
      while (y < size.height) {
        final end = (y + dash).clamp(0.0, size.height);
        canvas.drawLine(Offset(mid, y), Offset(mid, end.toDouble()), paint);
        y += dash + 4;
      }
    } else {
      canvas.drawLine(Offset(mid, 0), Offset(mid, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.solid != solid ||
      oldDelegate.solidColor != solidColor ||
      oldDelegate.dashColor != dashColor;
}
