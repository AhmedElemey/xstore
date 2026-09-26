import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit auth heading: optional "xStore" wordmark, a display-face title and
/// a supporting line, left-aligned.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showWordmark = false,
  });

  final String title;
  final String? subtitle;

  /// Login shows the wordmark and a larger title.
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showWordmark) ...[
          Text.rich(
            TextSpan(
              text: 'x',
              children: [
                TextSpan(
                  text: 'Store',
                  style: TextStyle(color: context.primaryColor),
                ),
              ],
            ),
            style: AppTypography.titleMedium.copyWith(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.x2l - 2),
        ],
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            fontSize: showWordmark ? 30 : 26,
            fontWeight: FontWeight.w800,
            height: 1.12,
            color: context.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTypography.bodyLarge.copyWith(
              height: 1.5,
              color: context.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
