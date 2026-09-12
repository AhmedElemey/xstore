import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';

class SocialAuthState {
  const SocialAuthState({
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.isFacebookLoading = false,
    this.error,
    this.pendingSocialResult,
    this.needsRoleSelection = false,
  });

  final bool isGoogleLoading;
  final bool isAppleLoading;
  final bool isFacebookLoading;
  final String? error;
  final SocialAuthResult? pendingSocialResult;
  final bool needsRoleSelection;

  bool get isAnyLoading => isGoogleLoading || isAppleLoading || isFacebookLoading;

  SocialAuthState copyWith({
    bool? isGoogleLoading,
    bool? isAppleLoading,
    bool? isFacebookLoading,
    String? error,
    bool clearError = false,
    SocialAuthResult? pendingSocialResult,
    bool clearPending = false,
    bool? needsRoleSelection,
  }) {
    return SocialAuthState(
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      isFacebookLoading: isFacebookLoading ?? this.isFacebookLoading,
      error: clearError ? null : (error ?? this.error),
      pendingSocialResult: clearPending ? null : (pendingSocialResult ?? this.pendingSocialResult),
      needsRoleSelection: needsRoleSelection ?? this.needsRoleSelection,
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
      isAppleLoading: false,
      isFacebookLoading: false,
      clearError: true,
    );
    final result = await ref.read(googleSignInUseCaseProvider).call();
    if (!mounted) return;
    await result.fold(_handleFailure, _handleGoogleSuccess);
  }

  /// Google sign-in yields only the identity token; the actual backend session
  /// is created via a role-specific login endpoint. Before forcing the role
  /// picker, ask the backend (read-only `checkGoogleUser`) whether this
  /// identity already has an account — if so, log straight in with that
  /// existing role and skip the picker; only a genuinely new identity sees it.
  Future<void> _handleGoogleSuccess(SocialAuthResult result) async {
    final idToken = result.idToken;
    if (idToken == null || idToken.isEmpty) {
      state = state.copyWith(
        isGoogleLoading: false,
        isAppleLoading: false,
        isFacebookLoading: false,
        error: 'Google sign-in failed — no identity token. Please try again.',
      );
      return;
    }

    final checkResult =
        await ref.read(checkGoogleUserUseCaseProvider).call(idToken: idToken);
    if (!mounted) return;

    // A failed lookup (network hiccup, etc.) falls back to today's behavior
    // — show the picker. The role-specific login endpoint is safe to call
    // even for an existing user (it just logs them into their real role),
    // so this only costs an extra tap, never a wrong account.
    final existingRole = checkResult.fold((_) => null, (r) => r.exists ? r.role : null);
    if (existingRole != null) {
      await _loginWithGoogleRole(result, existingRole);
      return;
    }

    state = state.copyWith(
      isGoogleLoading: false,
      isAppleLoading: false,
      isFacebookLoading: false,
      clearError: true,
      pendingSocialResult: result,
      needsRoleSelection: true,
    );
  }

  Future<void> signInWithApple() async {
    if (state.isAnyLoading) return;
    state = state.copyWith(
      isGoogleLoading: false,
      isAppleLoading: true,
      isFacebookLoading: false,
      clearError: true,
    );
    final result = await ref.read(appleSignInUseCaseProvider).call();
    if (!mounted) return;
    await result.fold(_handleFailure, _handleSuccess);
  }

  Future<void> signInWithFacebook() async {
    if (state.isAnyLoading) return;
    state = state.copyWith(
      isGoogleLoading: false,
      isAppleLoading: false,
      isFacebookLoading: true,
      clearError: true,
    );
    final result = await ref.read(facebookSignInUseCaseProvider).call();
    if (!mounted) return;
    await result.fold(_handleFailure, _handleSuccess);
  }

