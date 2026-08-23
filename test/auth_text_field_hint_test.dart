import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:xstore/core/theme/app_theme.dart';
import 'package:xstore/features/auth/presentation/widgets/auth_text_field.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) {
      final scaler = MediaQuery.textScalerOf(context);
      return Theme(
        data: AppTheme.withScaledTextSpacing(Theme.of(context), scaler),
        child: child!,
      );
    },
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('email and password hints have a visible slot on a phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(
        child: ListView(
          children: const [
            AuthTextField(
              label: 'Email Address *',
              hint: 'you@email.com',
              prefixIcon: Icon(LucideIcons.mail),
            ),
            SizedBox(height: 16),
            AuthTextField(
              label: 'Password *',
              hint: 'visible-hint-xyz',
              obscureText: true,
              prefixIcon: Icon(LucideIcons.lock),
              suffixIcon: IconButton(
                onPressed: null,
                icon: Icon(LucideIcons.eye),
              ),
            ),
          ],
        ),
      ),
    );

    for (final text in ['you@email.com', 'visible-hint-xyz']) {
      final hintFinder = find.text(text);
      expect(hintFinder, findsOneWidget, reason: text);

      final opacity = tester.widget<AnimatedOpacity>(
        find
            .ancestor(
              of: hintFinder,
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      expect(opacity.opacity, 1.0, reason: text);

      final hintRect = tester.getRect(hintFinder);
      expect(hintRect.width, greaterThan(80), reason: text);
      expect(hintRect.height, greaterThan(10), reason: text);

      final field = find.ancestor(
        of: hintFinder,
        matching: find.byType(TextFormField),
      );
      expect(tester.getRect(field).overlaps(hintRect), isTrue, reason: text);
    }
  });
}
