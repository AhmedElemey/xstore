import 'package:flutter/material.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.textDisabled.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scaledPx(12)),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.rem(0.8125),
              color: context.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.textDisabled.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
