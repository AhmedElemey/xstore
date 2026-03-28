import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';

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
    final h = MediaQuery.sizeOf(context).height;
    return Container(
      height: h,
      color: AppColors.cardBg,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.x2l + MediaQuery.paddingOf(context).top,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, s, child) =>
                Transform.scale(scale: s, child: child),
            child: Icon(
              Icons.celebration_rounded,
              size: AppSpacing.x4l * 2,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.orderPlacedTitle,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.orderPlacedNumber(widget.orderId),
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.orderPlacedSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                _t?.cancel();
                Navigator.of(context).pop();
                context.go(AppRoutes.orderPath(widget.orderId));
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
              ),
              child: Text(AppStrings.orderTrackCta),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _t?.cancel();
                Navigator.of(context).pop();
                context.go(AppRoutes.home);
              },
              child: Text(AppStrings.orderContinueShopping),
            ),
          ),
        ],
      ),
    );
  }
}
