import '../../features/auth/data/models/user_model.dart';
import '../utils/validators.dart';
import '../../features/auth/domain/entities/consumer_register_params.dart';
import '../../features/auth/domain/entities/register_params.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/entities/vendor_register_params.dart';
import 'mock_images.dart';

/// Domain session user (reference display).
const mockVendorUser = UserEntity(
  id: 'vendor_001',
  name: 'Ahmed Bensalem',
  email: 'ahmed@xstore.com',
  phoneNumber: '+201055500001',
  role: UserRole.vendor,
  isVerified: true,
  rating: 4.8,
  totalSales: 142,
  joinedAt: null,
  location: 'Algiers, Egypt',
  storeName: "Ahmed's Electronics",
  storeSlug: 'ahmeds-electronics',
  storeCategory: 'Electronics',
  storeDescription:
      'Premium electronics at the best prices in Egypt. All products are genuine and come with full warranty.',
  storeCity: 'Algiers',
  storeWilaya: 'Alger',
  whatsappNumber: '+20 105 551 2345',
  latitude: 30.044400,
  longitude: 31.235700,
  governorate: 'Cairo',
  town: 'Nasr City',
  detailAddress: '12 Tahrir Street, Floor 3',
);

/// Owner-created delivery account (couriers cannot self-register).
const mockCourierUser = UserEntity(
  id: 'courier_001',
  name: 'Mostafa El-Sayed',
  email: 'mostafa.courier@xstore.com',
  phoneNumber: '+201055500003',
  role: UserRole.courier,
  isVerified: true,
  joinedAt: null,
  location: 'Cairo, Egypt',
);

const mockConsumerUser = UserEntity(
  id: 'consumer_001',
  name: 'Sara Khelifi',
  email: 'sara@gmail.com',
  phoneNumber: '+201255500002',
  role: UserRole.consumer,
  isVerified: false,
  joinedAt: null,
  location: 'Oran, Egypt',
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
      storeDescription: mockVendorUser.storeDescription,
      storeCity: mockVendorUser.storeCity,
      storeWilaya: mockVendorUser.storeWilaya,
      whatsappNumber: mockVendorUser.whatsappNumber,
      latitude: mockVendorUser.latitude,
      longitude: mockVendorUser.longitude,
      governorate: mockVendorUser.governorate,
      town: mockVendorUser.town,
      detailAddress: mockVendorUser.detailAddress,
      token: 'mock-token-vendor',
    );

UserModel mockCourierUserModel({
  String? email,
  String? name,
  String? phoneNumber,
}) =>
    UserModel(
      id: mockCourierUser.id,
      name: name ?? mockCourierUser.name,
      email: email ?? mockCourierUser.email,
      phoneNumber: phoneNumber ?? mockCourierUser.phoneNumber,
      avatarUrl: MockImages.avatar(4),
      role: UserRole.courier,
      isVerified: true,
      joinedAt: DateTime(2026, 6, 1),
      location: mockCourierUser.location,
      token: 'mock-token-courier',
      refreshToken: 'mock-refresh-token-courier',
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

/// The login UI is phone-first (identifiers reach the datasource as
/// normalized 11-digit local numbers), so each mock role also matches its
/// seed user's phone. Email/keyword forms are kept for tests and direct calls.
bool _matchesMockPhone(String identifier, UserEntity user) =>
    AppValidators.normalizeEgyptLocal(identifier) ==
    AppValidators.normalizeEgyptLocal(user.phoneNumber);

bool mockLoginIsVendor(String emailOrPhone) {
  final e = emailOrPhone.toLowerCase().trim();
  return e.contains('vendor') ||
      e.contains('seller') ||
      e == 'ahmed@xstore.com' ||
      _matchesMockPhone(e, mockVendorUser);
}

/// Mock-mode courier sign-in: the mock courier's phone (01055500003 — the
/// only form the phone-first login screen lets through) or any identifier
/// mentioning courier/driver. Backend has no courier auth yet, so this is
/// the only way to run the app as a driver.
bool mockLoginIsCourier(String emailOrPhone) {
  final e = emailOrPhone.toLowerCase().trim();
  return e.contains('courier') ||
      e.contains('driver') ||
      _matchesMockPhone(e, mockCourierUser);
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

UserModel userModelFromConsumerRegisterParams(
  ConsumerRegisterParams p, {
  String? id,
}) {
  final newId = id ?? 'user_${p.email.hashCode.abs()}';
  return UserModel(
    id: newId,
    name: p.fullNameEn,
    email: p.email,
    phoneNumber: p.phoneNumber,
    role: UserRole.consumer,
    isVerified: false,
    joinedAt: DateTime.now(),
    dateOfBirth: p.dateOfBirth,
    fullNameEn: p.fullNameEn,
    fullNameAr: p.fullNameAr,
    token: 'mock-token-new-consumer',
    refreshToken: 'mock-refresh-token-new-consumer',
  );
}

UserModel userModelFromVendorRegisterParams(
  VendorRegisterParams p, {
  String? id,
}) {
  final newId = id ?? 'user_${p.email.hashCode.abs()}';
  final slug = p.storeNameEn
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
  final safeSlug = slug.isEmpty ? 'store' : slug;
  return UserModel(
    id: newId,
    name: p.fullNameEn,
    email: p.email,
    phoneNumber: p.phoneNumber,
    role: UserRole.vendor,
    isVerified: false,
    joinedAt: DateTime.now(),
    dateOfBirth: p.dateOfBirth,
    storeName: p.storeNameEn,
    storeSlug: safeSlug,
    storeDescription: p.storeDescriptionEn,
    whatsappNumber: p.whatsappNumber,
    fullNameEn: p.fullNameEn,
    fullNameAr: p.fullNameAr,
    storeNameEn: p.storeNameEn,
    storeNameAr: p.storeNameAr,
    storeDescriptionEn: p.storeDescriptionEn,
    storeDescriptionAr: p.storeDescriptionAr,
    storeCategoryId: p.storeCategoryId,
    storeCityId: p.storeCityId,
    storeGovernmentId: p.storeGovernmentId,
    token: 'mock-token-new-vendor',
    refreshToken: 'mock-refresh-token-new-vendor',
  );
}
