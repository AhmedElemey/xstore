import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit auth heading: the small "xStore" wordmark, an Unbounded headline
/// and an optional subtitle, left-aligned over the sky background.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showWordmark = true,
  });

  final String title;
  final String? subtitle;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showWordmark) ...[
          const AuthWordmark(size: 18),
          SizedBox(height: context.scaledPx(22)),
        ],
        Text(
          title,
          style: AppTypography.headline.copyWith(color: context.textPrimary),
        ),
        if (subtitle != null) ...[
          SizedBox(height: context.scaledPx(8)),
          Text(
            subtitle!,
            style: AppTypography.body15.copyWith(color: context.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// "x" + accent "Store" in the display face.
class AuthWordmark extends StatelessWidget {
  const AuthWordmark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.displayLarge.copyWith(
      fontSize: size,
      height: 1,
      color: context.textPrimary,
    );
    return Text.rich(
      TextSpan(
        text: 'x',
        style: style,
        children: [
          TextSpan(
            text: 'Store',
            style: TextStyle(
              color: context.isDark
                  ? AppColors.primaryLight
                  : AppColors.primaryDark,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

/// Frosted 44px circular back button used across the auth flow.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.glassColor,
      shape: CircleBorder(side: BorderSide(color: context.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: SizedBox.square(
          dimension: 44,
          child: Icon(
            // matchTextDirection: Flutter flips it for RTL on its own.
            Icons.chevron_left,
            size: 26,
            color: context.textPrimary,
            semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
      ),
    );
  }
}
