import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/profile_entity.dart';

/// DTO for profile API responses (mock or live).
class ProfileModel {
  const ProfileModel({
    required this.user,
    this.ordersCount = 0,
    this.wishlistCount = 0,
    this.savedAmountDzd = 0,
    this.storeViewCount = 0,
    this.storeSaveCount = 0,
    this.storeActiveListings = 0,
    this.responseRatePercent = 0,
    this.isEmailVerificationRequired = false,
    this.isPhoneVerificationRequired = false,
  });

  final UserModel user;
  final int ordersCount;
  final int wishlistCount;
  final int savedAmountDzd;
  final int storeViewCount;
  final int storeSaveCount;
  final int storeActiveListings;
  final int responseRatePercent;
  final bool isEmailVerificationRequired;
  final bool isPhoneVerificationRequired;

  ProfileEntity toEntity() => ProfileEntity(
        user: user.toEntity(),
        ordersCount: ordersCount,
        wishlistCount: wishlistCount,
        savedAmountDzd: savedAmountDzd,
        storeViewCount: storeViewCount,
        storeSaveCount: storeSaveCount,
        storeActiveListings: storeActiveListings,
        responseRatePercent: responseRatePercent,
        isEmailVerificationRequired: isEmailVerificationRequired,
        isPhoneVerificationRequired: isPhoneVerificationRequired,
      );
}
