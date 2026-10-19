import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit role option: a glowing orb with the role icon, title and subtitle,
/// a radio-style indicator at the end, and the feature checklist below.
/// Selected cards get a brand border, tint and glow.
class RoleSelectorCard extends StatelessWidget {
  const RoleSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.orbColors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  /// Radial gradient of the icon orb, highlight first.
  final List<Color> orbColors;

  static const _radius = BorderRadius.all(Radius.circular(24));

  @override
  Widget build(BuildContext context) {
    final brand = context.isDark ? AppColors.primaryLight : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? brand.withValues(alpha: 0.08)
              : context.glassColor,
          borderRadius: _radius,
          border: Border.all(
            color: isSelected ? brand : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          // No outer glow: a shadow paints under the translucent fill and
          // muddies it; the orb carries the glow instead.
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: _radius,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.4),
                            colors: orbColors,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: brand.withValues(alpha: 0.5),
                                    blurRadius: 24,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          size: 26,
                          color: AppColors.darkBackground,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleSmall.copyWith(
                                fontSize: AppTypography.rem(1.0625),
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _RadioDot(selected: isSelected, color: brand),
                    ],
                  ),
                  if (features.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    for (final f in features)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.spacing6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: context.linkColor,
                              ),
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
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled check when selected, an empty ring otherwise.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : null,
        border: selected
            ? null
            : Border.all(
                color: context.labelColor.withValues(alpha: 0.5),
                width: 2,
              ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 16, color: context.onBrandColor)
          : null,
    );
  }
}
