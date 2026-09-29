import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';

abstract final class Formatters {
  static String currency(num amount, {String symbol = r'$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
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
    DateTime createdAt,
    AppLocalizations l10n, {
    DateTime? now,
  }) {
    final n = (now ?? DateTime.now()).toLocal();
    final t = createdAt.toLocal();
    final diff = n.difference(t);
    if (diff.inMinutes < 1) return l10n.notificationsTimeJustNow;
    if (diff.inHours < 1) {
      return l10n.notificationsTimeMinutesAgo(diff.inMinutes);
    }
    final today = DateTime(n.year, n.month, n.day);
    final itemDay = DateTime(t.year, t.month, t.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (itemDay == yesterday) return l10n.notificationsTimeYesterday;
    if (itemDay == today) {
      return l10n.notificationsTimeHoursAgo(diff.inHours.clamp(1, 23));
    }
    final startOfWeek = today.subtract(Duration(days: today.weekday - DateTime.monday));
    // Locale date symbols are loaded by GlobalMaterialLocalizations before
    // any screen renders; plain unit tests call initializeDateFormatting.
    final locale = l10n.localeName;
    if (!itemDay.isBefore(startOfWeek) && itemDay.isBefore(today)) {
      return DateFormat.E(locale).format(t);
    }
    return DateFormat.MMMd(locale).format(t);
  }
}
