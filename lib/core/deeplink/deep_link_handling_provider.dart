import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../analytics/event_names.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/guest_mode_provider.dart';
import '../firebase/fcm_push_navigation.dart';
import '../router/app_router.dart';
import '../router/app_routes.dart';
import 'deep_link_route.dart';

/// Watched once from [XstoreApp] alongside `fcmPushHandlingProvider` — both
/// resolve an external trigger (a tapped link, a tapped push) to a
/// go_router path and are the single place each kind of trigger is wired.
/// See [openDeepLinkRoute] for how each resolved route is opened.
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
      ref.read(analyticsServiceProvider).track(
        AnalyticsEvents.deepLinkOpened,
        properties: {AnalyticsProps.screenName: route},
      );
      unawaited(openDeepLinkRoute(ref, route));
    },
    onError: (Object error) {
      if (kDebugMode) debugPrint('Deep link stream error: $error');
    },
  );

  ref.onDispose(() => unawaited(subscription.cancel()));
});

/// Guest-browsable links (product, seller, category — see
/// `isGuestAccessibleRoute`) open right away. A signed-out user who never
/// chose guest mode (e.g. a fresh install) is put into guest mode first,
/// so the router redirect doesn't send them to login and lose the link.
/// Account-bound links (order) are staged behind login via the same
/// `navigateToPushRoute`/`pendingPushRouteProvider` path push taps use.
Future<void> openDeepLinkRoute(Ref ref, String route) async {
  if (!isGuestAccessibleRoute(Uri.parse(route).path)) {
    return navigateToPushRoute(ref, route);
  }
  // Cold start: wait for the session restore before deciding.
  try {
    await ref.read(authProvider.future);
  } catch (_) {
    // A failed restore reads as signed out below.
  }
  if (ref.read(authProvider).valueOrNull == null) {
    await ref.read(guestModeProvider.notifier).enable();
  }
  ref.read(goRouterProvider).go(route);
}
