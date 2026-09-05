import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/cart/presentation/widgets/checkout_address_section.dart';

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity _user;
  @override
  Future<UserEntity?> build() async => _user;
}

class _InertCart extends Cart {
  @override
  CartState build() => const CartState();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'saving a new address does not use disposed controllers during sheet exit',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _FakeAuth(
                const UserEntity(
                  id: 'consumer_1',
                  name: 'Jane Doe',
                  email: 'buyer@test.com',
                  phoneNumber: '01012345678',
                ),
              ),
            ),
            cartProvider.overrideWith(() => _InertCart()),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CheckoutAddressSection()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('+ Add New Address'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(
        find.widgetWithText(TextField, 'Street'),
        '1 Nile St',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'City'),
        'Maadi',
      );

      final save = find.text('Save Address');
      await tester.ensureVisible(save);
      await tester.tap(save);
      // The sheet future completes at Navigator.pop while the exit
      // animation still holds the TextFields — this frame used to throw
      // "A TextEditingController was used after being disposed".
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Jane Doe'), findsWidgets);
    },
  );
}
