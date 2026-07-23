// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int? get totalSales => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError; // Vendor profile
  String? get storeName => throw _privateConstructorUsedError;
  String? get storeSlug => throw _privateConstructorUsedError;
  String? get storeCategory => throw _privateConstructorUsedError;
  String? get storeDescription => throw _privateConstructorUsedError;
  String? get storeLogoUrl => throw _privateConstructorUsedError;
  String? get storeCity => throw _privateConstructorUsedError;
  String? get storeWilaya => throw _privateConstructorUsedError;
  String? get whatsappNumber => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get governorate => throw _privateConstructorUsedError;
  String? get town => throw _privateConstructorUsedError;
  String? get detailAddress => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get instagramHandle => throw _privateConstructorUsedError;
  String? get facebookPage => throw _privateConstructorUsedError;
  bool get isNewUser =>
      throw _privateConstructorUsedError; // --- Bilingual/backend-ID fields (Phase 1 backend integration) ---
// Additive: legacy fields above are kept so unrelated screens keep
// working. [name] is populated from [fullNameEn] on login/register for
// backward compatibility — see UserModel.fromJson.
  String? get fullNameEn => throw _privateConstructorUsedError;
  String? get fullNameAr => throw _privateConstructorUsedError;
  String? get storeNameEn => throw _privateConstructorUsedError;
  String? get storeNameAr => throw _privateConstructorUsedError;
  String? get storeDescriptionEn => throw _privateConstructorUsedError;
  String? get storeDescriptionAr => throw _privateConstructorUsedError;
  int? get storeCategoryId => throw _privateConstructorUsedError;
  int? get storeCityId => throw _privateConstructorUsedError;
  int? get storeGovernmentId => throw _privateConstructorUsedError;
  int? get storeId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserEntityCopyWith<UserEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserEntityCopyWith<$Res> {
  factory $UserEntityCopyWith(
          UserEntity value, $Res Function(UserEntity) then) =
      _$UserEntityCopyWithImpl<$Res, UserEntity>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phoneNumber,
      String? avatarUrl,
      UserRole role,
      bool isVerified,
      double? rating,
      int? totalSales,
      DateTime? joinedAt,
      String? location,
      String? storeName,
      String? storeSlug,
      String? storeCategory,
      String? storeDescription,
      String? storeLogoUrl,
      String? storeCity,
      String? storeWilaya,
      String? whatsappNumber,
      double? latitude,
      double? longitude,
      String? governorate,
      String? town,
      String? detailAddress,
      String? bio,
      DateTime? dateOfBirth,
      String? instagramHandle,
      String? facebookPage,
      bool isNewUser,
      String? fullNameEn,
      String? fullNameAr,
      String? storeNameEn,
      String? storeNameAr,
      String? storeDescriptionEn,
      String? storeDescriptionAr,
      int? storeCategoryId,
      int? storeCityId,
      int? storeGovernmentId,
      int? storeId});
}

