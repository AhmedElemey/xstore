import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:xstore/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:xstore/features/profile/domain/entities/profile_entity.dart';
import 'package:xstore/features/profile/domain/entities/update_profile_request.dart';
import 'package:xstore/features/profile/presentation/providers/profile_state.dart';

// UserModel.fromJson wire-alias coverage (storeName precedence, whatsApp/
// instagram aliases) lives in test/user_model_profile_wire_test.dart.
void main() {
  group('UserEntity.displayStoreName', () {
    const entity = UserEntity(
      id: '1',
      name: 'Vendor',
      email: 'v@test.com',
      phoneNumber: '010',
      storeName: 'Legacy',
      storeNameEn: 'English Shop',
      storeNameAr: 'متجر',
    );

    test('returns Arabic when isArabic is true', () {
      expect(entity.displayStoreName(true), 'متجر');
    });

    test('returns English when isArabic is false', () {
      expect(entity.displayStoreName(false), 'English Shop');
    });

    test('falls back to legacy storeName when locale field is absent', () {
      const legacyOnly = UserEntity(
        id: '2',
        name: 'Vendor',
        email: 'v2@test.com',
        phoneNumber: '010',
        storeName: 'Legacy Only',
      );
      expect(legacyOnly.displayStoreName(true), 'Legacy Only');
      expect(legacyOnly.displayStoreName(false), 'Legacy Only');
    });
  });

  group('updateProfileWireFields', () {
    test('sends userImageUrl null when avatar removal is requested', () {
      const user = UserEntity(
        id: '1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '010',
        avatarUrl: 'https://cdn.example/avatar.jpg',
        storeLogoUrl: 'https://cdn.example/store.jpg',
      );
      final state = ProfileState(
        profile: ProfileEntity(user: user),
        avatarRemoved: true,
      );

      final body = updateProfileWireFields(state.toUpdateProfileRequest());

      expect(body.containsKey('userImageUrl'), isTrue);
      expect(body['userImageUrl'], isNull);
      expect(body['storeImageUrl'], 'https://cdn.example/store.jpg');
      expect(body.containsKey('email'), isFalse);
      expect(body.containsKey('phoneNumber'), isFalse);
    });

    test('sends storeImageUrl null when store logo removal is requested', () {
      const user = UserEntity(
        id: '1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '010',
        storeLogoUrl: 'https://cdn.example/store.jpg',
        storeId: 1,
      );
      final state = ProfileState(
        profile: ProfileEntity(user: user),
        storeLogoRemoved: true,
      );

      final body = updateProfileWireFields(state.toUpdateProfileRequest());

      expect(body.containsKey('storeImageUrl'), isTrue);
      expect(body['storeImageUrl'], isNull);
    });

    test('maps edit state to UpdateProfileRequest wire keys', () {
      const user = UserEntity(
        id: '1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '010',
        role: UserRole.vendor,
        storeCategoryId: 3,
        storeCityId: 10,
        storeGovernmentId: 2,
      );
      final state = ProfileState(
        profile: ProfileEntity(user: user),
        editName: 'Ahmed',
        editFullNameAr: 'أحمد',
        editLocation: '12 Abbas El Akkad, Nasr City',
        editDetailAddress: 'Building 5, floor 2',
        editTown: 'Nasr City',
        editGovernorate: 'Cairo',
        editLatitude: '30.044400',
        editLongitude: '31.235700',
        editDateOfBirth: DateTime(1990, 3, 20),
        editStoreName: 'Tech Hub',
        editWhatsapp: '01012345678',
        editInstagram: 'techhub',
        editFacebook: 'techhub.eg',
      );

      final body = updateProfileWireFields(state.toUpdateProfileRequest());

      expect(body['fullNameEn'], 'Ahmed');
      expect(body['fullNameAr'], 'أحمد');
      expect(body['storeNameEn'], 'Tech Hub');
      expect(body['detailedAddressByGoogleMaps'], '12 Abbas El Akkad, Nasr City');
      expect(body['detailedAddressByUser'], 'Building 5, floor 2');
      expect(body['cityByGoogleMaps'], 'Nasr City');
      expect(body['governmentByGoogleMaps'], 'Cairo');
      expect(body['lat'], closeTo(30.0444, 0.0001));
      expect(body['lng'], closeTo(31.2357, 0.0001));
      expect(body['storeCategoryId'], 3);
      expect(body['cityId'], 10);
      expect(body['governmentId'], 2);
      expect(body['birthDate'], '1990-03-20');
      expect(body['whatsAppNumber'], '01012345678');
      expect(body['instagramPage'], 'techhub');
      expect(body['facebookPage'], 'techhub.eg');
    });
  });

  group('mock profile save → fetch round-trip', () {
    test(
      'location and profile fields survive updateProfile then getProfile',
      () async {
        final ds = ProfileRemoteDataSourceImpl(Dio());
        final repo = ProfileRepositoryImpl(ds);

        const session = UserEntity(
          id: 'vendor_1',
          name: 'Ahmed Vendor',
          email: 'vendor@test.com',
          phoneNumber: '01012345678',
          role: UserRole.vendor,
        );

        final request = UpdateProfileRequest(
          fullNameEn: 'Ahmed Vendor',
          fullNameAr: 'أحمد',
          storeNameEn: 'Tech Hub',
          storeNameAr: 'متجر',
          storeDescriptionEn: 'Electronics seller',
          detailedAddressByGoogleMaps: '12 Abbas El Akkad',
          detailedAddressByUser: '12 Abbas El Akkad',
          cityByGoogleMaps: 'Nasr City',
          governmentByGoogleMaps: 'Cairo',
          lat: 30.0444,
          lng: 31.2357,
          storeCategoryId: 1,
          birthDate: DateTime.parse('1990-03-20'),
        );

        final saveResult =
            await repo.updateProfile(request, sessionUser: session);
        expect(saveResult.isRight(), isTrue);
        final saved = saveResult.getOrElse((_) => session);

        final fetchResult = await repo.getProfile(saved);
        expect(fetchResult.isRight(), isTrue);
        final profile = fetchResult.getOrElse(
          (_) => throw StateError('expected profile'),
        );
        final u = profile.user;

        expect(u.location, '12 Abbas El Akkad');
        expect(u.detailAddress, '12 Abbas El Akkad');
        expect(u.dateOfBirth, DateTime.parse('1990-03-20'));
        expect(u.storeCity, isNull);
        expect(u.town, 'Nasr City');
        expect(u.governorate, 'Cairo');
        expect(u.latitude, 30.0444);
        expect(u.longitude, 31.2357);
        expect(u.storeNameEn, 'Tech Hub');
        expect(u.storeNameAr, 'متجر');
      },
      skip: MockConfig.useMock ? false : 'Requires --dart-define=MOCK=true',
    );
  });
}
