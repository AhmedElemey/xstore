import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wraps a shell-tab screen so its data refreshes when navigation re-enters
/// its route, not just on first mount.
///
/// [StatefulShellRoute.indexedStack] keeps every tab's widget tree (and any
/// `autoDispose`/`keepAlive` provider it watches) alive for the app's whole
/// session — `initState`'s one-shot fetch never runs again, so a tab left
/// stale by an action taken elsewhere (an order confirmed on another tab, a
/// listing published, a wishlist item added) stays stale until the app is
/// killed and restarted. This widget listens to the router directly (there is
/// no `didPush`-style hook for switching `IndexedStack` branches) and calls
/// [onReentry] the moment [isTarget] starts matching the current location
/// again, having previously not matched it.
///
/// Only fires on a genuine re-entry (this route was left and come back to),
/// not on the initial build — the screen's own `initState`/`build`-time fetch
/// already covers first mount.
class RouteReentryRefresh extends ConsumerStatefulWidget {
  const RouteReentryRefresh({
    super.key,
    required this.isTarget,
    required this.onReentry,
    required this.child,
  });

  /// Whether [location] (the router's current matched path) counts as
  /// "on this screen" for refresh purposes.
  final bool Function(String location) isTarget;

  /// Called when navigation re-enters a route [isTarget] matches, after
  /// having been on a different route.
  final void Function(WidgetRef ref) onReentry;

  final Widget child;

  @override
  ConsumerState<RouteReentryRefresh> createState() =>
      _RouteReentryRefreshState();
}

class _RouteReentryRefreshState extends ConsumerState<RouteReentryRefresh> {
  GoRouterDelegate? _delegate;
  var _onRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.maybeOf(context);
    final next = router?.routerDelegate;
    if (identical(next, _delegate)) return;
    _delegate?.removeListener(_onRouteChanged);
    _delegate = next;
    _delegate?.addListener(_onRouteChanged);
    // Seed rather than fire here: on first build this route is already
    // current, and the screen's own initState/build fetch already covers it.
    _onRoute = _isOnRoute(router);
  }

  @override
  void dispose() {
    _delegate?.removeListener(_onRouteChanged);
    super.dispose();
  }

  bool _isOnRoute(GoRouter? router) {
    if (router == null) return false;
    return widget.isTarget(router.routerDelegate.currentConfiguration.uri.path);
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    final now = _isOnRoute(router);
    if (now && !_onRoute) {
      widget.onReentry(ref);
    }
    _onRoute = now;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
