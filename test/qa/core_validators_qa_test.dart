// QA suite (2026-09-24): edge cases for shared validation / normalization.
// A failing test here is a confirmed defect — see QA_REPORT.md for severity.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/jwt_payload.dart';
import 'package:xstore/core/utils/validators.dart';
import 'package:xstore/shared/utils/whatsapp.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('Egypt phone normalization', () {
    test('happy paths normalize to 11-digit local', () {
      expect(AppValidators.normalizeEgyptLocal('01012345678'), '01012345678');
      expect(AppValidators.normalizeEgyptLocal('+201012345678'), '01012345678');
      expect(AppValidators.normalizeEgyptLocal('201012345678'), '01012345678');
      expect(AppValidators.normalizeEgyptLocal('1012345678'), '01012345678');
      expect(AppValidators.normalizeEgyptLocal('010 1234 5678'), '01012345678');
    });

    test('valid prefixes 010/011/012/015 only', () {
      for (final p in ['010', '011', '012', '015']) {
        expect(Validators.egyptPhone(l10n, '${p}12345678'), isNull, reason: p);
      }
      for (final p in ['013', '014', '016', '019', '020']) {
        expect(Validators.egyptPhone(l10n, '${p}12345678'), isNotNull,
            reason: p);
      }
    });

    test('empty / too short / too long are rejected', () {
      expect(Validators.egyptPhone(l10n, ''), isNotNull);
      expect(Validators.egyptPhone(l10n, '   '), isNotNull);
      expect(Validators.egyptPhone(l10n, '0101234567'), isNotNull);
      expect(Validators.egyptPhone(l10n, '010123456789'), isNotNull);
    });

    test('00-prefixed international form (0020…) normalizes to local', () {
      // Common way Egyptians write a number copied from WhatsApp/contacts.
      expect(AppValidators.normalizeEgyptLocal('00201012345678'), '01012345678');
    });

    test('+20 followed by the trunk 0 (+20 010…) normalizes to local', () {
      expect(AppValidators.normalizeEgyptLocal('+2001012345678'), '01012345678');
    });

    test('Arabic-Indic digits (Arabic keyboard) are accepted', () {
      // ٠١٠١٢٣٤٥٦٧٨ == 01012345678
      expect(
        AppValidators.normalizeEgyptLocal('٠١٠١٢٣٤٥٦٧٨'),
        '01012345678',
      );
    });

    test('national significant number for +20 field', () {
      expect(AppValidators.egyptNationalSignificantNumber('01012345678'),
          '1012345678');
      expect(AppValidators.egyptNationalSignificantNumber(''), '');
      // Typing a lone trunk 0 must not stay in the +20 field.
      expect(AppValidators.egyptNationalSignificantNumber('0'), '');
    });

    test('pasting 0020… into the +20 field keeps the right number', () {
      expect(AppValidators.egyptNationalSignificantNumber('00201012345678'),
          '1012345678');
    });

    test('E.164 and display formatting round-trip', () {
      expect(AppValidators.toE164Egypt('01012345678'), '+201012345678');
      expect(AppValidators.toLocalEgypt('+201012345678'), '01012345678');
      expect(AppValidators.formatEgyptPhone('+201012345678'), '0101 234 5678');
    });

    test('toE164Egypt on empty input should not fabricate "+20"', () {
      expect(AppValidators.toE164Egypt(''), isNot('+20'));
    });

    test('missing-phone placeholders', () {
      expect(AppValidators.isMissingPhoneNumber(null), isTrue);
      expect(AppValidators.isMissingPhoneNumber(''), isTrue);
      expect(AppValidators.isMissingPhoneNumber('00000000000'), isTrue);
      expect(AppValidators.isMissingPhoneNumber('01012345678'), isFalse);
    });

    test('WhatsApp digits', () {
      expect(whatsAppDigits('01012345678'), '201012345678');
      expect(whatsAppDigits('+201012345678'), '201012345678');
      expect(whatsAppDigits(null), isNull);
      expect(whatsAppDigits('  '), isNull);
      // A 3-digit garbage number must not produce a wa.me link.
      expect(whatsAppDigits('123'), isNull);
    });
  });

  group('Register full name', () {
    test('Latin names pass, short/empty fail', () {
      expect(Validators.personFullName(l10n, 'Ahmed Taha'), isNull);
      expect(Validators.personFullName(l10n, 'Al'), isNotNull);
      expect(Validators.personFullName(l10n, '   '), isNotNull);
      expect(Validators.personFullName(l10n, 'Ahmed123'), isNotNull);
    });

    test('Arabic names are accepted (Egypt-first app)', () {
      expect(Validators.personFullName(l10n, 'أحمد طه'), isNull);
    });

    test('hyphen / apostrophe names are accepted', () {
      expect(Validators.personFullName(l10n, 'Abd-El Rahman'), isNull);
      expect(Validators.personFullName(l10n, "O'Neil Smith"), isNull);
    });
  });

  group('Email', () {
    test('basic valid / invalid', () {
      expect(Validators.registerEmail(l10n, 'a@b.co'), isNull);
      expect(Validators.registerEmail(l10n, '  a@b.co  '), isNull);
      expect(Validators.registerEmail(l10n, ''), isNotNull);
      expect(Validators.registerEmail(l10n, 'a@b'), isNotNull);
      expect(Validators.registerEmail(l10n, '@b.co'), isNotNull);
    });

    test('whitespace inside the address is rejected', () {
      expect(Validators.registerEmail(l10n, 'ahmed taha@gmail.com'), isNotNull);
      expect(Validators.registerEmail(l10n, 'ahmed@gmail.com x'), isNotNull);
    });

    test('empty domain label is rejected', () {
      expect(Validators.registerEmail(l10n, 'a@b..com'), isNotNull);
    });
  });

  group('Passwords', () {
    test('register complexity rules', () {
      expect(Validators.registerPassword(l10n, 'P@ssw0rd'), isNull);
      expect(Validators.registerPassword(l10n, 'P@ss0r'), isNotNull); // <8
      expect(Validators.registerPassword(l10n, 'password1!'), isNotNull);
      expect(Validators.registerPassword(l10n, 'PASSWORD1!'), isNotNull);
      expect(Validators.registerPassword(l10n, 'Password!!'), isNotNull);
      expect(Validators.registerPassword(l10n, 'Password11'), isNotNull);
    });

    test('login password min length', () {
      expect(Validators.loginPassword(l10n, ''), isNotNull);
      expect(Validators.loginPassword(l10n, '12345'), isNotNull);
      expect(Validators.loginPassword(l10n, '123456'), isNull);
    });

    test('confirm password', () {
      expect(Validators.confirmPasswordMatches(l10n, 'a', 'a'), isNull);
      expect(Validators.confirmPasswordMatches(l10n, 'a', 'A'), isNotNull);
    });
  });

  group('Birth date / minimum age', () {
    final now = DateTime(2026, 9, 24);

    test('future dates rejected, today allowed', () {
      expect(Validators.dateOfBirth(l10n, DateTime(2026, 9, 25), now: now),
          isNotNull);
      expect(Validators.dateOfBirth(l10n, now, now: now), isNull);
      expect(Validators.dateOfBirth(l10n, null, now: now), isNull);
    });

    test('exactly 18 today passes', () {
      expect(
        Validators.dateOfBirth(l10n, DateTime(2008, 9, 24),
            now: now, enforceMinimumAge: true),
        isNull,
      );
    });

    test('18th birthday is TOMORROW → still 17, must be rejected', () {
      expect(
        Validators.dateOfBirth(l10n, DateTime(2008, 9, 25),
            now: now, enforceMinimumAge: true),
        isNotNull,
      );
    });

    test('18th birthday in 3 days → must be rejected', () {
      expect(
        Validators.dateOfBirth(l10n, DateTime(2008, 9, 27),
            now: now, enforceMinimumAge: true),
        isNotNull,
      );
    });

    test('picker initial date clamps into range', () {
      final first = DateTime(1900);
      expect(
        Validators.clampBirthDatePickerInitial(DateTime(2100),
            fallback: DateTime(2000), firstDate: first, now: now),
        DateTime(2026, 9, 24),
      );
      expect(
        Validators.clampBirthDatePickerInitial(DateTime(1800),
            fallback: DateTime(2000), firstDate: first, now: now),
        first,
      );
    });
  });

  group('Money input', () {
    test('plain & thousands separators', () {
      expect(Validators.parseMoneyInput('100'), 100);
      expect(Validators.parseMoneyInput('1,000'), 1000);
      expect(Validators.parseMoneyInput('99.5'), 99.5);
      expect(Validators.parseMoneyInput(''), isNull);
      expect(Validators.parseMoneyInput('abc'), isNull);
    });

    test('NaN / Infinity are not valid money', () {
      final nan = Validators.parseMoneyInput('NaN');
      final inf = Validators.parseMoneyInput('Infinity');
      expect(nan == null || nan.isFinite, isTrue, reason: 'NaN accepted');
      expect(inf == null || inf.isFinite, isTrue, reason: 'Infinity accepted');
    });

    test('Arabic-Indic digits parse (Arabic keyboard)', () {
      expect(Validators.parseMoneyInput('١٥٠'), 150);
    });
  });

  group('Listing form validation', () {
    ListingFormValidationInput input({
      List<String> photos = const ['a.jpg'],
      String name = 'iPhone 13',
      String price = '1000',
      String compareAt = '',
      String desc = 'Good phone',
      String cat = '1',
      String sub = '2',
      String cond = 'new',
      int qty = 1,
      String loc = 'Cairo',
      bool ship = false,
      String shipCost = '',
      int existing = 0,
    }) =>
        ListingFormValidationInput(
          photoPaths: photos,
          name: name,
          priceInput: price,
          compareAtPriceInput: compareAt,
          description: desc,
          categoryId: cat,
          subcategoryId: sub,
          condition: cond,
          quantity: qty,
          location: loc,
          shippingAvailable: ship,
          shippingCostInput: shipCost,
          existingPhotoCount: existing,
        );

    test('valid form has no errors (both APIs agree)', () {
      final i = input();
      expect(Validators.listingFormHasErrors(i), isFalse);
      expect(Validators.listingFormErrors(l10n, i), isEmpty);
    });

    test('every required field is enforced', () {
      final cases = <String, ListingFormValidationInput>{
        'photos': input(photos: const []),
        'name': input(name: '  '),
        'price': input(price: '0'),
        'description': input(desc: ''),
        'category': input(cat: '', sub: ''),
        'subcategory': input(sub: ''),
        'condition': input(cond: ''),
        'quantity': input(qty: 0),
        'location': input(loc: ' '),
        'shippingCost': input(ship: true, shipCost: ''),
      };
      cases.forEach((key, i) {
        expect(Validators.listingFormHasErrors(i), isTrue, reason: key);
        expect(Validators.listingFormErrors(l10n, i), contains(key),
            reason: key);
      });
    });

    test('boundaries: name 100 ok / 101 fails, description 1000 / 1001', () {
      expect(Validators.listingFormHasErrors(input(name: 'a' * 100)), isFalse);
      expect(Validators.listingFormHasErrors(input(name: 'a' * 101)), isTrue);
      expect(Validators.listingFormHasErrors(input(desc: 'a' * 1000)), isFalse);
      expect(Validators.listingFormHasErrors(input(desc: 'a' * 1001)), isTrue);
    });

    test('existing remote photos satisfy the photo requirement', () {
      expect(
        Validators.listingFormHasErrors(input(photos: const [], existing: 2)),
        isFalse,
      );
    });

    test('compare-at must be strictly greater than price', () {
      expect(Validators.listingFormHasErrors(input(compareAt: '1000')), isTrue);
      expect(Validators.listingFormHasErrors(input(compareAt: '999')), isTrue);
      expect(Validators.listingFormHasErrors(input(compareAt: '1001')), isFalse);
    });

    test('negative price / negative shipping rejected, free shipping ok', () {
      expect(Validators.listingFormHasErrors(input(price: '-5')), isTrue);
      expect(
        Validators.listingFormHasErrors(input(ship: true, shipCost: '-1')),
        isTrue,
      );
      expect(
        Validators.listingFormHasErrors(input(ship: true, shipCost: '0')),
        isFalse,
      );
    });

    test('NaN price must not pass validation', () {
      expect(Validators.listingFormHasErrors(input(price: 'NaN')), isTrue);
    });
  });

  group('JWT user id', () {
    String jwt(String payloadJson) {
      String b64(String s) => base64Url
          .encode(s.codeUnits)
          .replaceAll('=', '');
      return '${b64('{"alg":"none"}')}.${b64(payloadJson)}.sig';
    }

    test('reads sub / nameid / ms claim', () {
      expect(userIdFromJwt(jwt('{"sub":"42"}')), '42');
      expect(userIdFromJwt(jwt('{"nameid":7}')), '7');
      expect(
        userIdFromJwt(jwt(
          '{"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier":"9"}',
        )),
        '9',
      );
    });

    test('garbage tokens return null instead of throwing', () {
      expect(userIdFromJwt(null), isNull);
      expect(userIdFromJwt(''), isNull);
      expect(userIdFromJwt('abc'), isNull);
      expect(userIdFromJwt('a.%%%.c'), isNull);
      expect(userIdFromJwt(jwt('[1,2]')), isNull);
      expect(userIdFromJwt(jwt('{"sub":"  "}')), isNull);
    });
  });
}
