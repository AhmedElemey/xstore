import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/profile_entity.dart';

/// DTO for profile API responses (mock or live).
class ProfileModel {
  const ProfileModel({
    required this.user,
    this.wishlistCount = 0,
    this.savedAmountDzd,
    this.storeViewCount = 0,
    this.storeSaveCount = 0,
    this.storeActiveListings = 0,
    this.responseRatePercent = 0,
    this.isEmailVerificationRequired = false,
    this.isPhoneVerificationRequired = false,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.hasPassword = true,
  });

  final UserModel user;
  final int wishlistCount;
  final int? savedAmountDzd;
  final int storeViewCount;
  final int storeSaveCount;
  final int storeActiveListings;
  final int responseRatePercent;
  final bool isEmailVerificationRequired;
  final bool isPhoneVerificationRequired;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool hasPassword;

  ProfileEntity toEntity() => ProfileEntity(
    user: user.toEntity(),
    wishlistCount: wishlistCount,
    savedAmountDzd: savedAmountDzd,
    storeViewCount: storeViewCount,
    storeSaveCount: storeSaveCount,
    storeActiveListings: storeActiveListings,
    responseRatePercent: responseRatePercent,
    isEmailVerificationRequired: isEmailVerificationRequired,
    isPhoneVerificationRequired: isPhoneVerificationRequired,
    isEmailVerified: isEmailVerified,
    isPhoneVerified: isPhoneVerified,
    hasPassword: hasPassword,
  );
}
