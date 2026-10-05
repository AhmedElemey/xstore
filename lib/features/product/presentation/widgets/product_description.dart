import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/expandable_text.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({
    super.key,
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.description,
            style: AppTypography.labelLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.labelColor,
            ),
          ),
          const Gap(AppSpacing.sm),
          ExpandableText(
            text: text,
            maxLines: 4,
            expanded: expanded,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              height: 1.55,
            ),
            toggle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: GestureDetector(
                onTap: onToggle,
                child: Text(
                  expanded
                      ? '${context.l10n.readLess} ${context.arrowBack}'
                      : '${context.l10n.readMore} ${context.arrowForward}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.linkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
