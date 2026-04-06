import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    await result.fold(_handleFailure, _handleSuccess);
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
    await result.fold(_handleFailure, _handleSuccess);
  }

  Future<void> completeSocialRegistration(UserRole role) async {
    final pending = state.pendingSocialResult;
    if (pending == null) return;
    await ref.read(authProvider.notifier).setUser(pending.toUserEntity(role));
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
