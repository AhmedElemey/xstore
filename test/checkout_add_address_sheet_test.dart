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

  Future<void> _pumpSection(
    WidgetTester tester, {
    String phoneNumber = '01012345678',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _FakeAuth(
              UserEntity(
                id: 'consumer_1',
                name: 'Jane Doe',
                email: 'buyer@test.com',
                phoneNumber: phoneNumber,
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
  }

  Future<void> _openAddSheet(WidgetTester tester) async {
    await tester.tap(find.text('+ Add New Address'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  FilledButton _saveButton(WidgetTester tester) {
    return tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save Address'),
    );
  }

  testWidgets(
    'saving a new address does not use disposed controllers during sheet exit',
    (tester) async {
      await _pumpSection(tester);
      await _openAddSheet(tester);

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

  testWidgets(
    'add-address Save stays dimmed until the phone matches Egypt regex',
    (tester) async {
      await _pumpSection(tester, phoneNumber: '');
      await _openAddSheet(tester);

      expect(_saveButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), '010');
      await tester.pump();
      expect(_saveButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), '01712345678');
      await tester.pump();
      expect(_saveButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), '01112345678');
      await tester.pump();
      expect(_saveButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets(
    'edit-address Save stays dimmed until a field changes and phone stays valid',
    (tester) async {
      await _pumpSection(tester);
      await _openAddSheet(tester);

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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(_saveButton(tester).onPressed, isNull);

      await tester.enterText(
        find.widgetWithText(TextField, 'Street'),
        '2 Nile St',
      );
      await tester.pump();
      expect(_saveButton(tester).onPressed, isNotNull);

      await tester.enterText(find.byType(TextFormField), '010');
      await tester.pump();
      expect(_saveButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), '01212345678');
      await tester.pump();
      expect(_saveButton(tester).onPressed, isNotNull);
    },
  );
}
