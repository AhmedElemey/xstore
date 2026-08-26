import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../../../../core/utils/jwt_payload.dart';

part 'user_model.freezed.dart';

/// Parsed GET/PUT profile wrapper (`user` + optional `store` + verification flags).
class ProfileResponseWire {
  const ProfileResponseWire({
    required this.userJson,
    this.isEmailVerificationRequired = false,
    this.isPhoneVerificationRequired = false,
    this.isEmailVerified = false,
    this.isPhoneNumberVerified = false,
    this.hasStore = false,
  });

  final Map<String, dynamic> userJson;
  final bool isEmailVerificationRequired;
  final bool isPhoneVerificationRequired;
  final bool isEmailVerified;
  final bool isPhoneNumberVerified;
  final bool hasStore;
}

int? _optInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

int? _nestedId(dynamic node) => node is Map ? _optInt(node['id']) : null;

String? _nestedPlaceName(dynamic node) {
  if (node is! Map) return null;
  String? pick(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  return pick(node['nameEn']) ?? pick(node['nameAr']) ?? pick(node['name']);
}

/// Copies city/government ids and names from [src] (user or store) onto the
/// flat user keys [UserModel.fromJson] reads.
void _flattenLocationIntoUser(
  Map<String, dynamic> user,
  Map<String, dynamic> src,
) {
  void put(String key, dynamic value) {
    if (value == null) return;
    user[key] = value;
  }

  final city = src['city'];
  final government = src['government'] ?? src['governorate'];
  put(
    'storeCityId',
    _optInt(src['cityId']) ?? _nestedId(city),
  );
  put(
    'storeGovernmentId',
    _optInt(src['governorateId']) ??
        _optInt(src['governmentId']) ??
        _nestedId(government),
  );
  put('storeCity', _nestedPlaceName(city));
  put('storeWilaya', _nestedPlaceName(government));
}

/// Maps the nested `store` object onto flat user keys [UserModel.fromJson] expects.
void mergeStoreJsonIntoUser(
  Map<String, dynamic> user,
  Map<String, dynamic> store,
) {
  void put(String key, dynamic value) {
    if (value == null) return;
    user[key] = value;
  }

  put('storeId', store['id']);
  put('storeNameEn', store['nameEn']);
  put('storeNameAr', store['nameAr']);
  put('storeDescriptionEn', store['descriptionEn']);
  put('storeDescriptionAr', store['descriptionAr']);
  put('whatsAppNumber', store['whatsAppNumber']);
  _flattenLocationIntoUser(user, store);
  put('storeCategoryId', store['storeCategoryId']);
  put('storeLogoUrl', store['storeLogoUrl']);
  put('storeCategory', store['storeCategoryNameEn']);
  put('instagramPage', store['instagramPage']);
  put('facebookPage', store['facebookPage']);
  put('latitude', store['lat']);
  put('longitude', store['lng']);
  put('location', store['detailedAddressByGoogleMaps']);
  put('detailAddress', store['detailedAddressByUser']);
  put('town', store['cityByGoogleMaps']);
  put('governorate', store['governmentByGoogleMaps']);
}

/// Parses GET/PUT `/api/auth/get-profile` and `/api/auth/update-profile` responses.
///
/// CONFIRMED live API: `{ "user": { ... }, "store": { ... } | null,
/// "isEmailVerificationRequired", "isPhoneVerificationRequired" }`.
/// Login/register return `{ "token", "refreshToken" }` only — no user object;
/// do not use this helper on those responses.
ProfileResponseWire parseProfileResponse(Map<String, dynamic> data) {
  final wrapped = data['user'];
  late final Map<String, dynamic> userJson;
  if (wrapped is Map) {
    userJson = Map<String, dynamic>.from(wrapped);
  } else if (data.containsKey('id') || data.containsKey('email')) {
    // Safety net: raw user-at-top-level (mock / legacy routes).
    userJson = Map<String, dynamic>.from(data);
  } else {
    throw const FormatException('Missing user in profile response');
  }

  // Consumers store city/government on `user`; vendors nest them on `store`.
  _flattenLocationIntoUser(userJson, userJson);
  final storeRaw = data['store'];
  final hasStore = storeRaw is Map;
  if (hasStore) {
    mergeStoreJsonIntoUser(userJson, Map<String, dynamic>.from(storeRaw));
    userJson.putIfAbsent('role', () => UserRole.vendor.name);
    userJson.putIfAbsent('roleName', () => 'Vendor');
  }

  return ProfileResponseWire(
    userJson: userJson,
    isEmailVerificationRequired:
        data['isEmailVerificationRequired'] as bool? ?? false,
    isPhoneVerificationRequired:
        data['isPhoneVerificationRequired'] as bool? ?? false,
    // Sent alongside isVerified on the user object itself (see
    // UserModel.fromJson) — isPhoneVerified is the older/alternate key some
    // responses used before isPhoneNumberVerified.
    isEmailVerified: userJson['isEmailVerified'] as bool? ?? false,
    isPhoneNumberVerified: userJson['isPhoneNumberVerified'] as bool? ??
        userJson['isPhoneVerified'] as bool? ??
        false,
    hasStore: hasStore,
  );
}

/// Builds a [UserModel] from a profile wrapper, optionally preserving session id.
UserModel userModelFromProfileResponse(
  Map<String, dynamic> data, {
  String? fallbackUserId,
  String? fallbackToken,
}) {
  final wire = parseProfileResponse(data);
  final userJson = wire.userJson;
  if (userJson['id'] == null || userJson['id'].toString().isEmpty) {
    final resolvedId = (fallbackUserId != null && fallbackUserId.isNotEmpty)
        ? fallbackUserId
        : userIdFromJwt(fallbackToken);
    if (resolvedId != null && resolvedId.isNotEmpty) {
      userJson['id'] = resolvedId;
    }
  }
  return UserModel.fromJson(userJson);
}

/// Extracts the merged user map from a profile response wrapper.
Map<String, dynamic> parseProfileUserJson(Map<String, dynamic> data) {
  return parseProfileResponse(data).userJson;
}

/// API/auth DTO. Persisted via [toJson] / [UserModel.fromJson].
@Freezed(fromJson: false, toJson: false)
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    @Default('') String name,
    required String email,
    @Default('') String phoneNumber,
    String? avatarUrl,
    @Default(UserRole.consumer) UserRole role,
    @Default(false) bool isVerified,
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
    String? token,
    String? refreshToken,
    @Default(false) bool isNewUser,
    String? fullNameEn,
    String? fullNameAr,
    String? storeNameEn,
    String? storeNameAr,
    String? storeDescriptionEn,
    String? storeDescriptionAr,
    int? storeCategoryId,
    int? storeCityId,
    int? storeGovernmentId,
    int? storeId,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parseRole() {
      // CONFIRMED: real get-profile response sends `roleName` (capitalized,
      // e.g. "Consumer"/"Vendor"), not `role`. Checked case-insensitively
      // alongside the older `role`/`isVendor` shapes for resilience.
      final r = (json['roleName'] as String?) ?? (json['role'] as String?);
      if (r != null) {
        final lower = r.toLowerCase();
        if (lower == UserRole.vendor.name) return UserRole.vendor;
        if (lower == UserRole.consumer.name) return UserRole.consumer;
        // Owner-created delivery accounts; backend naming unconfirmed, so
        // accept both "Courier" and "Delivery" until the contract is probed.
        if (lower == UserRole.courier.name || lower == 'delivery') {
          return UserRole.courier;
        }
      }
      final legacy = json['isVendor'] as bool? ?? false;
      return legacy ? UserRole.vendor : UserRole.consumer;
    }

    DateTime? parseDate(String? key, {String? altKey, bool dateOnly = false}) {
      final v = json[key] ?? (altKey != null ? json[altKey] : null);
      if (v == null) return null;
      if (v is! String) return null;
      final trimmed = v.trim();
      if (trimmed.isEmpty) return null;
      if (dateOnly) {
        // Backend sends date-only `YYYY-MM-DD` or ISO timestamps — always
        // treat the calendar date literally, not shifted by timezone.
        final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(trimmed);
        if (m != null) {
          return DateTime(
            int.parse(m.group(1)!),
            int.parse(m.group(2)!),
            int.parse(m.group(3)!),
          );
        }
      }
      final parsed = DateTime.tryParse(trimmed);
      if (parsed == null) return null;
      return dateOnly
          ? DateTime(parsed.year, parsed.month, parsed.day)
          : parsed;
    }

    String? optString(String key, {String? altKey}) {
      String? pick(dynamic v) {
        if (v == null) return null;
        final s = v is String ? v : v.toString();
        final trimmed = s.trim();
        return trimmed.isEmpty ? null : trimmed;
      }

      return pick(json[key]) ?? (altKey != null ? pick(json[altKey]) : null);
    }

    return UserModel(
      // CONFIRMED: `id` is a JSON number on the real backend, not a string.
      id: json['id']?.toString() ?? '',
      // Live name key is `fullName`; older payloads used `fullNameEn` or `name`.
      name: optString('name') ??
          optString('fullName') ??
          optString('fullNameEn') ??
          '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: parseRole(),
      // CONFIRMED: real response sends isEmailVerified/isPhoneVerified
      // alongside isVerified — isVerified is still the field to use here.
      isVerified: json['isVerified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalSales: json['totalSales'] as int?,
      // CONFIRMED: real response sends `creationDate`, not `joinedAt`.
      joinedAt: parseDate('joinedAt', altKey: 'creationDate'),
      location: optString('location'),
      // Localized store name keys before legacy storeName; use
      // UserEntity.displayStoreName(isArabic) at runtime for locale.
      storeName: optString('storeNameEn') ??
          optString('storeNameAr') ??
          optString('storeName'),
      storeSlug: json['storeSlug'] as String?,
      storeCategory: json['storeCategory'] as String?,
      // Localized keys before legacy storeDescription; profile GET nests
      // descriptionEn/Ar on store (merged to storeDescriptionEn/Ar).
      storeDescription: optString('storeDescriptionEn') ??
          optString('storeDescriptionAr') ??
          optString('storeDescription'),
      storeLogoUrl: json['storeLogoUrl'] as String?,
      storeCity: optString('storeCity') ?? _nestedPlaceName(json['city']),
      storeWilaya: optString('storeWilaya') ??
          _nestedPlaceName(json['government']) ??
          _nestedPlaceName(json['governorate']),
      // update-profile writes whatsAppNumber; get-profile may return either key.
      whatsappNumber: optString('whatsappNumber', altKey: 'whatsAppNumber'),
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble(),
      // GPS strings only — nested `governorate`/`city` objects are the
      // cascade parent and are read into storeWilaya/storeCity above.
      governorate:
          json['governorate'] is String ? optString('governorate') : null,
      town: json['town'] is String ? optString('town') : null,
      detailAddress: json['detailAddress'] as String?,
      bio: json['bio'] as String?,
      // CONFIRMED: real response sends `birthDate`, not `dateOfBirth`.
      dateOfBirth: parseDate('dateOfBirth', altKey: 'birthDate', dateOnly: true),
      // update-profile writes instagramPage; get-profile may return either key.
      instagramHandle: optString('instagramHandle', altKey: 'instagramPage'),
      facebookPage: json['facebookPage'] as String?,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isNewUser: json['isNewUser'] as bool? ?? false,
      fullNameEn: optString('fullNameEn') ?? optString('fullName'),
      fullNameAr: optString('fullNameAr'),
      storeNameEn: optString('storeNameEn'),
      storeNameAr: optString('storeNameAr'),
      storeDescriptionEn: optString('storeDescriptionEn'),
      storeDescriptionAr: optString('storeDescriptionAr'),
      storeCategoryId: _optInt(json['storeCategoryId']),
      storeCityId: _optInt(json['storeCityId']) ??
          _optInt(json['cityId']) ??
          _nestedId(json['city']),
      storeGovernmentId: _optInt(json['storeGovernmentId']) ??
          _optInt(json['governorateId']) ??
          _optInt(json['governmentId']) ??
          _nestedId(json['government']) ??
          _nestedId(json['governorate']),
      storeId: (json['storeId'] as num?)?.toInt(),
    );
  }
}

