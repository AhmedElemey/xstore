import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/category_queries.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class FeaturedCategoriesBanner extends StatelessWidget {
  const FeaturedCategoriesBanner({super.key});

  static double get _cardHeight => AppSpacing.x4l * 3 + AppSpacing.lg;

  static const _mensImage =
      'https://images.unsplash.com/photo-1617137968427-85924c1a0eee?w=600&q=80';
  static const _womensImage =
      'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600&q=80';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CategoryCard(
            title: context.l10n.mensFashion,
            imageUrl: _mensImage,
            height: _cardHeight,
            onTap: () => context.go(
              Uri(
                path: AppRoutes.explore,
                queryParameters: {
                  'category': kCategoryQueryMens,
                },
              ).toString(),
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        Expanded(
          child: _CategoryCard(
            title: context.l10n.womensFashion,
            imageUrl: _womensImage,
            height: _cardHeight,
            onTap: () => context.go(
              Uri(
                path: AppRoutes.explore,
                queryParameters: {
                  'category': kCategoryQueryWomens,
                },
              ).toString(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.imageUrl,
    required this.height,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: glassFill(context),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppCachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheHeight: (height * 3).round(),
                placeholder: (_, __) => ColoredBox(color: context.textDisabled),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: context.textDisabled,
                  child: Icon(LucideIcons.imageOff, color: context.textPrimary),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.space.withValues(alpha: 0),
                      AppColors.space.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.white),
                      ),
                      child: Text(context.l10n.shopNow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
