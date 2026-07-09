import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/send_otp_result.dart';
import '../../domain/entities/user_entity.dart';

/// Fixed test code accepted by [PhoneAuthDatasourceImpl.verifyOtp] when
/// `MockConfig.useMock` — no real SMS is sent, so there's nothing else to
/// enter here during local dev/testing.
const kMockPhoneOtpCode = '123456';

abstract interface class PhoneAuthDatasource {
  Future<SendOtpResult> sendOtp({
    required String e164Number,
    int? resendToken,
  });

  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String otpCode,
    required String phoneNumber,
  });
}

class PhoneAuthDatasourceImpl implements PhoneAuthDatasource {
  PhoneAuthDatasourceImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<SendOtpResult> sendOtp({
    required String e164Number,
    int? resendToken,
  }) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      return SendOtpResult(
        verificationId: 'mock_verification_id_12345',
        phoneNumber: AppValidators.toLocalEgypt(e164Number),
        resendToken: null,
        expiresAt: DateTime.now().add(const Duration(seconds: 60)),
        debugOtp: kMockPhoneOtpCode,
      );
    }

    final completer = Completer<SendOtpResult>();
    await _auth.verifyPhoneNumber(
      phoneNumber: e164Number,
      verificationCompleted: (credential) async {
        if (completer.isCompleted) return;
        try {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(
              SendOtpResult(
                verificationId: '',
                phoneNumber: AppValidators.toLocalEgypt(e164Number),
                resendToken: null,
                expiresAt: DateTime.now().add(const Duration(seconds: 60)),
                autoVerified: true,
              ),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(PhoneAuthException(_mapFirebaseError(e.code)));
          }
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(PhoneAuthException(_mapFirebaseError(e.code)));
        }
      },
      codeSent: (verificationId, token) {
        if (!completer.isCompleted) {
          completer.complete(
            SendOtpResult(
              verificationId: verificationId,
              phoneNumber: AppValidators.toLocalEgypt(e164Number),
              resendToken: token,
              expiresAt: DateTime.now().add(const Duration(seconds: 60)),
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
    );
    return completer.future;
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String otpCode,
    required String phoneNumber,
  }) async {
    if (MockConfig.useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (otpCode != kMockPhoneOtpCode) {
        throw const PhoneAuthException(AppStrings.otpInvalidCode);
      }
      final isVendor = phoneNumber.startsWith('011') || phoneNumber.startsWith('015');
      return UserEntity(
        id: 'phone_user_$phoneNumber',
        name: isVendor ? 'Ahmed Vendor' : 'Sara Consumer',
        email: '',
        phoneNumber: phoneNumber,
        role: isVendor ? UserRole.vendor : UserRole.consumer,
        isVerified: true,
        joinedAt: DateTime.now(),
      );
    }

    try {
      final (user, isNew) = await _signInOrUseExistingSession(
        verificationId: verificationId,
        otpCode: otpCode,
      );
      return UserEntity(
        id: user.uid,
        name: user.displayName ?? AppValidators.formatEgyptPhone(user.phoneNumber ?? ''),
        email: user.email ?? '',
        phoneNumber: AppValidators.toLocalEgypt(user.phoneNumber ?? phoneNumber),
        avatarUrl: user.photoURL,
        role: UserRole.consumer,
        isVerified: user.phoneNumber != null,
        joinedAt: user.metadata.creationTime ?? DateTime.now(),
        isNewUser: isNew,
      );
    } on FirebaseAuthException catch (e) {
      throw PhoneAuthException(_mapFirebaseError(e.code));
    }
  }

  Future<(User, bool)> _signInOrUseExistingSession({
    required String verificationId,
    required String otpCode,
  }) async {
    final current = _auth.currentUser;
    if (otpCode.isEmpty &&
        current != null &&
        current.phoneNumber != null &&
        current.phoneNumber!.isNotEmpty) {
      return (current, false);
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw const PhoneAuthException(AppStrings.genericError);
    return (user, userCredential.additionalUserInfo?.isNewUser ?? false);
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return AppStrings.phoneInvalidNumber;
      case 'too-many-requests':
      case 'quota-exceeded':
        return AppStrings.phoneTooManyRequests;
      case 'invalid-verification-code':
        return AppStrings.otpInvalidCode;
      case 'session-expired':
        return AppStrings.otpSessionExpired;
      case 'network-request-failed':
        return AppStrings.noInternet;
      default:
        return AppStrings.genericError;
    }
  }
}
