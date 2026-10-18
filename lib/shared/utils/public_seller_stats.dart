import 'package:flutter/widgets.dart';

import '../../core/utils/extensions/context_extensions.dart';

/// Visible seller stats. Missing/zero values are "new seller" — never 4.9 / 230.
String publicSellerStatsLabel(
  BuildContext context, {
  double? rating,
  int? sales,
}) {
  final hasRating = rating != null && rating > 0;
  final hasSales = sales != null && sales > 0;
  if (!hasRating && !hasSales) return context.l10n.newSeller;
  final star = hasRating ? '⭐ ${context.formatDecimal(rating)}' : null;
  final sold = hasSales ? '${context.formatInt(sales)} ${context.l10n.statSalesShort}' : null;
  return [star, sold].whereType<String>().join(' · ');
}
