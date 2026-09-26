import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Orbit design primitives shared by every redesigned screen.

/// Frosted card: translucent surface, hairline border, 22 px corners.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = 22,
    this.onTap,
    this.borderColor,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? context.borderColor),
    );
    return Material(
      color: color ?? glassFill(context),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The translucent fill behind glass surfaces.
Color glassFill(BuildContext context) => context.isDark
    ? AppColors.white.withValues(alpha: 0.05)
    : AppColors.white.withValues(alpha: 0.82);

/// 44 px round icon button on a glass disc (header actions, back buttons).
class OrbitCircleButton extends StatelessWidget {
  const OrbitCircleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: glassFill(context),
      shape: CircleBorder(side: BorderSide(color: context.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Section title in the display face with an optional trailing action.
class OrbitSectionHeader extends StatelessWidget {
  const OrbitSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: context.primaryColor,
              minimumSize: const Size(44, 44),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Planet-style radial gradients used for category orbs and image
/// placeholders, picked by index so neighbours differ.
const List<List<Color>> orbitOrbPalettes = [
  [Color(0xFFE9FDFF), Color(0xFF7CF0FF), Color(0xFF2B4BD1)],
  [Color(0xFFFFE8F6), Color(0xFFFF8FD0), Color(0xFF6B2A8C)],
  [Color(0xFFF3EDFF), Color(0xFFB69CFF), Color(0xFF3A2290)],
  [Color(0xFFFFF4DE), Color(0xFFFFC069), Color(0xFF9A4A1A)],
  [Color(0xFFE6FFF4), Color(0xFF6CF2B4), Color(0xFF11695A)],
];

RadialGradient orbitOrbGradient(int index) {
  final colors = orbitOrbPalettes[index % orbitOrbPalettes.length];
  return RadialGradient(
    center: const Alignment(-0.3, -0.4),
    colors: colors,
    stops: const [0, 0.4, 1],
  );
}
