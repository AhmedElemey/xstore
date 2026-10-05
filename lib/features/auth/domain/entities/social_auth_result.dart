import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_auth_result.freezed.dart';

enum SocialProvider { google }

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
