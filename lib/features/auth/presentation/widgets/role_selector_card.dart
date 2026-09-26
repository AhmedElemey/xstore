import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

/// Orbit account-type choice: planet orb with an icon, title and line, and
/// a radio dot. The selected card glows in the accent colour.
class RoleSelectorCard extends StatelessWidget {
  const RoleSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.paletteIndex,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int paletteIndex;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    final radius = BorderRadius.circular(24);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.08)
              : glassFill(context),
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? accent : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 30,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  OrbitGlyphOrb(
                    icon: icon,
                    paletteIndex: paletteIndex,
                    size: 60,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            height: 1.4,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? accent : null,
                      border: isSelected
                          ? null
                          : Border.all(color: context.borderColor, width: 2),
                    ),
                    child: isSelected
                        ? Icon(
                            LucideIcons.check,
                            size: 14,
                            color: context.isDark
                                ? AppColors.space
                                : AppColors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
