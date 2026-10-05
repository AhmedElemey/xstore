import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/category_entity.dart';

/// Orbit category "planets": a glowing orb per category with its name below.
class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({super.key, required this.categories, this.onSelected});

  final List<CategoryEntity> categories;
  final void Function(CategoryEntity category)? onSelected;

  static const double _orbSize = 58;
  static const double _itemWidth = 66;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: _orbSize + 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
        itemBuilder: (context, index) {
          final c = categories[index];
          return RepaintBoundary(
            child: Semantics(
              button: true,
              label: c.name,
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onSelected?.call(c),
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                child: SizedBox(
                  width: _itemWidth,
                  child: Column(
                    children: [
                      const Gap(AppSpacing.xs),
                      _CategoryOrb(category: c, index: index),
                      const Gap(AppSpacing.sm),
                      Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.body12.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).fadeSlideIn(delay: AppAnimations.staggerDelayCapped(index)),
          );
        },
      ),
    );
  }
}

/// The admin-uploaded category picture inside an orb, decoded at orb size.
/// A missing or broken image (some seeded categories point at files that 404)
/// falls back to a coloured orb with the category's first letter.
class _CategoryOrb extends StatelessWidget {
  const _CategoryOrb({required this.category, required this.index});

  final CategoryEntity category;
  final int index;

  // Highlight, mid and shadow tones of the Orbit planet palette.
  static const _palettes = <List<Color>>[
    [Color(0xFFE9FDFF), Color(0xFF7CF0FF), Color(0xFF2B4BD1)],
    [Color(0xFFFFE8F6), Color(0xFFFF8FD0), Color(0xFF6B2A8C)],
    [Color(0xFFF3EDFF), Color(0xFFB69CFF), Color(0xFF3A2290)],
    [Color(0xFFFFF4DE), Color(0xFFFFC069), Color(0xFF9A4A1A)],
    [Color(0xFFE6FFF4), Color(0xFF6CF2B4), Color(0xFF11695A)],
  ];

  @override
  Widget build(BuildContext context) {
    const size = CategoryChipRow._orbSize;
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: _palettes[index % _palettes.length],
          stops: const [0, 0.4, 1],
        ),
      ),
      child: Center(
        child: Text(
          category.name.isEmpty ? '?' : category.name.characters.first,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 20,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
    final iconUrl = category.iconUrl;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x407CA0FF), blurRadius: 22)],
      ),
      child: ClipOval(
        child: iconUrl == null
            ? fallback
            : AppCachedNetworkImage(
                imageUrl: iconUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                memCacheWidth: cacheSize,
                memCacheHeight: cacheSize,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