  Future<void> completeSocialRegistration(UserRole role) async {
    final pending = state.pendingSocialResult;
    if (pending == null) return;

    // Apple/Facebook new users still use a local session until the generic
    // social backend route ships. Google uses the Google OAuth idToken (not a
    // Firebase ID token) against the role-specific backend login endpoints.
    if (pending.provider != SocialProvider.google) {
      await ref.read(authProvider.notifier).setUser(
            pending.toUserEntity(role),
          );
      if (!mounted) return;
      ref.read(analyticsServiceProvider).track(
        AnalyticsEvents.loginSuccess,
        properties: {
          AnalyticsProps.method: pending.provider.name,
          AnalyticsProps.role: role.name,
        },
      );
      state = state.copyWith(
        isGoogleLoading: false,
        isAppleLoading: false,
        isFacebookLoading: false,
        clearError: true,
        clearPending: true,
        needsRoleSelection: false,
      );
      return;
    }

    await _loginWithGoogleRole(pending, role);
  }

  /// Calls the role-specific Google login endpoint (auto-creates the account
  /// if none exists, or logs into the existing one) and adopts the resulting
  /// session. Shared by [_handleGoogleSuccess] (identity already has an
  /// account — skips the picker) and [completeSocialRegistration] (a new
  /// identity, role just chosen on the picker).
  Future<void> _loginWithGoogleRole(
    SocialAuthResult pending,
    UserRole role,
  ) async {
    final idToken = pending.idToken;
    if (idToken == null || idToken.isEmpty) {
      state = state.copyWith(
        isGoogleLoading: false,
        error: 'Google sign-in failed — no identity token. Please try again.',
        needsRoleSelection: false,
        clearPending: true,
      );
      return;
    }
    state = state.copyWith(isGoogleLoading: true, clearError: true);
    final result = await ref
        .read(googleLoginUseCaseProvider)
        .call(idToken: idToken, role: role);
    if (!mounted) return;
    result.fold(
      (failure) {
        state = state.copyWith(isGoogleLoading: false, error: failure.toString());
      },
      (user) {
        state = state.copyWith(
          isGoogleLoading: false,
          clearError: true,
          clearPending: true,
          needsRoleSelection: false,
        );
        // Session already persisted by the repository; adopt it synchronously
        // so the router moves off the role screen to home.
        ref.read(authProvider.notifier).adoptSession(user);
        ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.loginSuccess,
          properties: {
            AnalyticsProps.method: 'google',
            AnalyticsProps.role: user.role.name,
          },
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Abandons a pending Google sign-in (user backed out of role selection)
  /// before any backend session was created, so the router stops forcing the
  /// role screen. The caller navigates back to login.
  void cancelSocialRegistration() {
    state = state.copyWith(
      clearPending: true,
      needsRoleSelection: false,
      clearError: true,
      isGoogleLoading: false,
      isAppleLoading: false,
      isFacebookLoading: false,
    );
  }

  Future<void> _handleFailure(failure) async {
    final message = failure.toString();
    final cancelled = message.toLowerCase().contains('cancelled');
    state = state.copyWith(
      isGoogleLoading: false,
      isAppleLoading: false,
      isFacebookLoading: false,
      error: cancelled ? null : message,
    );
  }

  Future<void> _handleSuccess(SocialAuthResult result) async {
    if (result.isNewUser) {
      state = state.copyWith(
        isGoogleLoading: false,
        isAppleLoading: false,
        isFacebookLoading: false,
        pendingSocialResult: result,
        needsRoleSelection: true,
      );
      return;
    }
    await ref.read(authProvider.notifier).setUser(
          result.toUserEntity(UserRole.consumer),
        );
    if (!mounted) return;
    ref.read(analyticsServiceProvider).track(
      AnalyticsEvents.loginSuccess,
      properties: {
        AnalyticsProps.method: result.provider.name,
        AnalyticsProps.role: UserRole.consumer.name,
      },
    );
    state = state.copyWith(
      isGoogleLoading: false,
      isAppleLoading: false,
      isFacebookLoading: false,
      clearError: true,
      clearPending: true,
      needsRoleSelection: false,
    );
  }
}

final socialAuthProvider =
    StateNotifierProvider<SocialAuthNotifier, SocialAuthState>(
  (ref) => SocialAuthNotifier(ref),
);
