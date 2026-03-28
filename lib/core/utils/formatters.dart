abstract final class Formatters {
  static String currency(num amount, {String symbol = r'$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Algerian DZD saved for profile stats; [minorUnits] e.g. 23000 → 230 DZD shown.
  static String dzdSavedDisplay(int minorUnits) {
    if (minorUnits <= 0) return '0';
    final whole = minorUnits ~/ 100;
    return '$whole';
  }

  /// Compact posted date for listings (local timezone when set).
  static String shortDate(DateTime date) {
    final local = date.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }
}
