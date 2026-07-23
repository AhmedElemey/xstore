import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/firebase/firebase_options.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_images.dart';
import '../../domain/entities/social_auth_result.dart';

abstract interface class SocialAuthDatasource {
  Future<SocialAuthResult> signInWithGoogle();
  Future<SocialAuthResult> signInWithApple();
  Future<SocialAuthResult> signInWithFacebook();
  Future<void> signOutSocial();
}

class SocialAuthDatasourceImpl implements SocialAuthDatasource {
  SocialAuthDatasourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: DefaultFirebaseOptions.googleWebClientId,
            );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

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
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const SocialAuthCancelledException('Google sign-in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw const SocialAuthException(
          'Google sign-in failed — no identity token returned. '
          'Ensure serverClientId is configured.',
        );
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleIdToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const SocialAuthException('Google sign-in failed');
      if (kDebugMode) {
        // One debugPrint per field: tokens stay on single logcat lines (<4KB)
        // so they can be copy-pasted for backend verification testing.
        final firebaseIdToken = await user.getIdToken();
        debugPrint('── Google sign-in credential ──');
        debugPrint('email: ${user.email}');
        debugPrint('displayName: ${user.displayName}');
        debugPrint('photoUrl: ${user.photoURL}');
        debugPrint('firebaseUid: ${user.uid}');
        debugPrint('isNewUser: ${userCredential.additionalUserInfo?.isNewUser}');
        debugPrint('google idToken (backend verifies this): $googleIdToken');
        debugPrint('firebase idToken: $firebaseIdToken');
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
  Future<SocialAuthResult> signInWithApple() async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      return const SocialAuthResult(
        provider: SocialProvider.apple,
        uid: 'apple_mock_uid_001',
        email: 'mockuser@icloud.com',
        displayName: 'Mock Apple User',
        isNewUser: false,
      );
    }
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256OfString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final provider = OAuthProvider('apple.com');
      final credential = provider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const SocialAuthException('Apple sign-in failed');
      final displayName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
      if (displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      return SocialAuthResult(
        provider: SocialProvider.apple,
        uid: user.uid,
        email: user.email ?? appleCredential.email,
        displayName: displayName.isNotEmpty ? displayName : user.displayName,
        photoUrl: user.photoURL,
        idToken: appleCredential.identityToken,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthCancelledException('Apple sign-in cancelled');
      }
      throw SocialAuthException(e.message);
    } on FirebaseAuthException catch (e) {
      throw SocialAuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<SocialAuthResult> signInWithFacebook() async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      return SocialAuthResult(
        provider: SocialProvider.facebook,
        uid: 'facebook_mock_uid_001',
        email: 'mockuser@facebook.com',
        displayName: 'Mock Facebook User',
        photoUrl: MockImages.avatar(11),
        isNewUser: false,
      );
    }
    try {
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );
      if (result.status == LoginStatus.cancelled) {
        throw const SocialAuthCancelledException('Facebook sign-in cancelled');
      }
      if (result.status == LoginStatus.failed) {
        throw SocialAuthException(result.message ?? 'Facebook login failed');
      }
      final accessToken = result.accessToken?.tokenString;
      if (accessToken == null) {
        throw const SocialAuthException('Facebook login failed');
      }
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );
      final credential = FacebookAuthProvider.credential(accessToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const SocialAuthException('Facebook sign-in failed');
      return SocialAuthResult(
        provider: SocialProvider.facebook,
        uid: user.uid,
        email: userData['email'] as String? ?? user.email,
        displayName: userData['name'] as String? ?? user.displayName,
        photoUrl: (userData['picture'] as Map?)?['data']?['url'] as String? ??
            user.photoURL,
        accessToken: accessToken,
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
      FacebookAuth.instance.logOut(),
    ]);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account with this email already exists. Try a different sign-in method.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'popup-closed-by-user':
        return 'Sign-in cancelled';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      default:
        return e.message ?? e.code;
    }
  }
}
