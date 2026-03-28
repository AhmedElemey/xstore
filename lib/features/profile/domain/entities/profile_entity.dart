import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';

part 'profile_entity.freezed.dart';

@freezed
class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({
    required UserEntity user,
    @Default(0) int ordersCount,
    @Default(0) int wishlistCount,
    @Default(0) int savedAmountDzd,
    @Default(0) int storeViewCount,
    @Default(0) int storeSaveCount,
    @Default(0) int storeActiveListings,
    @Default(0) int responseRatePercent,
  }) = _ProfileEntity;
}
