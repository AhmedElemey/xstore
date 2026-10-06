import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/extensions/context_extensions.dart';

// The date helpers replaced ad-hoc DateFormat calls keyed on
// l10n.localeName; each must render exactly what that call did.
void main() {
  final d = DateTime(2026, 3, 5, 14, 7);

  testWidgets('formatShortDate reads "5 Mar 2026" in English', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(ctx.formatShortDate(d), '5 Mar 2026');
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets(
      'date helpers match the replaced patterns (${locale.languageCode})',
      (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        final name = ctx.l10n.localeName;
        String fmt(String pattern) => DateFormat(pattern, name).format(d);

        // Day-first with a month name, never the ambiguous d/M/yyyy.
        expect(ctx.formatShortDate(d), fmt('d MMM yyyy'));
        expect(ctx.formatShortDate(d), ctx.formatDate(d));
        expect(ctx.formatMediumDate(d), fmt('MMM d, yyyy'));
        expect(ctx.formatWeekdayDate(d), fmt('EEEE, MMM d'));
        expect(ctx.formatLongDate(d), fmt('EEEE, MMM d, yyyy'));
        expect(ctx.formatMonthYear(d), fmt('MMM y'));
        expect(ctx.formatTime(d), fmt('HH:mm'));
        expect(
          '${ctx.formatMediumDate(d)} · ${ctx.formatTime(d)}',
          fmt('MMM d, yyyy · HH:mm'),
        );
        expect(ctx.formatLocaleMediumDate(d), DateFormat.yMMMd(name).format(d));
      },
    );
  }
}
