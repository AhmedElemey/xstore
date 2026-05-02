import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class RoleSelectorCard extends StatelessWidget {
  const RoleSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
    required this.selectionBorderColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final Color selectionBorderColor;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? accentColor.withValues(alpha: 0.08)
        : context.surfaceColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? selectionBorderColor : AppColors.lightBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (isSelected)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: selectionBorderColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: selectionBorderColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 48, color: accentColor),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing6),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        height: 1.35,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.inputContentPaddingH),
                    ...features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.spacing6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: accentColor.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                f,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
