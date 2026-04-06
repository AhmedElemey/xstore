import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CouponInputRow extends ConsumerWidget {
  const CouponInputRow({super.key});

  static String _detail(String code) {
    switch (code.toUpperCase()) {
      case 'SAVE10':
        return AppStrings.couponDetailSave10;
      case 'FREE500':
        return AppStrings.couponDetailFree500;
      case 'WELCOME':
        return AppStrings.couponDetailWelcome;
      default:
        return AppStrings.couponDetailSave10;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final hasCoupon = cart.coupon != null;
    final loading = cart.isCouponLoading;

    String? errText;
    if (cart.couponErrorKey == 'minOrder') {
      errText = AppStrings.cartCouponMinOrder;
    } else if (cart.couponErrorKey == 'invalid') {
      errText = AppStrings.cartCouponInvalid;
    }

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      elevation: 1,
      shadowColor: context.textPrimary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.cartPromoHeading,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (hasCoupon) ...[
              Text(
                cart.coupon!.code,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.cartCouponApplied(
                        cart.coupon!.code,
                        _detail(cart.coupon!.code),
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => notifier.removeCoupon(),
                    child: Text(
                      AppStrings.cartCouponRemove,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              _CouponEntry(
                loading: loading,
                errorText: errText,
                onChanged: notifier.setCouponInput,
                onApply: notifier.applyCoupon,
              ),
          ],
        ),
      ),
    );
  }
}

class _CouponEntry extends StatefulWidget {
  const _CouponEntry({
    required this.loading,
    required this.errorText,
    required this.onChanged,
    required this.onApply,
  });

  final bool loading;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onApply;

  @override
  State<_CouponEntry> createState() => _CouponEntryState();
}

class _CouponEntryState extends State<_CouponEntry> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = _ctrl.text.trim();
    final canApply = trimmed.isNotEmpty && !widget.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: AppStrings.cartCouponHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  errorText: widget.errorText,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: AppSpacing.x3l + AppSpacing.sm,
              child: FilledButton(
                onPressed: !canApply
                    ? null
                    : () async {
                        widget.onChanged(_ctrl.text);
                        await widget.onApply();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: canApply
                      ? AppColors.primary
                      : context.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                ),
                child: widget.loading
                    ? const SizedBox(
                        width: AppSpacing.lg,
                        height: AppSpacing.lg,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(AppStrings.cartApply),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
