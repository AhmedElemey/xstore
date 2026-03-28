import 'package:intl/intl.dart';

import '../constants/app_strings.dart';

abstract final class Formatters {
  static String currency(num amount, {String symbol = r'$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Whole DZD with grouping, e.g. `185,500 DZD`.
  static String dzdWhole(double amount) {
    final f = NumberFormat('#,##0', 'fr_FR');
    return '${f.format(amount.round())} ${AppStrings.currencyDzd}';
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
