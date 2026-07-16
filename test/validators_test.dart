import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';
import 'package:xstore/core/utils/validators.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('loginPassword', () {
    test('empty', () {
      expect(Validators.loginPassword(l10n, ''), isNotNull);
    });

    test('too short', () {
      expect(Validators.loginPassword(l10n, '12345'), isNotNull);
    });

    test('min length', () {
      expect(Validators.loginPassword(l10n, '123456'), isNull);
    });
  });

  group('registerEmail', () {
    test('invalid', () {
      expect(Validators.registerEmail(l10n, 'not-an-email'), isNotNull);
    });

    test('valid', () {
      expect(Validators.registerEmail(l10n, ' u@x.com '), isNull);
    });
  });

  group('registerPassword', () {
    test('too short', () {
      expect(Validators.registerPassword(l10n, '1234567'), isNotNull);
    });

    test('ok at 8', () {
      expect(Validators.registerPassword(l10n, '12345678'), isNull);
    });
  });

  group('personFullName', () {
    test('too short', () {
      expect(Validators.personFullName(l10n, 'Ab'), isNotNull);
    });

    test('non letters', () {
      expect(Validators.personFullName(l10n, 'John3'), isNotNull);
    });

    test('valid', () {
      expect(Validators.personFullName(l10n, 'John Doe'), isNull);
    });
  });

  group('egyptPhone', () {
    test('empty', () {
      expect(Validators.egyptPhone(l10n, null), isNotNull);
      expect(Validators.egyptPhone(l10n, ''), isNotNull);
    });

    test('wrong length', () {
      expect(Validators.egyptPhone(l10n, '010'), isNotNull);
    });

    test('wrong prefix', () {
      expect(Validators.egyptPhone(l10n, '01712345678'), isNotNull);
    });

    test('valid 010…', () {
      expect(Validators.egyptPhone(l10n, '01012345678'), isNull);
    });
  });

  group('parseMoneyInput', () {
    test('commas stripped', () {
      expect(Validators.parseMoneyInput('1,234.50'), closeTo(1234.50, 0.001));
    });

    test('invalid', () {
      expect(Validators.parseMoneyInput('abc'), isNull);
    });
  });

  group('listingForm', () {
    test('photos required', () {
      final input = ListingFormValidationInput(
        photoPaths: const [],
        name: 'Shoes',
        priceInput: '10',
        description: 'Nice',
        categoryId: 'c',
        subcategoryId: 's',
        condition: 'new',
        quantity: 1,
        location: 'Cairo',
        shippingAvailable: false,
        shippingCostInput: '',
      );
      expect(Validators.listingFormHasErrors(input), isTrue);
      expect(
        Validators.listingFormErrors(l10n, input)['photos'],
        l10n.listingValidationPhotosRequired,
      );
    });

    test('shipping cost when shipping on', () {
      final input = ListingFormValidationInput(
        photoPaths: const ['x'],
        name: 'Shoes',
        priceInput: '10',
        description: 'Nice',
        categoryId: 'c',
        subcategoryId: 's',
        condition: 'new',
        quantity: 1,
        location: 'Cairo',
        shippingAvailable: true,
        shippingCostInput: '-1',
      );
      expect(Validators.listingFormHasErrors(input), isTrue);
    });

    test('minimal valid listing', () {
      final input = ListingFormValidationInput(
        photoPaths: const ['p'],
        name: 'Shoes',
        priceInput: '10',
        description: 'Nice',
        categoryId: 'c',
        subcategoryId: 's',
        condition: 'new',
        quantity: 1,
        location: 'Cairo',
        shippingAvailable: false,
        shippingCostInput: '',
      );
      expect(Validators.listingFormHasErrors(input), isFalse);
    });
  });
}
