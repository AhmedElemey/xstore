import 'package:flutter/material.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.borderColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scaledPx(12)),
          child: Text(
            context.l10n.authOr,
            style: TextStyle(
              fontSize: AppTypography.rem(0.8125),
              color: context.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.borderColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
