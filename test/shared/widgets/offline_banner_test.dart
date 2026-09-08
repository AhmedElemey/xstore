import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/connectivity_provider.dart';
import 'package:xstore/shared/widgets/offline_banner.dart';

Widget _app({required ProviderContainer container, required Widget home}) {
  return UncontrolledProviderScope(
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
      home: home,
    ),
  );
}

void main() {
  testWidgets(
    'toggling online keeps Overlay and the route body mounted',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _app(
          container: container,
          home: const Scaffold(body: Text('body', key: Key('body'))),
        ),
      );
      await tester.pump();

      final body = find.byKey(const Key('body'));
      final overlay = find.byType(Overlay);
      expect(body, findsOneWidget);
      expect(overlay, findsOneWidget);
      final bodyId = identityHashCode(tester.element(body));
      final overlayId = identityHashCode(tester.element(overlay));

      container.read(isOnlineProvider.notifier).debugSetOnline(false);
      await tester.pump();

      expect(
        find.text('No internet connection. Please try again.'),
        findsOneWidget,
      );
      expect(identityHashCode(tester.element(body)), bodyId);
      expect(identityHashCode(tester.element(overlay)), overlayId);

      container.read(isOnlineProvider.notifier).debugSetOnline(true);
      await tester.pump();

      expect(
        find.text('No internet connection. Please try again.'),
        findsNothing,
      );
      expect(identityHashCode(tester.element(body)), bodyId);
      expect(identityHashCode(tester.element(overlay)), overlayId);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'toggling online with an open dialog does not assert _dependents.isEmpty',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _app(
          container: container,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const AlertDialog(
                      content: Text('dialog'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('dialog'), findsOneWidget);

      final overlayId = identityHashCode(tester.element(find.byType(Overlay)));

      container.read(isOnlineProvider.notifier).debugSetOnline(false);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('dialog'), findsOneWidget);
      expect(
        find.text('No internet connection. Please try again.'),
        findsOneWidget,
      );
      expect(
        identityHashCode(tester.element(find.byType(Overlay))),
        overlayId,
      );

      container.read(isOnlineProvider.notifier).debugSetOnline(true);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('dialog'), findsOneWidget);
      expect(
        identityHashCode(tester.element(find.byType(Overlay))),
        overlayId,
      );
    },
  );
}
