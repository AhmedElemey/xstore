import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Five amber stars; those past [rating] are dimmed.
class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(0, 5);
    return Semantics(
      label: '$filled/5',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(
              Icons.star_rounded,
              size: 16,
              color: i < filled
                  ? context.amberColor
                  : context.labelColor.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}
