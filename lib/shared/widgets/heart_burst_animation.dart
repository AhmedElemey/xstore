import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/animations/app_animations.dart';

/// Scale “pop” when toggling favorite on.
class HeartBurstAnimation extends StatelessWidget {
  const HeartBurstAnimation({
    super.key,
    required this.isFavorite,
    required this.child,
  });

  final bool isFavorite;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(target: isFavorite ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.35, 1.35),
          duration: AppAnimations.fast,
          curve: AppAnimations.bounce,
        )
        .then()
        .scale(
          begin: const Offset(1.35, 1.35),
          end: const Offset(1.0, 1.0),
          duration: AppAnimations.fast,
          curve: Curves.easeOut,
        );
  }
}
