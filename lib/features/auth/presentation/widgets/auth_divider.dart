import 'package:flutter/material.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label});

  /// Defaults to the localized "or continue with".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: context.borderColor, thickness: 1),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scaledPx(12)),
          child: Text(
            label ?? context.l10n.socialLoginDivider,
            style: AppTypography.body12.copyWith(color: context.labelColor),
          ),
        ),
        line,
      ],
    );
  }
}