/// @nodoc
class _$UserEntityCopyWithImpl<$Res, $Val extends UserEntity>
    implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? isVerified = null,
    Object? rating = freezed,
    Object? totalSales = freezed,
    Object? joinedAt = freezed,
    Object? location = freezed,
    Object? storeName = freezed,
    Object? storeSlug = freezed,
    Object? storeCategory = freezed,
    Object? storeDescription = freezed,
    Object? storeLogoUrl = freezed,
    Object? storeCity = freezed,
    Object? storeWilaya = freezed,
    Object? whatsappNumber = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? governorate = freezed,
    Object? town = freezed,
    Object? detailAddress = freezed,
    Object? bio = freezed,
    Object? dateOfBirth = freezed,
    Object? instagramHandle = freezed,
    Object? facebookPage = freezed,
    Object? isNewUser = null,
    Object? fullNameEn = freezed,
    Object? fullNameAr = freezed,
    Object? storeNameEn = freezed,
    Object? storeNameAr = freezed,
    Object? storeDescriptionEn = freezed,
    Object? storeDescriptionAr = freezed,
    Object? storeCategoryId = freezed,
    Object? storeCityId = freezed,
    Object? storeGovernmentId = freezed,
    Object? storeId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalSales: freezed == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as int?,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      storeName: freezed == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String?,
      storeSlug: freezed == storeSlug
          ? _value.storeSlug
          : storeSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCategory: freezed == storeCategory
          ? _value.storeCategory
          : storeCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      storeDescription: freezed == storeDescription
          ? _value.storeDescription
          : storeDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      storeLogoUrl: freezed == storeLogoUrl
          ? _value.storeLogoUrl
          : storeLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCity: freezed == storeCity
          ? _value.storeCity
          : storeCity // ignore: cast_nullable_to_non_nullable
              as String?,
      storeWilaya: freezed == storeWilaya
          ? _value.storeWilaya
          : storeWilaya // ignore: cast_nullable_to_non_nullable
              as String?,
      whatsappNumber: freezed == whatsappNumber
          ? _value.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      governorate: freezed == governorate
          ? _value.governorate
          : governorate // ignore: cast_nullable_to_non_nullable
              as String?,
      town: freezed == town
          ? _value.town
          : town // ignore: cast_nullable_to_non_nullable
              as String?,
      detailAddress: freezed == detailAddress
          ? _value.detailAddress
          : detailAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      instagramHandle: freezed == instagramHandle
          ? _value.instagramHandle
          : instagramHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      facebookPage: freezed == facebookPage
          ? _value.facebookPage
          : facebookPage // ignore: cast_nullable_to_non_nullable
              as String?,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
      fullNameEn: freezed == fullNameEn
          ? _value.fullNameEn
          : fullNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      fullNameAr: freezed == fullNameAr
          ? _value.fullNameAr
          : fullNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      storeNameEn: freezed == storeNameEn
          ? _value.storeNameEn
          : storeNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      storeNameAr: freezed == storeNameAr
          ? _value.storeNameAr
          : storeNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      storeDescriptionEn: freezed == storeDescriptionEn
          ? _value.storeDescriptionEn
          : storeDescriptionEn // ignore: cast_nullable_to_non_nullable
              as String?,
      storeDescriptionAr: freezed == storeDescriptionAr
          ? _value.storeDescriptionAr
          : storeDescriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCategoryId: freezed == storeCategoryId
          ? _value.storeCategoryId
          : storeCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeCityId: freezed == storeCityId
          ? _value.storeCityId
          : storeCityId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeGovernmentId: freezed == storeGovernmentId
          ? _value.storeGovernmentId
          : storeGovernmentId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeId: freezed == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserEntityImplCopyWith<$Res>
    implements $UserEntityCopyWith<$Res> {
  factory _$$UserEntityImplCopyWith(
          _$UserEntityImpl value, $Res Function(_$UserEntityImpl) then) =
      __$$UserEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phoneNumber,
      String? avatarUrl,
      UserRole role,
      bool isVerified,
      double? rating,
      int? totalSales,
      DateTime? joinedAt,
      String? location,
      String? storeName,
      String? storeSlug,
      String? storeCategory,
      String? storeDescription,
      String? storeLogoUrl,
      String? storeCity,
      String? storeWilaya,
      String? whatsappNumber,
      double? latitude,
      double? longitude,
      String? governorate,
      String? town,
      String? detailAddress,
      String? bio,
      DateTime? dateOfBirth,
      String? instagramHandle,
      String? facebookPage,
      bool isNewUser,
      String? fullNameEn,
      String? fullNameAr,
      String? storeNameEn,
      String? storeNameAr,
      String? storeDescriptionEn,
      String? storeDescriptionAr,
      int? storeCategoryId,
      int? storeCityId,
      int? storeGovernmentId,
      int? storeId});
}

