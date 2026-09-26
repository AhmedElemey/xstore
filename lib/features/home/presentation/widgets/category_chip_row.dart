import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../domain/entities/category_entity.dart';

/// Orbit category row: a glowing planet orb per category with its name
/// underneath. Uses the category icon when the API sends one.
class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    this.onSelected,
  });

  final List<CategoryEntity> categories;
  final void Function(CategoryEntity category)? onSelected;

  static const _orb = 58.0;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: _orb + 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Gap(AppSpacing.md),
        itemBuilder: (context, index) {
          final c = categories[index];
          final icon = c.iconUrl?.trim() ?? '';
          return RepaintBoundary(
            child: Semantics(
              button: true,
              label: c.name,
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onSelected?.call(c),
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: SizedBox(
                  width: 66,
                  child: Column(
                    children: [
                      Container(
                        width: _orb,
                        height: _orb,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: orbitOrbGradient(index),
                          boxShadow: [
                            BoxShadow(
                              color: orbitOrbPalettes[
                                      index % orbitOrbPalettes.length][1]
                                  .withValues(alpha: 0.35),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: icon.isEmpty
                            ? null
                            : Padding(
                                padding: const EdgeInsets.all(14),
                                child: AppCachedNetworkImage(
                                  imageUrl: icon,
                                  fit: BoxFit.contain,
                                  memCacheWidth: 120,
                                  errorWidget: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                      ),
                      const Gap(AppSpacing.sm),
                      Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMedium.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).fadeSlideIn(
              delay: AppAnimations.staggerDelayCapped(index),
            ),
          );
        },
      ),
    );
  }
}
