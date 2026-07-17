import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xstore/features/auth/domain/entities/login_params.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';

void main() {
  group('mockLoginIsCourier', () {
    test('matches courier/driver identifiers, case-insensitive', () {
      expect(mockLoginIsCourier('driver@xstore.com'), true);
      expect(mockLoginIsCourier('mostafa.courier@xstore.com'), true);
      expect(mockLoginIsCourier('  DRIVER01  '), true);
      expect(mockLoginIsCourier('sara@gmail.com'), false);
      expect(mockLoginIsCourier('vendor@xstore.com'), false);
    });

    test("matches the mock courier's phone — the only form the phone-first "
        'login screen lets through', () {
      // As typed in the UI (local), normalized (what the notifier sends),
      // and full international — all must resolve to the courier.
      expect(mockLoginIsCourier('01055500003'), true);
      expect(mockLoginIsCourier('+20 105 550 0003'), true);
      expect(mockLoginIsCourier('1055500003'), true);
      // Consumer/vendor mock phones must not match.
      expect(mockLoginIsCourier('01255500002'), false);
      expect(mockLoginIsCourier('01055500001'), false);
    });

    test("vendor matcher picks up the mock vendor's phone", () {
      expect(mockLoginIsVendor('01055500001'), true);
      expect(mockLoginIsVendor('01055500003'), false);
    });
  });

  group('mock-mode login routes roles by identifier', () {
    final ds = AuthRemoteDataSourceImpl(Dio());

    LoginParams params(String id) =>
        LoginParams(emailOrPhone: id, password: 'anything');

    test('driver identifier signs in as courier', () async {
      final model = await ds.login(params('driver@xstore.com'));
      expect(model.role, UserRole.courier);
      expect(model.id, mockCourierUser.id);
      expect(model.token, isNotEmpty);
    });

    test('vendor identifier signs in as vendor', () async {
      final model = await ds.login(params('vendor@xstore.com'));
      expect(model.role, UserRole.vendor);
    });

    test('anything else signs in as consumer', () async {
      final model = await ds.login(params('sara@gmail.com'));
      expect(model.role, UserRole.consumer);
    });
  }, skip: MockConfig.useMock ? false : 'Requires --dart-define=MOCK=true');
}
