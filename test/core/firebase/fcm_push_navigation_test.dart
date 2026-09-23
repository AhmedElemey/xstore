import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:xstore/core/firebase/fcm_push_navigation.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/core/router/app_router.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/pending_push_route_provider.dart';

/// Auth whose session restore finishes when the test says so.
class _PendingAuth extends Auth {
  _PendingAuth(this._restore);
  final Completer<UserEntity?> _restore;
  @override
  Future<UserEntity?> build() => _restore.future;
}

final _refProvider = Provider<Ref>((ref) => ref);

// Not an inbox route, so no notifications refetch is triggered.
const _target = '/cart';

GoRouter _router() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
        GoRoute(path: _target, builder: (_, __) => const SizedBox()),
      ],
    );

String _location(GoRouter router) =>
    router.routeInformationProvider.value.uri.toString();

ProviderContainer _container(Completer<UserEntity?> restore, GoRouter router) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => _PendingAuth(restore)),
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

  test('signed in: opens the route', () async {
    final restore = Completer<UserEntity?>()..complete(mockConsumerUser);
    final router = _router();
    final container = _container(restore, router);
    await container.read(authProvider.future);

    await navigateToPushRoute(container.read(_refProvider), _target);

    expect(_location(router), _target);
    expect(container.read(pendingPushRouteProvider), isNull);
  });

  test(
      'cold start: waits for the session restore, then opens the route '
      '(no route lost when the restore finishes first or last)', () async {
    final restore = Completer<UserEntity?>();
    final router = _router();
    final container = _container(restore, router);

    final opening = navigateToPushRoute(container.read(_refProvider), _target);
    restore.complete(mockConsumerUser);
    await opening;

    expect(_location(router), _target);
  });

  test('signed out: stages the route behind login instead of opening it',
      () async {
    final restore = Completer<UserEntity?>()..complete(null);
    final router = _router();
    final container = _container(restore, router);
    await container.read(authProvider.future);

    await navigateToPushRoute(container.read(_refProvider), _target);

    expect(_location(router), '/');
    expect(container.read(pendingPushRouteProvider), _target);

    flushPendingPushRoute(container.read(_refProvider));
    expect(_location(router), _target);
    expect(container.read(pendingPushRouteProvider), isNull);
  });

  test('ignores a payload route that is not an in-app path', () async {
    final restore = Completer<UserEntity?>()..complete(mockConsumerUser);
    final router = _router();
    final container = _container(restore, router);
    await container.read(authProvider.future);

    await navigateToPushRoute(
      container.read(_refProvider),
      'https://evil.example/phish',
    );

    expect(_location(router), '/');
    expect(container.read(pendingPushRouteProvider), isNull);
  });
}
