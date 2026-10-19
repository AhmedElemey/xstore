import 'package:flutter/material.dart';

import '../../core/utils/extensions/context_extensions.dart';

/// Frosted 44px circular back button used across Orbit screens.
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
