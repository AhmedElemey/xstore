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

    test('missing complexity (digits only) is rejected', () {
      expect(Validators.registerPassword(l10n, '12345678'), isNotNull);
    });

    test('missing special character is rejected', () {
      expect(Validators.registerPassword(l10n, 'Passw0rd'), isNotNull);
    });

    test('meets length + uppercase + lowercase + digit + special char', () {
      expect(Validators.registerPassword(l10n, 'Passw0rd!'), isNull);
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

  group('dateOfBirth', () {
    final today = DateTime(2026, 7, 26);
    final yesterday = DateTime(2026, 7, 25);

    test('null is valid', () {
      expect(Validators.dateOfBirth(l10n, null, now: today), isNull);
    });

    test('yesterday is valid', () {
      expect(
        Validators.dateOfBirth(l10n, yesterday, now: today),
        isNull,
      );
    });

    test('today is valid', () {
      expect(
        Validators.dateOfBirth(l10n, today, now: today),
        isNull,
      );
    });

    test('future is rejected', () {
      expect(
        Validators.dateOfBirth(l10n, DateTime(2027, 1, 1), now: today),
        l10n.validationBirthDateBeforeToday,
      );
    });

    test('under 18 when enforced', () {
      expect(
        Validators.dateOfBirth(
          l10n,
          DateTime(2010, 1, 1),
          now: today,
          enforceMinimumAge: true,
        ),
        l10n.validationAgeMinimum18,
      );
    });

    test('18+ when enforced', () {
      expect(
        Validators.dateOfBirth(
          l10n,
          DateTime(2000, 1, 1),
          now: today,
          enforceMinimumAge: true,
        ),
        isNull,
      );
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

    ListingFormValidationInput baseInput({
      String compareAtPriceInput = '',
      bool subcategoryRequired = true,
      String subcategoryId = 's',
    }) =>
        ListingFormValidationInput(
          photoPaths: const ['p'],
          name: 'Shoes',
          priceInput: '100',
          description: 'Nice',
          categoryId: 'c',
          subcategoryId: subcategoryId,
          condition: 'new',
          quantity: 1,
          location: 'Cairo',
          shippingAvailable: false,
          shippingCostInput: '',
          compareAtPriceInput: compareAtPriceInput,
          subcategoryRequired: subcategoryRequired,
        );

    test('compareAtPrice omitted is valid', () {
      final input = baseInput();
      expect(Validators.listingFormHasErrors(input), isFalse);
      expect(Validators.listingFormErrors(l10n, input)['compareAtPrice'], isNull);
    });

    test('compareAtPrice below price is rejected', () {
      final input = baseInput(compareAtPriceInput: '50');
      expect(Validators.listingFormHasErrors(input), isTrue);
      expect(
        Validators.listingFormErrors(l10n, input)['compareAtPrice'],
        l10n.listingValidationCompareAtPrice,
      );
    });

    test('compareAtPrice equal to price is rejected', () {
      final input = baseInput(compareAtPriceInput: '100');
      expect(Validators.listingFormHasErrors(input), isTrue);
    });

    test('compareAtPrice above price is valid', () {
      final input = baseInput(compareAtPriceInput: '150');
      expect(Validators.listingFormHasErrors(input), isFalse);
      expect(Validators.listingFormErrors(l10n, input)['compareAtPrice'], isNull);
    });

    test('subcategory required by default when category is set', () {
      final input = baseInput(subcategoryId: '');
      expect(Validators.listingFormHasErrors(input), isTrue);
      expect(
        Validators.listingFormErrors(l10n, input)['subcategory'],
        l10n.listingValidationSubcategoryRequired,
      );
    });

    test('subcategory not required for a leaf category', () {
      final input = baseInput(subcategoryId: '', subcategoryRequired: false);
      expect(Validators.listingFormHasErrors(input), isFalse);
      expect(Validators.listingFormErrors(l10n, input)['subcategory'], isNull);
    });
  });
}
