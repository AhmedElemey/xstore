import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';

class ProductSpecifications extends StatelessWidget {
  const ProductSpecifications({
    super.key,
    required this.specifications,
  });

  final Map<String, String> specifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = specifications.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++)
                  Container(
                    color: i.isEven ? Colors.white : const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entries[i].key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entries[i].value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
