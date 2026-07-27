import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/core/router/router_notifier.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';

UserEntity _user(UserRole role) => UserEntity(
      id: 'u1',
      name: 'U',
      email: 'u@test.com',
      phoneNumber: '01000000000',
      role: role,
    );

String? _redirect(UserRole role, String location) => computeXStoreAuthRedirect(
      auth: AsyncValue.data(_user(role)),
      needsRoleSelection: false,
      matchedLocation: location,
    );

void main() {
  group('delivery-request routes are open to consumer AND vendor', () {
    for (final loc in [AppRoutes.sendPackage, AppRoutes.myPackages]) {
      test('consumer is allowed on $loc', () {
        expect(_redirect(UserRole.consumer, loc), isNull);
      });
      test('vendor is allowed on $loc', () {
        expect(_redirect(UserRole.vendor, loc), isNull);
      });
      test('courier is redirected away from $loc', () {
        expect(_redirect(UserRole.courier, loc), isNotNull);
      });
    }

    test('isRequesterRestrictedRoute covers only the request routes', () {
      expect(isRequesterRestrictedRoute(AppRoutes.sendPackage), isTrue);
      expect(isRequesterRestrictedRoute(AppRoutes.myPackages), isTrue);
      expect(isRequesterRestrictedRoute(AppRoutes.cart), isFalse);
      // No longer folded into the consumer-only shopping restriction.
      expect(isConsumerRestrictedRoute(AppRoutes.sendPackage), isFalse);
    });
  });
}
