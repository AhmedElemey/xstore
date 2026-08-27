import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/auth/data/models/user_model.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';

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

    test('reads birthDate as dateOfBirth (calendar date, not timezone-shifted)', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'c@test.com',
        'birthDate': '1990-05-15T00:00:00.000Z',
      });
      expect(model.dateOfBirth, DateTime(1990, 5, 15));
    });

    test('reads date-only birthDate wire format', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'c@test.com',
        'birthDate': '1990-03-20',
      });
      expect(model.dateOfBirth, DateTime(1990, 3, 20));
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

    test('empty legacy storeDescription falls through to storeDescriptionEn', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'storeDescription': '',
        'storeDescriptionEn': 'English description',
      });
      expect(model.storeDescription, 'English description');
    });

    test('reads storeDescriptionEn then storeDescriptionAr when legacy absent', () {
      final en = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'storeDescriptionEn': 'About our shop',
      });
      expect(en.storeDescription, 'About our shop');

      final ar = UserModel.fromJson({
        'id': 2,
        'email': 'v2@test.com',
        'storeDescriptionAr': 'وصف المتجر',
      });
      expect(ar.storeDescription, 'وصف المتجر');
    });

    test('prefers storeDescriptionEn over legacy storeDescription when all set', () {
      final model = UserModel.fromJson({
        'id': 1,
        'email': 'v@test.com',
        'storeDescription': 'Legacy desc',
        'storeDescriptionEn': 'Updated desc',
        'storeDescriptionAr': 'وصف',
      });
      expect(model.storeDescription, 'Updated desc');
      expect(model.storeDescriptionEn, 'Updated desc');
      expect(model.storeDescriptionAr, 'وصف');
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

  group('parseProfileResponse', () {
    test('unwraps live get-profile wrapper shape', () {
      final wire = parseProfileResponse({
        'user': {
          'id': 22,
          'email': 'probe@test.local',
          'fullNameEn': 'Probe User',
        },
        'store': null,
        'isEmailVerificationRequired': true,
      });
      expect(wire.userJson['id'], 22);
      expect(wire.userJson['email'], 'probe@test.local');
      expect(wire.isEmailVerificationRequired, isTrue);
      expect(wire.hasStore, isFalse);
    });

    test('reads isEmailVerified/isPhoneVerified as top-level flags, not nested under user', () {
      // Exact shape of a real GET /api/auth/get-profile response (captured
      // live 2026-08-27) — isEmailVerified/isPhoneVerified sit alongside
      // `user`/`store`, not inside `user`.
      final wire = parseProfileResponse({
        'user': {
          'id': 42,
          'fullName': 'Ahmed taha',
          'email': 'rehab.mhmd2@gmail.com',
          'phoneNumber': '01019890452',
        },
        'store': null,
        'isEmailVerified': true,
        'isPhoneVerified': false,
      });
      expect(wire.isEmailVerified, isTrue);
      expect(wire.isPhoneNumberVerified, isFalse);
      // Confirms it's NOT read from the user object itself.
      expect(wire.userJson.containsKey('isEmailVerified'), isFalse);
    });

    test('merges nested store object onto user fields', () {
      final model = userModelFromProfileResponse({
        'user': {
          'fullNameEn': 'Updated Name',
          'fullNameAr': 'الاسم المحدث',
          'email': 'vendor@test.com',
          'phoneNumber': '01112345678',
          'avatarUrl':
              'http://example.com/uploads/avatars/e4a956c2-3804-4465-9c1f-ef8ab35d0714.jpg',
          'birthDate': '1985-05-15T00:00:00',
          'creationDate': '2026-07-13T01:03:04.7636173',
        },
        'store': {
          'id': 1,
          'nameEn': 'Store Name Updated',
          'nameAr': 'اسم المتجر المعدل',
          'descriptionEn': 'Store Description Updated',
          'descriptionAr': 'وصف المتجر المعدل',
          'whatsAppNumber': '01012345677',
          'cityId': 2,
          'governorateId': 2,
          'storeCategoryId': 2,
          'storeLogoUrl':
              'http://example.com/uploads/avatars/65db2fb1-66ae-412b-8892-9d5f6e0a8e6f.jpg',
          'storeCategoryNameEn': 'Fashion',
          'storeCategoryNameAr': 'أزياء',
          'instagramPage': 'https://instagram.com/store1',
          'facebookPage': 'https://facebook.com/store1',
          'lat': 5.221,
          'lng': 6.213,
          'detailedAddressByGoogleMaps': '123 Main St, Cairo, Egypt',
          'detailedAddressByUser': '456 User Rd, Apt 7',
          'cityByGoogleMaps': 'Cairo',
          'governmentByGoogleMaps': 'Cairo Governorate',
        },
        'isEmailVerificationRequired': false,
        'isPhoneVerificationRequired': false,
      });

      expect(model.name, 'Updated Name');
      expect(model.fullNameAr, 'الاسم المحدث');
      expect(model.storeId, 1);
      expect(model.storeNameEn, 'Store Name Updated');
      expect(model.storeName, 'Store Name Updated');
      expect(model.storeDescriptionEn, 'Store Description Updated');
      expect(model.storeDescription, 'Store Description Updated');
      expect(model.storeDescriptionAr, 'وصف المتجر المعدل');
      expect(model.whatsappNumber, '01012345677');
      expect(model.storeCityId, 2);
      expect(model.storeGovernmentId, 2);
      expect(model.storeCategoryId, 2);
      expect(model.storeLogoUrl, contains('65db2fb1'));
      expect(model.storeCategory, 'Fashion');
      expect(model.instagramHandle, 'https://instagram.com/store1');
      expect(model.facebookPage, 'https://facebook.com/store1');
      expect(model.latitude, 5.221);
      expect(model.longitude, 6.213);
      expect(model.location, '123 Main St, Cairo, Egypt');
      expect(model.detailAddress, '456 User Rd, Apt 7');
      expect(model.town, 'Cairo');
      expect(model.governorate, 'Cairo Governorate');
      expect(model.role, UserRole.vendor);
      expect(model.storeId, isNotNull);
    });

    test('still reads legacy governmentId when governorateId is absent', () {
      final model = UserModel.fromJson({
        'id': 22,
        'email': 'buyer@test.com',
        'cityId': 1,
        'governmentId': 16,
      });
      expect(model.storeCityId, 1);
      expect(model.storeGovernmentId, 16);
    });

    test('reads nested city/government on the user (consumer register)', () {
      final model = userModelFromProfileResponse({
        'user': {
          'id': 22,
          'email': 'buyer@test.com',
          'fullName': 'Buyer',
          'cityId': 1,
          'governorateId': 16,
          'city': {
            'id': 1,
            'nameEn': 'Nasr City',
            'nameAr': 'مدينة نصر',
          },
          'government': {
            'id': 16,
            'nameEn': 'Cairo',
            'nameAr': 'القاهرة',
          },
        },
        'store': null,
      });

      expect(model.storeCityId, 1);
      expect(model.storeGovernmentId, 16);
      expect(model.storeCity, 'Nasr City');
      expect(model.storeWilaya, 'Cairo');
    });

    test('reads nested city/government on the store when ids are omitted', () {
      final model = userModelFromProfileResponse({
        'user': {
          'email': 'vendor@test.com',
          'fullName': 'Vendor',
        },
        'store': {
          'id': 1,
          'city': {
            'id': 2,
            'nameEn': 'Alexandria City',
            'nameAr': 'مدينة الإسكندرية',
          },
          'government': {
            'id': 15,
            'nameEn': 'Alexandria',
            'nameAr': 'الإسكندرية',
          },
        },
      });

      expect(model.storeCityId, 2);
      expect(model.storeGovernmentId, 15);
      expect(model.storeCity, 'Alexandria City');
      expect(model.storeWilaya, 'Alexandria');
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
        () => parseProfileResponse({'store': null}),
        throwsFormatException,
      );
    });
  });
}
