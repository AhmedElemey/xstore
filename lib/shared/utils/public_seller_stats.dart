import '../../core/localization/app_localizations.dart';

/// Visible seller stats. Missing/zero values are "new seller" — never 4.9 / 230.
String publicSellerStatsLabel(
  AppLocalizations l10n, {
  double? rating,
  int? sales,
}) {
  final hasRating = rating != null && rating > 0;
  final hasSales = sales != null && sales > 0;
  if (!hasRating && !hasSales) return l10n.newSeller;
  final star = hasRating ? '⭐ ${rating.toStringAsFixed(1)}' : null;
  final sold = hasSales ? '$sales ${l10n.statSalesShort}' : null;
  return [star, sold].whereType<String>().join(' · ');
}
