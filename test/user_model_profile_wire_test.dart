import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson profile wire aliases', () {
    test('reads storeNameEn then storeNameAr when storeName is absent', () {
      final en = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'storeNameEn': 'Tech Hub',
      });
      expect(en.storeName, 'Tech Hub');

      final ar = UserModel.fromJson({
        'id': 2,
        'email': 'v2@test.com',
        'storeNameAr': 'متجر',
      });
      expect(ar.storeName, 'متجر');
    });

    test('reads whatsAppNumber and instagramPage write aliases on GET', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'whatsAppNumber': '01012345678',
        'instagramPage': 'techhub',
      });
      expect(model.whatsappNumber, '01012345678');
      expect(model.instagramHandle, 'techhub');
    });

    test('prefers canonical read keys over write aliases', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'whatsappNumber': '01011111111',
        'whatsAppNumber': '01022222222',
        'instagramHandle': 'handle',
        'instagramPage': 'page',
      });
      expect(model.whatsappNumber, '01011111111');
      expect(model.instagramHandle, 'handle');
    });

    test('reads birthDate as dateOfBirth', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'c@test.com',
        'birthDate': '1990-05-15T00:00:00.000Z',
      });
      expect(model.dateOfBirth, DateTime.parse('1990-05-15T00:00:00.000Z'));
    });

    test('prefers storeNameEn over legacy storeName when all are set', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'storeName': 'Legacy Name',
        'storeNameEn': 'English Shop',
        'storeNameAr': 'متجر',
      });
      expect(model.storeName, 'English Shop');
    });

    test('empty legacy storeName falls through to storeNameEn', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'storeName': '',
        'storeNameEn': 'English Shop',
      });
      expect(model.storeName, 'English Shop');
    });

    test('whitespace-only alias values are treated as absent', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'whatsappNumber': '   ',
        'whatsAppNumber': '01012345678',
        'instagramHandle': '',
        'instagramPage': 'techhub',
      });
      expect(model.whatsappNumber, '01012345678');
      expect(model.instagramHandle, 'techhub');
    });
  });

  group('parseProfileUserJson', () {
    test('unwraps live get-profile wrapper shape', () {
      final userJson = parseProfileUserJson({
        'user': {
          'id': 22,
          'email': 'probe@test.local',
          'fullNameEn': 'Probe User',
        },
        'store': null,
        'isEmailVerificationRequired': true,
      });
      expect(userJson['id'], 22);
      expect(userJson['email'], 'probe@test.local');
    });

    test('falls back to raw user object when wrapper is absent', () {
      final userJson = parseProfileUserJson({
        'id': 1,
        'email': 'legacy@test.local',
        'name': 'Legacy',
      });
      expect(userJson['email'], 'legacy@test.local');
    });

    test('throws when neither wrapper nor user fields are present', () {
      expect(
        () => parseProfileUserJson({'store': null}),
        throwsFormatException,
      );
    });
  });
}
