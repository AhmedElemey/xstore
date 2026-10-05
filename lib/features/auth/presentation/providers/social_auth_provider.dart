import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';

class SocialAuthState {
  const SocialAuthState({
    this.isGoogleLoading = false,
    this.error,
    this.googleRegistration,
  });

  final bool isGoogleLoading;
  final String? error;

  /// A Google sign-in found no existing account for this identity — the
  /// caller (login/register screen) should open the full register flow
  /// prefilled with this Google profile (email, name) and consume it by
  /// calling [SocialAuthNotifier.acknowledgeNeedsRegistration].
  final SocialAuthResult? googleRegistration;

  bool get needsRegistration => googleRegistration != null;

  bool get isAnyLoading => isGoogleLoading;

  SocialAuthState copyWith({
    bool? isGoogleLoading,
    String? error,
    bool clearError = false,
    SocialAuthResult? googleRegistration,
    bool clearGoogleRegistration = false,
  }) {
    return SocialAuthState(
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      error: clearError ? null : (error ?? this.error),
      googleRegistration: clearGoogleRegistration
          ? null
          : (googleRegistration ?? this.googleRegistration),
    );
  }
}

class SocialAuthNotifier extends StateNotifier<SocialAuthState> {
  SocialAuthNotifier(this.ref) : super(const SocialAuthState());

  final Ref ref;

  Future<void> signInWithGoogle() async {
    if (state.isAnyLoading) return;
    state = state.copyWith(
      isGoogleLoading: true,
      clearError: true,
    );
    final result = await ref.read(googleSignInUseCaseProvider).call();
    if (!mounted) return;
    await result.fold(_handleFailure, _handleGoogleSuccess);
  }

  /// Google is a login-only shortcut, not a self-service account creator:
  /// ask the backend (read-only `checkGoogleUser`) whether this identity
  /// already has an account. If it does, log straight in via the single
  /// `/api/auth/google/login` endpoint (any role). Otherwise — or if the
  /// lookup failed — go to the register flow prefilled with the Google
  /// profile.
  ///
  /// Firebase `isNewUser` plays no part: Firebase remembers every Google
  /// account that ever signed in to the project, so it says nothing about
  /// whether a backend account exists.
  Future<void> _handleGoogleSuccess(SocialAuthResult result) async {
    final idToken = result.idToken;
    if (idToken == null || idToken.isEmpty) {
      state = state.copyWith(
        isGoogleLoading: false,
        error: 'Google sign-in failed — no identity token. Please try again.',
      );
      return;
    }

    final checkResult =
        await ref.read(checkGoogleUserUseCaseProvider).call(idToken: idToken);
    if (!mounted) return;

    var exists = false;
    UserRole? existingRole;
    checkResult.fold((_) {}, (r) {
      exists = r.exists;
      existingRole = r.role;
    });
    if (kDebugMode) {
      debugPrint(
        'google check-user parsed: exists=$exists role=$existingRole',
      );
    }

    // Existing account (any role): one login endpoint; the role comes back
    // with the profile.
    if (exists || existingRole != null) {
      await _loginWithGoogle(idToken);
      return;
    }

    state = state.copyWith(
      isGoogleLoading: false,
      clearError: true,
      googleRegistration: result,
    );
  }

  Future<void> _loginWithGoogle(String idToken) async {
    state = state.copyWith(isGoogleLoading: true, clearError: true);
    final result =
        await ref.read(googleLoginUseCaseProvider).call(idToken: idToken);
    if (!mounted) return;
    result.fold(
      (failure) {
        state = state.copyWith(isGoogleLoading: false, error: failure.toString());
      },
      _adoptGoogleSession,
    );
  }

  void _adoptGoogleSession(UserEntity user) {
    state = state.copyWith(isGoogleLoading: false, clearError: true);
    // Session already persisted by the repository; adopt it synchronously
    // so the router moves off login to home.
    ref.read(authProvider.notifier).adoptSession(user);
    ref.read(analyticsServiceProvider).track(
      AnalyticsEvents.loginSuccess,
      properties: {
        AnalyticsProps.method: 'google',
        AnalyticsProps.role: user.role.name,
      },
    );
  }

  /// Consumes [SocialAuthState.needsRegistration] once the caller has
  /// navigated to the register screen, so it doesn't fire again on a later,
  /// unrelated visit to that screen.
  void acknowledgeNeedsRegistration() {
    state = state.copyWith(clearGoogleRegistration: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _handleFailure(failure) async {
    final message = failure.toString();
    final cancelled = message.toLowerCase().contains('cancelled');
    state = state.copyWith(
      isGoogleLoading: false,
      error: cancelled ? null : message,
    );
  }

}

final socialAuthProvider =
    StateNotifierProvider<SocialAuthNotifier, SocialAuthState>(
  (ref) => SocialAuthNotifier(ref),
);
