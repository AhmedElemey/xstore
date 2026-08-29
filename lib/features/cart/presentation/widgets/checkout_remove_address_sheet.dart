import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

Future<void> showCheckoutRemoveAddressSheet(
  BuildContext context,
  WidgetRef ref,
  int index,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.lg),
      ),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.checkoutRemoveAddressTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.checkoutRemoveAddressBody,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(checkoutProvider.notifier).removeAddress(index);
                  },
                  child: Text(context.l10n.checkoutRemoveAddress),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.paddingOf(ctx).bottom + AppSpacing.sm),
        ],
      ),
    ),
  );
}
