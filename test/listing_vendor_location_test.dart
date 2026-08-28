import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/listing/presentation/providers/listing_form_notifier.dart';

void main() {
  group('vendorListingLocation', () {
    test('null user is empty', () {
      expect(vendorListingLocation(null), '');
    });

    test('prefers Google address from the profile store object', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        location: '12 Tahrir Square, Cairo',
        detailAddress: 'Near the museum',
        storeCity: 'Giza',
        storeWilaya: 'Giza Governorate',
      );
      expect(vendorListingLocation(user), '12 Tahrir Square, Cairo');
    });

    test('falls back to user detailed address', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        detailAddress: 'Near the museum',
        storeCity: 'Giza',
      );
      expect(vendorListingLocation(user), 'Near the museum');
    });

    test('joins storeCity and storeWilaya when no address', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        storeCity: 'Giza',
        storeWilaya: 'Giza Governorate',
      );
      expect(vendorListingLocation(user), 'Giza, Giza Governorate');
    });

    test('falls back to storeWilaya when city is blank', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        storeCity: '  ',
        storeWilaya: 'Cairo Governorate',
      );
      expect(vendorListingLocation(user), 'Cairo Governorate');
    });

    test('empty when neither city nor governorate is set', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
      );
      expect(vendorListingLocation(user), '');
    });
  });

  group('vendorHasStoreLocation', () {
    test('false without coordinates', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        storeCity: 'Giza',
      );
      expect(vendorHasStoreLocation(user), isFalse);
      expect(vendorHasStoreLocation(null), isFalse);
    });

    test('true when profile store has lat and lng', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        latitude: 30.0444,
        longitude: 31.2357,
      );
      expect(vendorHasStoreLocation(user), isTrue);
    });
  });
}
