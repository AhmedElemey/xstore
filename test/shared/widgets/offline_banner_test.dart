import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/connectivity_provider.dart';
import 'package:xstore/shared/widgets/offline_banner.dart';

void main() {
  testWidgets(
    'toggling online keeps the navigator Expanded mounted',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => OfflineBannerHost(
              child: child ?? const SizedBox.shrink(),
            ),
            home: const Scaffold(
              body: Text('body', key: Key('body')),
            ),
          ),
        ),
      );
      await tester.pump();

      final bodyKey = find.byKey(const ValueKey<String>('app-body'));
      expect(bodyKey, findsOneWidget);
      final bodyElementId = identityHashCode(tester.element(bodyKey));

      container.read(isOnlineProvider.notifier).debugSetOnline(false);
      await tester.pump();

      expect(find.text('No internet connection. Please try again.'), findsOneWidget);
      expect(find.byKey(const Key('body')), findsOneWidget);
      expect(identityHashCode(tester.element(bodyKey)), bodyElementId);

      container.read(isOnlineProvider.notifier).debugSetOnline(true);
      await tester.pump();

      expect(find.text('No internet connection. Please try again.'), findsNothing);
      expect(find.byKey(const Key('body')), findsOneWidget);
      expect(identityHashCode(tester.element(bodyKey)), bodyElementId);
    },
  );
}
