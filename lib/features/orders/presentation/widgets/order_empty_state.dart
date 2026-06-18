import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.filterActive = false,
  });

  final String title;
  final String subtitle;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  LucideIcons.shoppingBag,
                  size: AppSpacing.x4l + AppSpacing.lg,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                Positioned(
                  right: AppSpacing.md,
                  top: AppSpacing.sm,
                  child: Icon(
                    LucideIcons.helpCircle,
                    size: AppSpacing.x2l,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!filterActive) ...[
              const SizedBox(height: AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.ordersBrowseProducts,
                onPressed: () => context.go(AppRoutes.explore),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
