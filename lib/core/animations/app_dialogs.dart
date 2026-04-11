import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_animations.dart';

/// Scale + fade dialog.
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: AppAnimations.normal,
    pageBuilder: (_, __, ___) => child,
    transitionBuilder: (_, anim, __, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(
          CurvedAnimation(parent: anim, curve: AppAnimations.spring),
        ),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
  );
}

/// Bottom sheet with fade + slide on content (transparent scrim uses theme default).
Future<T?> showAnimatedBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final content = builder(ctx);
      return content
          .animate()
          .fadeIn(
            duration: AppAnimations.normal,
            curve: AppAnimations.enter,
          )
          .slideY(
            begin: 0.06,
            end: 0,
            duration: AppAnimations.medium,
            curve: AppAnimations.enter,
          );
    },
  );
}
