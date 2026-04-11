import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({
    super.key,
    this.filterEmptyTitle,
    this.onShowAll,
  });

  /// When non-null, list is empty due to filters; [onShowAll] resets filters.
  final String? filterEmptyTitle;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    final filtered = filterEmptyTitle != null;
    final titleText =
        filtered ? filterEmptyTitle! : context.l10n.wishlistEmptyTitle;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.x4l,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Icon(
                    LucideIcons.heart,
                    size: AppSpacing.x4l * 2 + AppSpacing.md,
                    color: context.textSecondary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),
                Text(
                  titleText,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                if (!filtered)
                  Text(
                    context.l10n.wishlistEmptySubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: AppSpacing.x2l),
                FilledButton(
                  onPressed: filtered
                      ? onShowAll
                      : () => context.go(AppRoutes.explore),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md,horizontal: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                  ),
                  child: Text(
                    filtered
                        ? context.l10n.wishlistShowAllItems
                        : context.l10n.discoverProducts,
                        style: TextStyle( color: AppColors.white,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
