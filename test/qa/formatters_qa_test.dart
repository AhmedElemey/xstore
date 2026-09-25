// QA suite (2026-09-24): pure formatting helpers.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/formatters.dart';

void main() {
  group('formatNotificationTime', () {
    final now = DateTime(2026, 9, 24, 12, 0);
    final en = lookupAppLocalizations(const Locale('en'));
    String f(DateTime t) => Formatters.formatNotificationTime(t, en, now: now);

    test('just now / minutes / hours', () {
      expect(f(now.subtract(const Duration(seconds: 30))),
          en.notificationsTimeJustNow);
      expect(f(now.subtract(const Duration(minutes: 5))),
          en.notificationsTimeMinutesAgo(5));
      expect(f(now.subtract(const Duration(hours: 3))),
          en.notificationsTimeHoursAgo(3));
    });

    test('yesterday', () {
      expect(f(DateTime(2026, 9, 23, 12)),
          en.notificationsTimeYesterday);
    });

    test('uses the passed locale, not hardcoded English', () {
      final ar = lookupAppLocalizations(const Locale('ar'));
      final yesterday = DateTime(2026, 9, 23, 12);
      expect(
        Formatters.formatNotificationTime(yesterday, ar, now: now),
        ar.notificationsTimeYesterday,
      );
      expect(ar.notificationsTimeYesterday, isNot(en.notificationsTimeYesterday));
    });

    test('older than a week shows month/day', () {
      expect(f(DateTime(2026, 8, 1, 12)), 'Aug 1');
    });

    test('a future timestamp (clock skew) does not throw or show negatives',
        () {
      final label = f(now.add(const Duration(hours: 2)));
      expect(label, isNot(contains('-')));
    });
  });

  group('Formatters.shortDate', () {
    test('zero-pads month and day', () {
      expect(Formatters.shortDate(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });
}