extension UserModelX on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        role: role,
        isVerified: isVerified,
        rating: rating,
        totalSales: totalSales,
        joinedAt: joinedAt,
        location: location,
        storeName: storeName,
        storeSlug: storeSlug,
        storeCategory: storeCategory,
        storeDescription: storeDescription,
        storeLogoUrl: storeLogoUrl,
        storeCity: storeCity,
        storeWilaya: storeWilaya,
        whatsappNumber: whatsappNumber,
        latitude: latitude,
        longitude: longitude,
        governorate: governorate,
        town: town,
        detailAddress: detailAddress,
        bio: bio,
        dateOfBirth: dateOfBirth,
        instagramHandle: instagramHandle,
        facebookPage: facebookPage,
        isNewUser: isNewUser,
        fullNameEn: fullNameEn,
        fullNameAr: fullNameAr,
        storeNameEn: storeNameEn,
        storeNameAr: storeNameAr,
        storeDescriptionEn: storeDescriptionEn,
        storeDescriptionAr: storeDescriptionAr,
        storeCategoryId: storeCategoryId,
        storeCityId: storeCityId,
        storeGovernmentId: storeGovernmentId,
        storeId: storeId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'role': role.name,
        'isVendor': role == UserRole.vendor,
        'isVerified': isVerified,
        if (rating != null) 'rating': rating,
        if (totalSales != null) 'totalSales': totalSales,
        if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
        if (location != null) 'location': location,
        if (storeName != null) 'storeName': storeName,
        if (storeSlug != null) 'storeSlug': storeSlug,
        if (storeCategory != null) 'storeCategory': storeCategory,
        if (storeDescription != null) 'storeDescription': storeDescription,
        if (storeLogoUrl != null) 'storeLogoUrl': storeLogoUrl,
        if (storeCity != null) 'storeCity': storeCity,
        if (storeWilaya != null) 'storeWilaya': storeWilaya,
        if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (governorate != null) 'governorate': governorate,
        if (town != null) 'town': town,
        if (detailAddress != null) 'detailAddress': detailAddress,
        if (bio != null) 'bio': bio,
        if (dateOfBirth != null)
          'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (instagramHandle != null) 'instagramHandle': instagramHandle,
        if (facebookPage != null) 'facebookPage': facebookPage,
        if (token != null) 'token': token,
        if (refreshToken != null) 'refreshToken': refreshToken,
        'isNewUser': isNewUser,
        if (fullNameEn != null) 'fullNameEn': fullNameEn,
        if (fullNameAr != null) 'fullNameAr': fullNameAr,
        if (storeNameEn != null) 'storeNameEn': storeNameEn,
        if (storeNameAr != null) 'storeNameAr': storeNameAr,
        if (storeDescriptionEn != null)
          'storeDescriptionEn': storeDescriptionEn,
        if (storeDescriptionAr != null)
          'storeDescriptionAr': storeDescriptionAr,
        if (storeCategoryId != null) 'storeCategoryId': storeCategoryId,
        if (storeCityId != null) 'storeCityId': storeCityId,
        if (storeGovernmentId != null) 'storeGovernmentId': storeGovernmentId,
        if (storeId != null) 'storeId': storeId,
      };
}
