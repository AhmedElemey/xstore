import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/deeplink/deep_link_handling_provider.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/core/router/app_router.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/pending_push_route_provider.dart';

import '../../helpers/fake_async_auth_notifier.dart';

final _refProvider = Provider<Ref>((ref) => ref);

const _product = '/product/42';
const _order = '/order/7';

GoRouter _router() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
        GoRoute(path: _product, builder: (_, __) => const SizedBox()),
        GoRoute(path: _order, builder: (_, __) => const SizedBox()),
      ],
    );

String _location(GoRouter router) =>
    router.routeInformationProvider.value.uri.toString();

ProviderContainer _container(UserEntity? user, GoRouter router) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(user)),
      goRouterProvider.overrideWithValue(router),
    ],
  );
  addTearDown(container.dispose);
  container.listen(authProvider, (_, __) {});
  container.listen(pendingPushRouteProvider, (_, __) {});
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('first-time signed-out user: product link opens in guest mode',
      () async {
    final router = _router();
    final container = _container(null, router);
    // Fresh provider, built by the link itself: the initial prefs load
    // must not undo enable().
    container.listen(guestModeProvider, (_, __) {});

    await openDeepLinkRoute(container.read(_refProvider), _product);
    await Future<void>.delayed(Duration.zero);

    expect(_location(router), _product);
    expect(container.read(guestModeProvider), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('guest_mode'), isTrue);
  });

  test('signed-in user: product link opens without touching guest mode',
      () async {
    final router = _router();
    final container = _container(mockConsumerUser, router);

    await openDeepLinkRoute(container.read(_refProvider), _product);

    expect(_location(router), _product);
    expect(container.read(guestModeProvider), isFalse);
  });

  test('signed-out user: order link is staged behind login, not guest mode',
      () async {
    final router = _router();
    final container = _container(null, router);

    await openDeepLinkRoute(container.read(_refProvider), _order);

    expect(_location(router), '/');
    expect(container.read(pendingPushRouteProvider), _order);
    expect(container.read(guestModeProvider), isFalse);
  });
}
