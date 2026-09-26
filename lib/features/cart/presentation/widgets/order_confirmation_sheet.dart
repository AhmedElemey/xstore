import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/space_background.dart';
import '../../../../shared/widgets/xstore_button.dart';

Future<void> showOrderConfirmationSheet(
  BuildContext context, {
  required String orderId,
  double? cashDue,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (ctx) => OrderConfirmationBody(orderId: orderId, cashDue: cashDue),
  );
}

class OrderConfirmationBody extends StatefulWidget {
  const OrderConfirmationBody({super.key, required this.orderId, this.cashDue});

  final String orderId;

  /// Cash to hand the courier; null hides the line.
  final double? cashDue;

  @override
  State<OrderConfirmationBody> createState() => _OrderConfirmationBodyState();
}

class _OrderConfirmationBodyState extends State<OrderConfirmationBody> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _leave(String location) {
    _t?.cancel();
    Navigator.of(context).pop();
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final cashDue = widget.cashDue;
    // Orbit "order placed": a green success planet in the sky, then a panel
    // with the order number, the cash to have ready and the two exits.
    return SizedBox(
      height: h,
      child: SpaceBackground(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, s, child) =>
                      Transform.scale(scale: s, child: child),
                  child: const _SuccessOrb(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.x2l,
                AppSpacing.lg,
                AppSpacing.x2l,
                AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: context.borderColor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.orderPlacedTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.orderPlacedBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    radius: 20,
                    child: Text(
                      context.l10n.orderPlacedNumber(widget.orderId),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (cashDue != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md + 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.cashColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: context.cashColor.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payments_outlined, color: context.cashColor),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              context.l10n.homeLiveOrderCashReady(
                                context.formatCurrency(cashDue),
                              ),
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  XstoreButton(
                    label: context.l10n.orderTrackCta,
                    onPressed: () =>
                        _leave(AppRoutes.orderPath(widget.orderId)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => _leave(AppRoutes.home),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(context.l10n.orderContinueShopping),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessOrb extends StatelessWidget {
  const _SuccessOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.nova.withValues(alpha: 0.25),
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.35),
              ),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [Color(0xFFF2FFFA), AppColors.successLight, Color(0xFF1B8A6E)],
                stops: [0, 0.4, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.successLight.withValues(alpha: 0.55),
                  blurRadius: 60,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 52,
              color: Color(0xFF04160F),
            ),
          ),
        ],
      ),
    );
  }
}
