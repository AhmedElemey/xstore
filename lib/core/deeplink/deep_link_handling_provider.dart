import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import 'deep_link_route.dart';

/// Watched once from [XstoreApp] alongside `fcmPushHandlingProvider` — both
/// resolve an external trigger (a tapped link, a tapped push) to a
/// go_router path and are the single place each kind of trigger is wired.
/// Product links are guest-accessible (see `isGuestAccessibleRoute`), so
/// unlike push taps they navigate immediately rather than staging behind
/// login via `navigateToPushRoute`/`pendingPushRouteProvider`.
///
/// Kept alive (not autoDispose): the incoming-link stream must keep
/// listening for the app's whole lifetime.
final deepLinkHandlingProvider = Provider<void>((ref) {
  // app_links' own docs: subscribing to uriLinkStream alone (instantiated
  // early, as this keepAlive provider is) catches both the cold-start link
  // and links tapped while running — no separate getInitialLink() call.
  final subscription = AppLinks().uriLinkStream.listen(
    (uri) {
      final route = routeFromDeepLinkUri(uri);
      if (route == null) return;
      ref.read(goRouterProvider).go(route);
    },
    onError: (Object error) {
      if (kDebugMode) debugPrint('Deep link stream error: $error');
    },
  );

  ref.onDispose(() => unawaited(subscription.cancel()));
});
