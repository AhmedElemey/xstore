import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/register_params.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'mock_images.dart';

/// Domain session user (reference display).
const mockVendorUser = UserEntity(
  id: 'vendor_001',
  name: 'Ahmed Bensalem',
  email: 'ahmed@xstore.com',
  phoneNumber: '+213555000001',
  role: UserRole.vendor,
  isVerified: true,
  rating: 4.8,
  totalSales: 142,
  joinedAt: null,
  location: 'Algiers, Algeria',
  storeName: "Ahmed's Electronics",
  storeSlug: 'ahmeds-electronics',
  storeCategory: 'Electronics',
);

const mockConsumerUser = UserEntity(
  id: 'consumer_001',
  name: 'Sara Khelifi',
  email: 'sara@gmail.com',
  phoneNumber: '+213555000002',
  role: UserRole.consumer,
  isVerified: false,
  joinedAt: null,
  location: 'Oran, Algeria',
);

UserModel mockVendorUserModel({
  String? email,
  String? name,
  String? phoneNumber,
}) =>
    UserModel(
      id: mockVendorUser.id,
      name: name ?? mockVendorUser.name,
      email: email ?? mockVendorUser.email,
      phoneNumber: phoneNumber ?? mockVendorUser.phoneNumber,
      avatarUrl: MockImages.avatar(1),
      role: UserRole.vendor,
      isVerified: true,
      rating: 4.8,
      totalSales: 142,
      joinedAt: DateTime(2023, 3, 15),
      location: mockVendorUser.location,
      storeName: mockVendorUser.storeName,
      storeSlug: mockVendorUser.storeSlug,
      storeCategory: mockVendorUser.storeCategory,
      token: 'mock-token-vendor',
    );

UserModel mockConsumerUserModel({
  String? email,
  String? name,
  String? phoneNumber,
}) =>
    UserModel(
      id: mockConsumerUser.id,
      name: name ?? mockConsumerUser.name,
      email: email ?? mockConsumerUser.email,
      phoneNumber: phoneNumber ?? mockConsumerUser.phoneNumber,
      avatarUrl: MockImages.avatar(2),
      role: UserRole.consumer,
      isVerified: false,
      joinedAt: DateTime(2024, 1, 10),
      location: mockConsumerUser.location,
      token: 'mock-token-consumer',
    );

/// Extra display fields for seller/profile UIs (legacy tuple — prefer [UserEntity]).
final mockVendorProfileDisplay = (
  name: mockVendorUser.name,
  email: mockVendorUser.email,
  avatarUrl: MockImages.avatar(1),
  isVerified: true,
  rating: 4.8,
  totalSales: 142,
  joinedAt: DateTime(2023, 3, 15),
  location: mockVendorUser.location ?? '',
);

final mockConsumerProfileDisplay = (
  name: mockConsumerUser.name,
  email: mockConsumerUser.email,
  avatarUrl: MockImages.avatar(2),
  isVerified: false,
  rating: null as double?,
  totalSales: null as int?,
  joinedAt: DateTime(2024, 1, 10),
  location: mockConsumerUser.location ?? '',
);

bool mockLoginIsVendor(String emailOrPhone) {
  final e = emailOrPhone.toLowerCase().trim();
  return e.contains('vendor') ||
      e.contains('seller') ||
      e == 'ahmed@xstore.com';
}

UserModel userModelFromRegisterParams(RegisterParams p, {String? id}) {
  final newId = id ?? 'user_${p.email.hashCode.abs()}';
  final joined = DateTime.now();
  if (p.role == UserRole.vendor) {
    final slug = (p.storeName ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    final safeSlug = slug.isEmpty ? 'store' : slug;
    return UserModel(
      id: newId,
      name: p.fullName,
      email: p.email,
      phoneNumber: '${p.countryCode}${p.phoneNumber}',
      role: UserRole.vendor,
      isVerified: false,
      joinedAt: joined,
      location: p.location,
      storeName: p.storeName,
      storeSlug: safeSlug,
      storeCategory: p.storeCategory,
      storeDescription: p.storeDescription,
      storeCity: p.storeCity,
      storeWilaya: p.storeWilaya,
      whatsappNumber: p.whatsappNumber,
      token: 'mock-token-new-vendor',
    );
  }
  return UserModel(
    id: newId,
    name: p.fullName,
    email: p.email,
    phoneNumber: '${p.countryCode}${p.phoneNumber}',
    role: UserRole.consumer,
    isVerified: false,
    joinedAt: joined,
    location: p.location,
    token: 'mock-token-new-consumer',
  );
}
