import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/listing/presentation/providers/listing_form_notifier.dart';

void main() {
  group('vendorListingLocation', () {
    test('null user is empty', () {
      expect(vendorListingLocation(null), '');
    });

    test('prefers storeCity', () {
      const user = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        storeCity: 'Giza',
        storeWilaya: 'Giza Governorate',
      );
      expect(vendorListingLocation(user), 'Giza');
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
}