/// @nodoc
class __$$UserEntityImplCopyWithImpl<$Res>
    extends _$UserEntityCopyWithImpl<$Res, _$UserEntityImpl>
    implements _$$UserEntityImplCopyWith<$Res> {
  __$$UserEntityImplCopyWithImpl(
      _$UserEntityImpl _value, $Res Function(_$UserEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? isVerified = null,
    Object? rating = freezed,
    Object? totalSales = freezed,
    Object? joinedAt = freezed,
    Object? location = freezed,
    Object? storeName = freezed,
    Object? storeSlug = freezed,
    Object? storeCategory = freezed,
    Object? storeDescription = freezed,
    Object? storeLogoUrl = freezed,
    Object? storeCity = freezed,
    Object? storeWilaya = freezed,
    Object? whatsappNumber = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? governorate = freezed,
    Object? town = freezed,
    Object? detailAddress = freezed,
    Object? bio = freezed,
    Object? dateOfBirth = freezed,
    Object? instagramHandle = freezed,
    Object? facebookPage = freezed,
    Object? isNewUser = null,
    Object? fullNameEn = freezed,
    Object? fullNameAr = freezed,
    Object? storeNameEn = freezed,
    Object? storeNameAr = freezed,
    Object? storeDescriptionEn = freezed,
    Object? storeDescriptionAr = freezed,
    Object? storeCategoryId = freezed,
    Object? storeCityId = freezed,
    Object? storeGovernmentId = freezed,
    Object? storeId = freezed,
  }) {
    return _then(_$UserEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalSales: freezed == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as int?,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      storeName: freezed == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String?,
      storeSlug: freezed == storeSlug
          ? _value.storeSlug
          : storeSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCategory: freezed == storeCategory
          ? _value.storeCategory
          : storeCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      storeDescription: freezed == storeDescription
          ? _value.storeDescription
          : storeDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      storeLogoUrl: freezed == storeLogoUrl
          ? _value.storeLogoUrl
          : storeLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCity: freezed == storeCity
          ? _value.storeCity
          : storeCity // ignore: cast_nullable_to_non_nullable
              as String?,
      storeWilaya: freezed == storeWilaya
          ? _value.storeWilaya
          : storeWilaya // ignore: cast_nullable_to_non_nullable
              as String?,
      whatsappNumber: freezed == whatsappNumber
          ? _value.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      governorate: freezed == governorate
          ? _value.governorate
          : governorate // ignore: cast_nullable_to_non_nullable
              as String?,
      town: freezed == town
          ? _value.town
          : town // ignore: cast_nullable_to_non_nullable
              as String?,
      detailAddress: freezed == detailAddress
          ? _value.detailAddress
          : detailAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      instagramHandle: freezed == instagramHandle
          ? _value.instagramHandle
          : instagramHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      facebookPage: freezed == facebookPage
          ? _value.facebookPage
          : facebookPage // ignore: cast_nullable_to_non_nullable
              as String?,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
      fullNameEn: freezed == fullNameEn
          ? _value.fullNameEn
          : fullNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      fullNameAr: freezed == fullNameAr
          ? _value.fullNameAr
          : fullNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      storeNameEn: freezed == storeNameEn
          ? _value.storeNameEn
          : storeNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      storeNameAr: freezed == storeNameAr
          ? _value.storeNameAr
          : storeNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      storeDescriptionEn: freezed == storeDescriptionEn
          ? _value.storeDescriptionEn
          : storeDescriptionEn // ignore: cast_nullable_to_non_nullable
              as String?,
      storeDescriptionAr: freezed == storeDescriptionAr
          ? _value.storeDescriptionAr
          : storeDescriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCategoryId: freezed == storeCategoryId
          ? _value.storeCategoryId
          : storeCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeCityId: freezed == storeCityId
          ? _value.storeCityId
          : storeCityId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeGovernmentId: freezed == storeGovernmentId
          ? _value.storeGovernmentId
          : storeGovernmentId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeId: freezed == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$UserEntityImpl extends _UserEntity {
  const _$UserEntityImpl(
      {required this.id,
      required this.name,
      required this.email,
      required this.phoneNumber,
      this.avatarUrl,
      this.role = UserRole.consumer,
      this.isVerified = false,
      this.rating,
      this.totalSales,
      this.joinedAt,
      this.location,
      this.storeName,
      this.storeSlug,
      this.storeCategory,
      this.storeDescription,
      this.storeLogoUrl,
      this.storeCity,
      this.storeWilaya,
      this.whatsappNumber,
      this.latitude,
      this.longitude,
      this.governorate,
      this.town,
      this.detailAddress,
      this.bio,
      this.dateOfBirth,
      this.instagramHandle,
      this.facebookPage,
      this.isNewUser = false,
      this.fullNameEn,
      this.fullNameAr,
      this.storeNameEn,
      this.storeNameAr,
      this.storeDescriptionEn,
      this.storeDescriptionAr,
      this.storeCategoryId,
      this.storeCityId,
      this.storeGovernmentId,
      this.storeId})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String phoneNumber;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final UserRole role;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final double? rating;
  @override
  final int? totalSales;
  @override
  final DateTime? joinedAt;
  @override
  final String? location;
// Vendor profile
  @override
  final String? storeName;
  @override
  final String? storeSlug;
  @override
  final String? storeCategory;
  @override
  final String? storeDescription;
  @override
  final String? storeLogoUrl;
  @override
  final String? storeCity;
  @override
  final String? storeWilaya;
  @override
  final String? whatsappNumber;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? governorate;
  @override
  final String? town;
  @override
  final String? detailAddress;
  @override
  final String? bio;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? instagramHandle;
  @override
  final String? facebookPage;
  @override
  @JsonKey()
  final bool isNewUser;
// --- Bilingual/backend-ID fields (Phase 1 backend integration) ---
// Additive: legacy fields above are kept so unrelated screens keep
// working. [name] is populated from [fullNameEn] on login/register for
// backward compatibility — see UserModel.fromJson.
  @override
  final String? fullNameEn;
  @override
  final String? fullNameAr;
  @override
  final String? storeNameEn;
  @override
  final String? storeNameAr;
  @override
  final String? storeDescriptionEn;
  @override
  final String? storeDescriptionAr;
  @override
  final int? storeCategoryId;
  @override
  final int? storeCityId;
  @override
  final int? storeGovernmentId;
  @override
  final int? storeId;

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, role: $role, isVerified: $isVerified, rating: $rating, totalSales: $totalSales, joinedAt: $joinedAt, location: $location, storeName: $storeName, storeSlug: $storeSlug, storeCategory: $storeCategory, storeDescription: $storeDescription, storeLogoUrl: $storeLogoUrl, storeCity: $storeCity, storeWilaya: $storeWilaya, whatsappNumber: $whatsappNumber, latitude: $latitude, longitude: $longitude, governorate: $governorate, town: $town, detailAddress: $detailAddress, bio: $bio, dateOfBirth: $dateOfBirth, instagramHandle: $instagramHandle, facebookPage: $facebookPage, isNewUser: $isNewUser, fullNameEn: $fullNameEn, fullNameAr: $fullNameAr, storeNameEn: $storeNameEn, storeNameAr: $storeNameAr, storeDescriptionEn: $storeDescriptionEn, storeDescriptionAr: $storeDescriptionAr, storeCategoryId: $storeCategoryId, storeCityId: $storeCityId, storeGovernmentId: $storeGovernmentId, storeId: $storeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeSlug, storeSlug) ||
                other.storeSlug == storeSlug) &&
            (identical(other.storeCategory, storeCategory) ||
                other.storeCategory == storeCategory) &&
            (identical(other.storeDescription, storeDescription) ||
                other.storeDescription == storeDescription) &&
            (identical(other.storeLogoUrl, storeLogoUrl) ||
                other.storeLogoUrl == storeLogoUrl) &&
            (identical(other.storeCity, storeCity) ||
                other.storeCity == storeCity) &&
            (identical(other.storeWilaya, storeWilaya) ||
                other.storeWilaya == storeWilaya) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.governorate, governorate) ||
                other.governorate == governorate) &&
            (identical(other.town, town) || other.town == town) &&
            (identical(other.detailAddress, detailAddress) ||
                other.detailAddress == detailAddress) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.instagramHandle, instagramHandle) ||
                other.instagramHandle == instagramHandle) &&
            (identical(other.facebookPage, facebookPage) ||
                other.facebookPage == facebookPage) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser) &&
            (identical(other.fullNameEn, fullNameEn) ||
                other.fullNameEn == fullNameEn) &&
            (identical(other.fullNameAr, fullNameAr) ||
                other.fullNameAr == fullNameAr) &&
            (identical(other.storeNameEn, storeNameEn) ||
                other.storeNameEn == storeNameEn) &&
            (identical(other.storeNameAr, storeNameAr) ||
                other.storeNameAr == storeNameAr) &&
            (identical(other.storeDescriptionEn, storeDescriptionEn) ||
                other.storeDescriptionEn == storeDescriptionEn) &&
            (identical(other.storeDescriptionAr, storeDescriptionAr) ||
                other.storeDescriptionAr == storeDescriptionAr) &&
            (identical(other.storeCategoryId, storeCategoryId) ||
                other.storeCategoryId == storeCategoryId) &&
            (identical(other.storeCityId, storeCityId) ||
                other.storeCityId == storeCityId) &&
            (identical(other.storeGovernmentId, storeGovernmentId) ||
                other.storeGovernmentId == storeGovernmentId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        email,
        phoneNumber,
        avatarUrl,
        role,
        isVerified,
        rating,
        totalSales,
        joinedAt,
        location,
        storeName,
        storeSlug,
        storeCategory,
        storeDescription,
        storeLogoUrl,
        storeCity,
        storeWilaya,
        whatsappNumber,
        latitude,
        longitude,
        governorate,
        town,
        detailAddress,
        bio,
        dateOfBirth,
        instagramHandle,
        facebookPage,
        isNewUser,
        fullNameEn,
        fullNameAr,
        storeNameEn,
        storeNameAr,
        storeDescriptionEn,
        storeDescriptionAr,
        storeCategoryId,
        storeCityId,
        storeGovernmentId,
        storeId
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserEntityImplCopyWith<_$UserEntityImpl> get copyWith =>
      __$$UserEntityImplCopyWithImpl<_$UserEntityImpl>(this, _$identity);
}

