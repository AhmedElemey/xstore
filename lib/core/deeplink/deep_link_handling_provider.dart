import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/fcm_push_navigation.dart';
import '../router/app_router.dart';
import '../router/app_routes.dart';
import 'deep_link_route.dart';

/// Watched once from [XstoreApp] alongside `fcmPushHandlingProvider` — both
/// resolve an external trigger (a tapped link, a tapped push) to a
/// go_router path and are the single place each kind of trigger is wired.
/// Guest-accessible links (product, seller, category — see
/// `isGuestAccessibleRoute`) navigate immediately; account-bound links
/// (order) are staged behind login via the same
/// `navigateToPushRoute`/`pendingPushRouteProvider` mechanism push taps use.
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
      if (isGuestAccessibleRoute(Uri.parse(route).path)) {
        ref.read(goRouterProvider).go(route);
      } else {
        unawaited(navigateToPushRoute(ref, route));
      }
    },
    onError: (Object error) {
      if (kDebugMode) debugPrint('Deep link stream error: $error');
    },
  );

  ref.onDispose(() => unawaited(subscription.cancel()));
});
