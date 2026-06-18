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

  /// Egyptn DZD saved for profile stats; [minorUnits] e.g. 23000 → 230 DZD shown.
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

  /// Relative labels for notification rows (local time).
  static String formatNotificationTime(
    DateTime createdAt, {
    DateTime? now,
  }) {
    final n = (now ?? DateTime.now()).toLocal();
    final t = createdAt.toLocal();
    final diff = n.difference(t);
    if (diff.inMinutes < 1) return AppStrings.notificationsTimeJustNow;
    if (diff.inHours < 1) {
      return AppStrings.notificationsTimeMinutesAgo(diff.inMinutes);
    }
    final today = DateTime(n.year, n.month, n.day);
    final itemDay = DateTime(t.year, t.month, t.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (itemDay == yesterday) return AppStrings.notificationsTimeYesterday;
    if (itemDay == today) {
      return AppStrings.notificationsTimeHoursAgo(diff.inHours.clamp(1, 23));
    }
    final startOfWeek = today.subtract(Duration(days: today.weekday - DateTime.monday));
    if (!itemDay.isBefore(startOfWeek) && itemDay.isBefore(today)) {
      // Avoid DateFormat.E — requires initializeDateFormatting in main.
      const dow = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return dow[t.weekday - 1];
    }
    const mon = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${mon[t.month - 1]} ${t.day}';
  }
}
