// Orbit QA round 5: the last Latin digits next to Arabic-Indic prices, Arabic
// dates and decimal mark, Latin paragraphs and truncating home labels laid
// out by their own first letter.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/extensions/context_extensions.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/explore/presentation/explore_state.dart';
import 'package:xstore/features/explore/presentation/widgets/filter_bottom_sheet.dart';
import 'package:xstore/features/home/domain/entities/banner_entity.dart';
import 'package:xstore/features/home/domain/entities/category_entity.dart';
import 'package:xstore/features/home/presentation/widgets/category_chip_row.dart';
import 'package:xstore/features/home/presentation/widgets/hero_banner_carousel.dart';
import 'package:xstore/features/home/presentation/widgets/product_card.dart';
import 'package:xstore/features/listing/presentation/widgets/listing_stats_banner.dart';
import 'package:xstore/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:xstore/features/wishlist/presentation/widgets/price_drop_badge.dart';
import 'package:xstore/shared/widgets/expandable_text.dart';

const _ar = Locale('ar');

Widget _app(Widget home, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

Future<BuildContext> _context(WidgetTester tester, {Locale? locale}) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    _app(
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
      locale: locale,
    ),
  );
  return ctx;
}

/// The left-to-right isolate `BuildContext.ltr` wraps Arabic values in.
String _ltr(String value) => '\u2066$value\u2069';

