import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:xstore/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:xstore/features/profile/domain/entities/profile_entity.dart';
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

  group('updateProfileRequestBody', () {
    test('sends avatarUrl null when avatar removal is requested', () {
      const user = UserEntity(
        id: '1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '010',
        avatarUrl: 'https://cdn.example/avatar.jpg',
      );
      final state = ProfileState(
        profile: ProfileEntity(user: user),
        avatarRemoved: true,
      );

      final body = updateProfileRequestBody(state.toEditedUser());

      expect(body.containsKey('avatarUrl'), isTrue);
      expect(body['avatarUrl'], isNull);
    });
  });

  group('mock profile save → fetch round-trip', () {
    test(
      'location and profile fields survive updateProfile then getProfile',
      () async {
        final ds = ProfileRemoteDataSourceImpl(Dio());
        final repo = ProfileRepositoryImpl(ds);

        const dob = '1990-03-20T00:00:00.000';
        final updated = UserEntity(
          id: 'vendor_1',
          name: 'Ahmed Vendor',
          email: 'vendor@test.com',
          phoneNumber: '01012345678',
          role: UserRole.vendor,
          location: 'Cairo',
          bio: 'Electronics seller',
          dateOfBirth: DateTime.parse(dob),
          storeCategory: 'Electronics',
          storeCity: 'Cairo',
          storeWilaya: 'Cairo',
          latitude: 30.0444,
          longitude: 31.2357,
          governorate: 'Cairo',
          town: 'Nasr City',
          detailAddress: '12 Abbas El Akkad',
          fullNameEn: 'Ahmed Vendor',
          fullNameAr: 'أحمد',
          storeNameEn: 'Tech Hub',
          storeNameAr: 'متجر',
        );

        final saveResult = await repo.updateProfile(updated);
        expect(saveResult.isRight(), isTrue);
        final saved = saveResult.getOrElse((_) => updated);

        final fetchResult = await repo.getProfile(saved);
        expect(fetchResult.isRight(), isTrue);
        final profile = fetchResult.getOrElse(
          (_) => throw StateError('expected profile'),
        );
        final u = profile.user;

        expect(u.location, 'Cairo');
        expect(u.bio, 'Electronics seller');
        expect(u.dateOfBirth, DateTime.parse(dob));
        expect(u.storeCategory, 'Electronics');
        expect(u.storeCity, 'Cairo');
        expect(u.storeWilaya, 'Cairo');
        expect(u.latitude, 30.0444);
        expect(u.longitude, 31.2357);
        expect(u.governorate, 'Cairo');
        expect(u.town, 'Nasr City');
        expect(u.detailAddress, '12 Abbas El Akkad');
        expect(u.storeNameEn, 'Tech Hub');
        expect(u.storeNameAr, 'متجر');
      },
      skip: MockConfig.useMock ? false : 'Requires --dart-define=MOCK=true',
    );
  });
}
