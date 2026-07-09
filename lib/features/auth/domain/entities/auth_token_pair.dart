import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token_pair.freezed.dart';

@freezed
class AuthTokenPair with _$AuthTokenPair {
  const factory AuthTokenPair({
    required String token,
    required String refreshToken,
  }) = _AuthTokenPair;
}
