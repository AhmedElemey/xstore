import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'mock_images.dart';

/// Domain session user (matches persisted [UserEntity] fields only).
const mockVendorUser = UserEntity(
  id: 'vendor_001',
  email: 'ahmed@xstore.com',
  isVendor: true,
);

const mockConsumerUser = UserEntity(
  id: 'consumer_001',
  email: 'sara@gmail.com',
  isVendor: false,
);

UserModel mockVendorUserModel({String? email}) => UserModel(
      id: mockVendorUser.id,
      email: email ?? mockVendorUser.email,
      isVendor: true,
      token: 'mock-token-vendor',
    );

UserModel mockConsumerUserModel({String? email}) => UserModel(
      id: mockConsumerUser.id,
      email: email ?? mockConsumerUser.email,
      isVendor: false,
      token: 'mock-token-consumer',
    );

/// Extra display fields for seller/profile UIs (not stored on [UserEntity]).
final mockVendorProfileDisplay = (
  name: 'Ahmed Bensalem',
  email: 'ahmed@xstore.com',
  avatarUrl: MockImages.avatar(1),
  isVerified: true,
  rating: 4.8,
  totalSales: 142,
  joinedAt: DateTime(2023, 3, 15),
  location: 'Algiers, Algeria',
);

final mockConsumerProfileDisplay = (
  name: 'Sara Khelifi',
  email: 'sara@gmail.com',
  avatarUrl: MockImages.avatar(2),
  isVerified: false,
  rating: null as double?,
  totalSales: null as int?,
  joinedAt: DateTime(2024, 1, 10),
  location: 'Oran, Algeria',
);

bool mockLoginIsVendor(String email) {
  final e = email.toLowerCase().trim();
  return e.contains('vendor') || e == 'ahmed@xstore.com';
}
