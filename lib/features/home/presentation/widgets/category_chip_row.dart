import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
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
          return ActionChip(
            label: Text(c.name),
            onPressed: () => onSelected?.call(c),
          );
        },
      ),
    );
  }
}
