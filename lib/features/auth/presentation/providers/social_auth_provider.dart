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
    this.needsRegistration = false,
  });

  final bool isGoogleLoading;
  final bool isAppleLoading;
  final bool isFacebookLoading;
  final String? error;
  final SocialAuthResult? pendingSocialResult;
  final bool needsRoleSelection;

  /// A Google sign-in found no existing account for this identity — the
  /// caller (login/register screen) should navigate to the full register
  /// flow and consume this by calling [SocialAuthNotifier.acknowledgeNeedsRegistration].
  final bool needsRegistration;

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
    bool? needsRegistration,
  }) {
    return SocialAuthState(
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      isFacebookLoading: isFacebookLoading ?? this.isFacebookLoading,
      error: clearError ? null : (error ?? this.error),
      pendingSocialResult: clearPending ? null : (pendingSocialResult ?? this.pendingSocialResult),
      needsRoleSelection: needsRoleSelection ?? this.needsRoleSelection,
      needsRegistration: needsRegistration ?? this.needsRegistration,
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

  /// Google is a login-only shortcut, not a self-service account creator:
  /// ask the backend (read-only `checkGoogleUser`) whether this identity
  /// already has an account. If it does, log straight in with that existing
  /// role via the role-specific endpoint (which also auto-creates, but is
  /// never asked to here). If it doesn't, send the user to the normal
  /// register flow instead — Google never collects a phone number or
  /// password, which the rest of the app treats as required account fields.
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

    // A failed lookup (network hiccup, etc.) falls back to the safe default
    // — send to register. Registering with a real phone/password when an
    // account already exists just fails there with an actionable error,
    // never silently creates a duplicate or wrong-role account.
    final existingRole = checkResult.fold((_) => null, (r) => r.exists ? r.role : null);
    if (existingRole == null) {
      state = state.copyWith(
        isGoogleLoading: false,
        isAppleLoading: false,
        isFacebookLoading: false,
        clearError: true,
        needsRegistration: true,
      );
      return;
    }

    state = state.copyWith(isGoogleLoading: true, clearError: true);
    final loginResult = await ref
        .read(googleLoginUseCaseProvider)
        .call(idToken: idToken, role: existingRole);
    if (!mounted) return;
    loginResult.fold(
      (failure) {
        state = state.copyWith(isGoogleLoading: false, error: failure.toString());
      },
      (user) {
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
      },
    );
  }

  /// Consumes [SocialAuthState.needsRegistration] once the caller has
  /// navigated to the register screen, so it doesn't fire again on a later,
  /// unrelated visit to that screen.
  void acknowledgeNeedsRegistration() {
    state = state.copyWith(needsRegistration: false);
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

  /// Only reachable for Apple/Facebook new users now — a new Google identity
  /// never sets [SocialAuthState.pendingSocialResult] (see
  /// [_handleGoogleSuccess]), so `pending.provider` here is never
  /// [SocialProvider.google]. Apple/Facebook new users still use a local
  /// session until the generic social backend route ships.
  Future<void> completeSocialRegistration(UserRole role) async {
    final pending = state.pendingSocialResult;
    if (pending == null) return;

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
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Abandons a pending Apple/Facebook sign-in (user backed out of role
  /// selection) before any local session was created, so the router stops
  /// forcing the role screen. The caller navigates back to login.
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
