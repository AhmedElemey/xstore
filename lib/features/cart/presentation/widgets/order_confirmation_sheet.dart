import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';

Future<void> showOrderConfirmationSheet(
  BuildContext context, {
  required String orderId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (ctx) => OrderConfirmationBody(orderId: orderId),
  );
}

class OrderConfirmationBody extends StatefulWidget {
  const OrderConfirmationBody({super.key, required this.orderId});

  final String orderId;

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

  @override
  Widget build(BuildContext context) {
    final success = AppColors.success;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: OrbitBackground(
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.4),
                        colors: [
                          Color.lerp(success, AppColors.white, 0.85)!,
                          success,
                          Color.lerp(success, AppColors.black, 0.45)!,
                        ],
                        stops: const [0, 0.4, 1],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: success.withValues(alpha: 0.5),
                          blurRadius: 70,
                        ),
                      ],
                    ),
                    child: const SizedBox.square(
                      dimension: 110,
                      child: Icon(
                        LucideIcons.check,
                        size: 48,
                        color: AppColors.darkBackground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.surfaceColor.withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border(top: BorderSide(color: context.borderColor)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  AppSpacing.md,
                  22,
                  AppSpacing.x2l + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.textSecondary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const SizedBox(width: 44, height: 5),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.orderPlacedTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 24,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.l10n.orderTrackCta,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.glassColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md + 2,
                        ),
                        child: Text(
                          context.l10n.orderPlacedNumber(widget.orderId),
                          textAlign: TextAlign.center,
                          style: AppTypography.mono.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2l),
                    XstoreButton(
                      label: context.l10n.orderTrackCta,
                      onPressed: () {
                        _t?.cancel();
                        Navigator.of(context).pop();
                        context.go(AppRoutes.orderPath(widget.orderId));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () {
                        _t?.cancel();
                        Navigator.of(context).pop();
                        context.go(AppRoutes.home);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textPrimary,
                        side: BorderSide(color: context.borderColor),
                        shape: const StadiumBorder(),
                        minimumSize: const Size.fromHeight(52),
                        textStyle: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(context.l10n.orderContinueShopping),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
