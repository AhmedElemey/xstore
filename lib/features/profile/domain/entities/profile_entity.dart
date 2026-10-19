import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';

part 'profile_entity.freezed.dart';

@freezed
class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({
    required UserEntity user,
    @Default(0) int wishlistCount,

    /// Null when the backend doesn't provide it (live get-profile never does).
    int? savedAmountDzd,
    @Default(0) int storeViewCount,
    @Default(0) int storeSaveCount,
    @Default(0) int storeActiveListings,
    @Default(0) int responseRatePercent,
    @Default(false) bool isEmailVerificationRequired,
    @Default(false) bool isPhoneVerificationRequired,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,

    /// Social-only accounts send `hasPassword: "No"` and skip current-password.
    @Default(true) bool hasPassword,
  }) = _ProfileEntity;
}
