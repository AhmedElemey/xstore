import '../../features/auth/domain/entities/user_entity.dart';

/// Shell bottom navigation mode for [XstoreBottomNav].
enum UserRole {
  consumer,
  vendor,
}

extension UserRoleX on UserEntity? {
  UserRole get toUserRole =>
      this?.isVendor == true ? UserRole.vendor : UserRole.consumer;
}