bool _hasLatinDigit(String s) => RegExp('[0-9]').hasMatch(s);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ar = lookupAppLocalizations(_ar);

  group('formatting helpers', () {
    testWidgets('ratings use the Arabic decimal separator, not a comma', (
      tester,
    ) async {
      final ctx = await _context(tester, locale: _ar);
      expect(ctx.formatDecimal(4.6), '٤٫٦');
      expect(ctx.formatDecimal(4.6), isNot(contains(',')));
    });

    testWidgets('English ratings keep the dot', (tester) async {
      final ctx = await _context(tester);
      expect(ctx.formatDecimal(4.6), '4.6');
    });

    testWidgets('percent and discount read the same in both languages', (
      tester,
    ) async {
      final en = await _context(tester);
      expect(en.formatPercent(89), '89%');
      expect(en.formatDiscount(15), '-15%');

      final ctx = await _context(tester, locale: _ar);
      expect(ctx.formatPercent(89), '٨٩٪');
      // Isolated left-to-right so the minus stays in front of the number.
      expect(ctx.formatDiscount(15), _ltr('-١٥٪'));
    });

    testWidgets('Arabic dates use the Arabic comma and digits', (tester) async {
      final ctx = await _context(tester, locale: _ar);
      final d = DateTime(2026, 10, 4, 14, 5);
      for (final text in [
        ctx.formatMediumDate(d),
        ctx.formatWeekdayDate(d),
        ctx.formatLongDate(d),
      ]) {
        expect(text, isNot(contains(',')), reason: text);
        expect(text, contains('،'), reason: text);
        expect(_hasLatinDigit(text), isFalse, reason: text);
      }
      expect(ctx.formatMediumDate(d), 'أكتوبر '
          '٤، ٢٠٢٦');
      expect(_hasLatinDigit(ctx.formatShortDate(d)), isFalse);
    });

    testWidgets('English dates are unchanged', (tester) async {
      final ctx = await _context(tester);
      expect(ctx.formatMediumDate(DateTime(2026, 10, 4)), 'Oct 4, 2026');
    });
  });

  group('stat tiles and badges in Arabic', () {
    testWidgets('vendor profile stats row', (tester) async {
      await tester.pumpWidget(
        _app(
          const ProfileStatsRow(
            role: UserRole.vendor,
            sales: 142,
            rating: 4.8,
            responsePercent: 89,
          ),
          locale: _ar,
        ),
      );
      expect(find.text('١٤٢'), findsOneWidget);
      expect(find.text('٤٫٨ ★'), findsOneWidget);
      expect(find.text('٨٩٪'), findsOneWidget);
    });

    testWidgets('consumer profile stats row (orders, favorites)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const ProfileStatsRow(
            role: UserRole.consumer,
            orders: 12,
            wishlistCount: 3,
          ),
          locale: _ar,
        ),
      );
      expect(find.text('١٢'), findsOneWidget);
      expect(find.text('٣'), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('My Listings stat tiles', (tester) async {
      await tester.pumpWidget(
        _app(
          const ListingStatsBanner(
            totalCount: 6,
            activeCount: 5,
            soldOutCount: 0,
          ),
          locale: _ar,
        ),
      );
      expect(find.text('٦'), findsOneWidget);
      expect(find.text('٥'), findsOneWidget);
      expect(find.text('٠'), findsOneWidget);
    });

    testWidgets('home product card discount badge', (tester) async {
      await tester.pumpWidget(
        _app(
          const ProductCard(
            title: 'Phone',
            price: 1000,
            discountPercent: 15,
          ),
          locale: _ar,
        ),
      );
      expect(find.text(_ltr('-١٥٪')), findsOneWidget);
      expect(find.textContaining('15'), findsNothing);
    });

    testWidgets('wishlist price drop badge', (tester) async {
      await tester.pumpWidget(
        _app(const PriceDropBadge(percent: 20), locale: _ar),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('٢٠٪'), findsOneWidget);
      expect(find.textContaining('20'), findsNothing);
    });

    test('count messages take the formatted string', () {
      expect(ar.checkoutItemsFromSellers('٢', '١'), contains('٢'));
      expect(ar.vendorOrdersConfirmed('٣'), contains('٣'));
      expect(ar.courierPackagesCount(5, '٥'), contains('٥'));
      expect(ar.courierPackagesCount(1, '١'), isNot(contains('١')));
      expect(ar.checkoutPartialOrderWarning(4, '٤'), contains('٤'));
      expect(_hasLatinDigit(ar.listingPhotoSectionSubtitle), isFalse);
      expect(_hasLatinDigit(ar.listingValidationNameMax), isFalse);
      expect(_hasLatinDigit(ar.ratingStars4Plus), isFalse);
    });
  });

  group('filter sheet', () {
    Future<void> open(
      WidgetTester tester, {
      required Locale? locale,
      required void Function(FilterState) onApply,
    }) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showExploreFilterBottomSheet(
                context: context,
                initial: const FilterState(),
                categoryOptions: const [],
                onApply: onApply,
                onReset: () {},
              ),
              child: const Text('open'),
            ),
          ),
          locale: locale,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    TextField field(WidgetTester tester, String label) =>
        tester.widget<TextField>(
          find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == label,
          ),
        );

    testWidgets('Arabic shows Arabic-Indic price inputs and rating chips', (
      tester,
    ) async {
      await open(tester, locale: _ar, onApply: (_) {});
      expect(field(tester, ar.minPriceLabel).controller!.text, '٠');
      expect(
        field(tester, ar.maxPriceLabel).controller!.text,
        '٥٠٠٠٠',
      );
      expect(find.text(ar.ratingStars4Plus), findsOneWidget);
      expect(_hasLatinDigit(ar.ratingStars4Plus), isFalse);
    });

    testWidgets('typed Arabic digits still parse', (tester) async {
      FilterState? applied;
      await open(tester, locale: _ar, onApply: (s) => applied = s);
      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == ar.minPriceLabel,
        ),
        '١٢٣',
      );
      await tester.ensureVisible(find.text(ar.applyFiltersCount('٠')));
      await tester.tap(find.text(ar.applyFiltersCount('٠')));
      await tester.pumpAndSettle();
      expect(applied?.minPrice, 123);
      expect(applied?.maxPrice, 50000);
    });

    testWidgets('English keeps Latin digits', (tester) async {
      await open(tester, locale: null, onApply: (_) {});
      final en = lookupAppLocalizations(const Locale('en'));
      expect(field(tester, en.minPriceLabel).controller!.text, '0');
      expect(field(tester, en.maxPriceLabel).controller!.text, '50000');
    });
  });

  group('Latin text in the Arabic UI', () {
    Widget paragraph(String text) => SizedBox(
      width: 300,
      child: ExpandableText(
        text: text,
        maxLines: 3,
        expanded: false,
        toggle: const SizedBox(),
      ),
    );

    testWidgets('a Latin description is laid out LTR so its period ends it', (
      tester,
    ) async {
      const text = 'Like new, original box and USB-C cable.';
      await tester.pumpWidget(_app(paragraph(text), locale: _ar));
      expect(tester.widget<Text>(find.text(text)).textDirection,
          TextDirection.ltr);
    });

    testWidgets('an Arabic description stays RTL', (tester) async {
      const text = 'جديد بالعلبة الأصلية.';
      await tester.pumpWidget(_app(paragraph(text), locale: _ar));
      expect(tester.widget<Text>(find.text(text)).textDirection,
          TextDirection.rtl);
    });

    testWidgets('home banner title and category label follow their letters', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              SizedBox(
                height: 200,
                child: HeroBannerCarousel(
                  banners: [
                    BannerEntity(
                      id: 'b1',
                      title: 'Electronics Sale - Limited Offer',
                      imageUrl: 'https://example.test/banner.jpg',
                    ),
                  ],
                ),
              ),
              CategoryChipRow(
                categories: [CategoryEntity(id: '1', name: 'Electronics')],
              ),
            ],
          ),
          locale: _ar,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<Text>(find.text('Electronics Sale - Limited Offer'))
            .textDirection,
        TextDirection.ltr,
      );
      expect(
        tester.widget<Text>(find.text('Electronics')).textDirection,
        TextDirection.ltr,
      );
    });
  });
}
