import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_entity.dart';

part 'social_auth_result.freezed.dart';

enum SocialProvider {
  google,
  apple,
  facebook,
}

@freezed
class SocialAuthResult with _$SocialAuthResult {
  const factory SocialAuthResult({
    required SocialProvider provider,
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? accessToken,
    String? idToken,
    @Default(false) bool isNewUser,
  }) = _SocialAuthResult;
}

extension SocialAuthResultX on SocialAuthResult {
  UserEntity toUserEntity(UserRole role) => UserEntity(
        id: uid,
        name: (displayName == null || displayName!.trim().isEmpty)
            ? 'User'
            : displayName!.trim(),
        email: email ?? '',
        phoneNumber: '',
        avatarUrl: photoUrl,
        role: role,
        isVerified: false,
        joinedAt: DateTime.now(),
      );
}
