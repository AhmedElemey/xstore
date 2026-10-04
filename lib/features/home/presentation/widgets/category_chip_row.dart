import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/category_entity.dart';

class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    this.onSelected,
  });

  final List<CategoryEntity> categories;
  final void Function(CategoryEntity category)? onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
        itemBuilder: (context, index) {
          final c = categories[index];
          return RepaintBoundary(
            child: ActionChip(
              avatar: c.iconUrl == null ? null : _CategoryAvatar(category: c),
              label: Text(c.name),
              onPressed: () => onSelected?.call(c),
            ).fadeSlideIn(
              delay: AppAnimations.staggerDelayCapped(index),
            ),
          );
        },
      ),
    );
  }
}

/// The admin-uploaded category picture, decoded at chip size. A missing or
/// broken image (some seeded categories point at files that 404) falls back to
/// the category's first letter so the chip never shows a broken icon.
class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.category});

  static const double _size = 24;

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    final cacheSize =
        (_size * MediaQuery.devicePixelRatioOf(context)).round();
    final fallback = CircleAvatar(
      radius: _size / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        category.name.isEmpty ? '?' : category.name.characters.first,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
    return ClipOval(
      child: AppCachedNetworkImage(
        imageUrl: category.iconUrl!,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}
