import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/constants/app_strings.dart';
import 'package:xstore/core/localization/app_localizations_ar.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';

/// Regression guard for the Egypt-only branding cleanup (see
/// docs_business/02_development_roadmap.md's "Egypt-only cleanup" punch list).
/// These strings were previously left over from the app's Algeria-targeted
/// mock/prototype phase — CIB, Dahabia and BaridiMob are Algerian bank/postal
/// brands, and "Algiers hub" leaked into a live order-tracking string. Payment
/// methods other than cash-on-delivery are no longer selectable at checkout
/// (COD-only launch), but their labels still render for historical orders, so
/// the brand names must not silently come back through that path.
void main() {
  group('historical payment method labels have no Algeria branding', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    test('English labels are neutral, non-branded text', () {
      expect(en.ordersPaymentCib, 'Card payment');
      expect(en.ordersPaymentDahabi, 'Prepaid card');
      expect(en.ordersPaymentBaridimob, 'Mobile wallet');
    });

    test('Arabic labels are neutral, non-branded text', () {
      expect(ar.ordersPaymentCib, 'دفع بالبطاقة');
      expect(ar.ordersPaymentDahabi, 'بطاقة مدفوعة مسبقاً');
      expect(ar.ordersPaymentBaridimob, 'محفظة موبايل');
    });

    test('none of the Algerian brand names appear anywhere in the labels',
        () {
      final labels = [
        en.ordersPaymentCib,
        en.ordersPaymentDahabi,
        en.ordersPaymentBaridimob,
        ar.ordersPaymentCib,
        ar.ordersPaymentDahabi,
        ar.ordersPaymentBaridimob,
      ];
      for (final label in labels) {
        expect(label.toUpperCase(), isNot(contains('CIB')));
        expect(label, isNot(contains('Dahabi')));
        expect(label, isNot(contains('BaridiMob')));
      }
    });
  });

  group('order tracking mock location has no Algeria branding', () {
    test('AppStrings constant matches the already-fixed l10n copy', () {
      // These two used to say "Algiers hub" and "Cairo hub" respectively —
      // having drifted apart is exactly how the leftover survived a prior
      // cleanup pass undetected.
      final en = AppLocalizationsEn();
      expect(AppStrings.ordersCurrentLocationMock, en.ordersCurrentLocationMock);
    });

    test('does not mention Algiers', () {
      expect(AppStrings.ordersCurrentLocationMock, isNot(contains('Algiers')));
      expect(AppStrings.ordersCurrentLocationMock, contains('Cairo'));
    });
  });
}
