import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/firebase/firebase_options.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/mock/mock_images.dart';
import '../../domain/entities/social_auth_result.dart';

abstract interface class SocialAuthDatasource {
  Future<SocialAuthResult> signInWithGoogle();
  Future<void> signOutSocial();
}

class SocialAuthDatasourceImpl implements SocialAuthDatasource {
  SocialAuthDatasourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _injectedGoogleSignIn = googleSignIn != null,
        _googleSignIn = googleSignIn ?? _createGoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final bool _injectedGoogleSignIn;
  GoogleSignIn _googleSignIn;

  static GoogleSignIn _createGoogleSignIn() => GoogleSignIn(
        serverClientId: DefaultFirebaseOptions.googleWebClientId,
      );

  @override
  Future<SocialAuthResult> signInWithGoogle() async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      return SocialAuthResult(
        provider: SocialProvider.google,
        uid: 'google_mock_uid_001',
        email: 'mockuser@gmail.com',
        displayName: 'Mock Google User',
        photoUrl: MockImages.avatar(10),
        // Non-null so the role screen's completeSocialRegistration proceeds
        // to the (mocked) backend Google login under MOCK=true.
        idToken: 'mock-google-id-token',
        isNewUser: false,
      );
    }
    try {
      await _resetGoogleSignIn();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const SocialAuthCancelledException('Google sign-in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        // Usually means serverClientId isn't configured.
        throw const SocialAuthException(googleSignInFailedErrorCode);
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleIdToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const SocialAuthException(googleSignInFailedErrorCode);
      }
      if (kDebugMode) {
        // Tokens are never logged in full. Payload dump is aud/email/sub
        // without jwt.io.
        final firebaseIdToken = await user.getIdToken();
        debugPrint('── Google sign-in credential ──');
        debugPrint('email: ${user.email}');
        debugPrint('displayName: ${user.displayName}');
        debugPrint('photoUrl: ${user.photoURL}');
        debugPrint('firebaseUid: ${user.uid}');
        debugPrint('isNewUser: ${userCredential.additionalUserInfo?.isNewUser}');
        print('clientId:');
        print(DefaultFirebaseOptions.googleWebClientId);
        // Never log the token itself; it is a live credential.
        debugPrint('google idToken: present (${googleIdToken.length} chars)');
        _debugLogGoogleIdTokenPayload(googleIdToken);
        debugPrint('firebase idToken: ${_truncatedForLog(firebaseIdToken)}');
      }
      return SocialAuthResult(
        provider: SocialProvider.google,
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        accessToken: googleAuth.accessToken,
        idToken: googleIdToken,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      throw SocialAuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> signOutSocial() async {
    if (MockConfig.useMock) return;
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Drops the cached Google account (and leftover Firebase session) so the
  /// next [GoogleSignIn.signIn] always shows the picker and mints a fresh
  /// ID token. A leftover session silently reuses the last account.
  Future<void> _resetGoogleSignIn() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    if (!_injectedGoogleSignIn) {
      _googleSignIn = _createGoogleSignIn();
    }
  }

  /// Returns a stable error code that screens map to l10n through
  /// `resolveAppError` (cancelled stays a plain string: it is swallowed).
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return socialAccountExistsErrorCode;
      case 'network-request-failed':
        return kOfflineErrorCode;
      case 'popup-closed-by-user':
        return 'Sign-in cancelled';
      case 'user-disabled':
        return socialAccountDisabledErrorCode;
      default:
        if (kDebugMode) debugPrint('firebase sign-in error: ${e.code}');
        return googleSignInFailedErrorCode;
    }
  }
}

/// Truncates a token to a short, unusable-as-credential prefix for
/// kDebugMode logcat output — just enough to eyeball which sign-in produced
/// it, never enough to paste elsewhere as a live bearer token.
String _truncatedForLog(String? token) {
  if (token == null || token.isEmpty) return '(none)';
  const visible = 12;
  if (token.length <= visible) return token;
  return '${token.substring(0, visible)}…(${token.length} chars)';
}

void _debugLogGoogleIdTokenPayload(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return;
  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    print('google idToken payload: $payload'); // ignore: avoid_print
  } catch (_) {}
}
