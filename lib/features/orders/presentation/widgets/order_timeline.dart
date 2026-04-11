import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class OrderTimeline extends StatefulWidget {
  const OrderTimeline({
    super.key,
    required this.order,
    this.showTitle = true,
  });

  final OrderEntity order;
  final bool showTitle;

  @override
  State<OrderTimeline> createState() => _OrderTimelineState();
}

class _OrderTimelineState extends State<OrderTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final steps = _Step.values;
    final cancelled = o.status == OrderStatus.cancelled;
    final timeFmt = DateFormat('MMM d, yyyy · HH:mm');
    final activeIdx = cancelled ? _idxBeforeCancel(o) : _progressIndex(o);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
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
            pulse: _pulse,
            nodeFilled: isCancelNode ? true : filled,
            isCurrent: isCurrent,
            dashedBelow:
                !lineDone && !filled && !isCancelNode && i != activeIdx + 1,
            isCancelNode: isCancelNode,
            isLast: i == steps.length - 1,
            label: isCancelNode ? context.l10n.ordersFilterCancelled : s.label(context),
            subtitle: isCancelNode
                ? (o.cancelReason ?? context.l10n.statusSubtitleCancelled)
                : (date != null
                    ? timeFmt.format(date)
                    : context.l10n.ordersTimelinePending),
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
        OrderStatus.refunded => 4,
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
        return o.status == OrderStatus.processing ? o.updatedAt : null;
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
    required this.pulse,
    required this.nodeFilled,
    required this.isCurrent,
    required this.dashedBelow,
    required this.isCancelNode,
    required this.isLast,
    required this.label,
    required this.subtitle,
    this.cancelReason,
  });

  final AnimationController pulse;
  final bool nodeFilled;
  final bool isCurrent;
  final bool dashedBelow;
  final bool isCancelNode;
  final bool isLast;
  final String label;
  final String subtitle;
  final String? cancelReason;

  @override
  Widget build(BuildContext context) {
    final dotColor = isCancelNode
        ? AppColors.error
        : (nodeFilled ? AppColors.success : context.textDisabled);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: AppSpacing.x2l,
            child: Column(
              children: [
                if (isCurrent && !isCancelNode)
                  AnimatedBuilder(
                    animation: pulse,
                    builder: (context, child) {
                      final scale = 1 + 0.22 * math.sin(pulse.value * math.pi);
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: AppSpacing.md,
                      height: AppSpacing.md,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.45),
                            blurRadius: AppSpacing.sm,
                            spreadRadius: AppSpacing.xs,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: AppSpacing.md,
                    height: AppSpacing.md,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          nodeFilled || isCancelNode ? dotColor : AppColors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            nodeFilled || isCancelNode ? dotColor : context.textDisabled,
                        width: 2,
                      ),
                    ),
                    child: isCancelNode
                        ? const Icon(Icons.close, size: 10, color: AppColors.white)
                        : null,
                  ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _LinePainter(
                        dashed: !nodeFilled && !isCancelNode,
                        solid: nodeFilled || isCancelNode,
                        pendingColor: context.textDisabled,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall,
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
  _LinePainter({
    required this.dashed,
    required this.solid,
    required this.pendingColor,
  });

  final bool dashed;
  final bool solid;
  final Color pendingColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = solid ? AppColors.success : pendingColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final mid = size.width / 2;
    if (dashed) {
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
      oldDelegate.dashed != dashed || oldDelegate.solid != solid;
}