abstract class _UserEntity extends UserEntity {
  const factory _UserEntity(
      {required final String id,
      required final String name,
      required final String email,
      required final String phoneNumber,
      final String? avatarUrl,
      final UserRole role,
      final bool isVerified,
      final double? rating,
      final int? totalSales,
      final DateTime? joinedAt,
      final String? location,
      final String? storeName,
      final String? storeSlug,
      final String? storeCategory,
      final String? storeDescription,
      final String? storeLogoUrl,
      final String? storeCity,
      final String? storeWilaya,
      final String? whatsappNumber,
      final double? latitude,
      final double? longitude,
      final String? governorate,
      final String? town,
      final String? detailAddress,
      final String? bio,
      final DateTime? dateOfBirth,
      final String? instagramHandle,
      final String? facebookPage,
      final bool isNewUser,
      final String? fullNameEn,
      final String? fullNameAr,
      final String? storeNameEn,
      final String? storeNameAr,
      final String? storeDescriptionEn,
      final String? storeDescriptionAr,
      final int? storeCategoryId,
      final int? storeCityId,
      final int? storeGovernmentId,
      final int? storeId}) = _$UserEntityImpl;
  const _UserEntity._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String get phoneNumber;
  @override
  String? get avatarUrl;
  @override
  UserRole get role;
  @override
  bool get isVerified;
  @override
  double? get rating;
  @override
  int? get totalSales;
  @override
  DateTime? get joinedAt;
  @override
  String? get location;
  @override // Vendor profile
  String? get storeName;
  @override
  String? get storeSlug;
  @override
  String? get storeCategory;
  @override
  String? get storeDescription;
  @override
  String? get storeLogoUrl;
  @override
  String? get storeCity;
  @override
  String? get storeWilaya;
  @override
  String? get whatsappNumber;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get governorate;
  @override
  String? get town;
  @override
  String? get detailAddress;
  @override
  String? get bio;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get instagramHandle;
  @override
  String? get facebookPage;
  @override
  bool get isNewUser;
  @override // --- Bilingual/backend-ID fields (Phase 1 backend integration) ---
// Additive: legacy fields above are kept so unrelated screens keep
// working. [name] is populated from [fullNameEn] on login/register for
// backward compatibility — see UserModel.fromJson.
  String? get fullNameEn;
  @override
  String? get fullNameAr;
  @override
  String? get storeNameEn;
  @override
  String? get storeNameAr;
  @override
  String? get storeDescriptionEn;
  @override
  String? get storeDescriptionAr;
  @override
  int? get storeCategoryId;
  @override
  int? get storeCityId;
  @override
  int? get storeGovernmentId;
  @override
  int? get storeId;
  @override
  @JsonKey(ignore: true)
  _$$UserEntityImplCopyWith<_$UserEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
