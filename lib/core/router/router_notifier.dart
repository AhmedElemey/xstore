import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
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
/// non-vendors blocked from `/listing/*`.
String? computeXStoreAuthRedirect({
  required AsyncValue<UserEntity?> auth,
  required bool needsRoleSelection,
  required String matchedLocation,
  bool holdRegisterForVendorSuccess = false,
}) {
  final loc = matchedLocation;
  final isAuthRoute = loc == AppRoutes.splash ||
      loc == AppRoutes.onboarding ||
      loc == AppRoutes.login ||
      loc == AppRoutes.register ||
      loc == AppRoutes.socialRoleSelect ||
      loc == AppRoutes.otp ||
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
        return isAuthRoute ? null : AppRoutes.login;
      }
      if (isAuthRoute) {
        if (loc == AppRoutes.register && holdRegisterForVendorSuccess) {
          return null;
        }
        return AppRoutes.home;
      }
      if (isVendorRestrictedRoute(loc) && !user.isVendor) {
        return AppRoutes.home;
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => AppRoutes.login,
  );
}

/// Typed wrapper for [GoRouter.redirect] using the active [Ref].
String? xStoreGoRouterRedirect(Ref ref, GoRouterState state) {
  final holdVendorSuccess =
      ref.read(registerNotifierProvider).showVendorSuccessOverlay;
  final needsRoleSelection =
      ref.read(socialAuthProvider.select((s) => s.needsRoleSelection));
  return computeXStoreAuthRedirect(
    auth: ref.read(authProvider),
    needsRoleSelection: needsRoleSelection,
    matchedLocation: state.matchedLocation,
    holdRegisterForVendorSuccess: holdVendorSuccess,
  );
}

final class RouterNotifier extends Listenable {
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => _notify());
    _ref.listen(socialAuthProvider.select((s) => s.needsRoleSelection), (_, __) => _notify());
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
