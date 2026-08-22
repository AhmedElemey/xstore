import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

String listingLocalizedCondition(BuildContext context, String condition) {
  final l = context.l10n;
  return switch (condition) {
    'New' => l.listingCondNew,
    'Like New' => l.listingCondLikeNew,
    'Good' => l.listingCondGood,
    'Used / For Parts' => l.listingCondUsedForParts,
    // Legacy tokens from data saved before the 4-value backend alignment.
    'Used' || 'For Parts' => l.listingCondUsedForParts,
    _ => condition,
  };
}
