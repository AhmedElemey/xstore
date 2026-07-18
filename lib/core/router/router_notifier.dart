import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/guest_mode_provider.dart';
import '../../features/auth/presentation/providers/social_auth_provider.dart';
import 'app_routes.dart';

part 'router_notifier.g.dart';

/// Bridges auth state to [GoRouter] via [Listenable] for `refreshListenable`.
///
/// Auth-based redirects (including vendor route guard) are centralized in
/// [computeXStoreAuthRedirect] so they live next to this notifier, which
/// [watch]es [authProvider] and notifies the router when session changes.
@Riverpod(keepAlive: true)
RouterNotifier routerNotifier(RouterNotifierRef ref) {
  return RouterNotifier(ref);
}

/// Redirect guard: unauthenticated users, post-login leave auth screens,
/// role guards all ways — consumers blocked from vendor areas (listings,
/// vendor orders, store tooling), vendors and couriers blocked from the
/// buying flow (cart, checkout, wishlist, consumer orders), non-couriers
/// blocked from the delivery run. Couriers home to [AppRoutes.deliveries].
/// Guests ([isGuest]) may browse [isGuestAccessibleRoute] areas; anything
/// else routes to login.
String? computeXStoreAuthRedirect({
  required AsyncValue<UserEntity?> auth,
  required bool needsRoleSelection,
  required String matchedLocation,
  bool holdRegisterForVendorSuccess = false,
  bool isGuest = false,
}) {
  final loc = matchedLocation;
  final isAuthRoute = loc == AppRoutes.splash ||
      loc == AppRoutes.onboarding ||
      loc == AppRoutes.login ||
      loc == AppRoutes.register ||
      loc == AppRoutes.socialRoleSelect ||
      loc == AppRoutes.otp ||
      loc == AppRoutes.courierLogin ||
      loc == AppRoutes.forgotPassword;

  return auth.when(
    data: (user) {
      final loggedIn = user != null;
      if (loggedIn && needsRoleSelection && loc != AppRoutes.socialRoleSelect) {
        return AppRoutes.socialRoleSelect;
      }
      if (loggedIn && !needsRoleSelection && loc == AppRoutes.socialRoleSelect) {
        return AppRoutes.home;
      }
      if (!loggedIn) {
        if (isGuest && isGuestAccessibleRoute(loc)) return null;
        // Guests may still open auth screens to sign in for real; splash
        // stays reachable so cold start doesn't loop.
        return isAuthRoute ? null : AppRoutes.login;
      }
      // Couriers land on their run, not the marketplace home — /home and
      // /explore only exist inside the consumer/vendor shells, so a courier
      // reaching them would hit "no route" instead of a screen.
      final roleHome =
          user.isCourier ? AppRoutes.deliveries : AppRoutes.home;
      if (isAuthRoute) {
        if (loc == AppRoutes.register && holdRegisterForVendorSuccess) {
          return null;
        }
        return roleHome;
      }
      if (user.isCourier &&
          (loc == AppRoutes.home || loc == AppRoutes.explore)) {
        return AppRoutes.deliveries;
      }
      if (isCourierRestrictedRoute(loc) && !user.isCourier) {
        return AppRoutes.home;
      }
      if (isVendorRestrictedRoute(loc) && !user.isVendor) {
        return roleHome;
      }
      if (isConsumerRestrictedRoute(loc) &&
          user.role != UserRole.consumer) {
        return roleHome;
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => AppRoutes.login,
  );
}

final class RouterNotifier extends Listenable {
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) {
      // Delay one frame so ref.read(authProvider) returns
      // AsyncData when redirect evaluates — fixes release timing
      WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
    });
    _ref.listen(socialAuthProvider.select((s) => s.needsRoleSelection), (_, __) => _notify());
    _ref.listen(guestModeProvider, (_, __) => _notify());
    _ref.listen(
      registerNotifierProvider.select((s) => s.showVendorSuccessOverlay),
      (_, __) => _notify(),
    );
  }

  final Ref _ref;
  final List<VoidCallback> _listeners = [];

  void _notify() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
}
