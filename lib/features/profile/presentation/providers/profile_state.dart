import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/update_profile_request.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    ProfileEntity? profile,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    // Edit form
    @Default('') String editName,
    @Default('') String editFullNameAr,
    @Default('') String editEmail,
    @Default('') String editPhone,
    @Default('') String editLocation,
    @Default('') String editBio,
    File? editAvatarFile,
    @Default(false) bool avatarRemoved,
    File? editStoreLogoFile,
    @Default(false) bool storeLogoRemoved,
    @Default('') String editStoreName,
    @Default('') String editStoreNameAr,
    @Default('') String editStoreCategory,
    @Default('') String editStoreDescription,
    @Default('') String editStoreDescriptionAr,
    @Default('') String editStoreCity,
    @Default('') String editStoreWilaya,
    @Default('') String editWhatsapp,
    @Default('') String editLatitude,
    @Default('') String editLongitude,
    @Default('') String editGovernorate,
    @Default('') String editTown,
    @Default('') String editDetailAddress,
    @Default(false) bool isDetectingLocation,
    String? locationError,
    String? locationAction,
    DateTime? editDateOfBirth,
    @Default('') String editInstagram,
    @Default('') String editFacebook,
    // Preferences
    @Default(false) bool isDarkMode,
    @Default(true) bool pushNotificationsEnabled,
    @Default(true) bool emailUpdatesEnabled,
    @Default(false) bool hasChanges,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _ProfileState;
}

extension ProfileStateX on ProfileState {
  UserEntity? get user => profile?.user;

  ProfileState applyFromProfile(
    ProfileEntity p, {
    required bool isDarkMode,
    required bool pushNotificationsEnabled,
    required bool emailUpdatesEnabled,
  }) {
    final u = p.user;
    return copyWith(
      profile: p,
      error: null,
      editName: u.name,
      editFullNameAr: u.fullNameAr ?? '',
      editEmail: u.email,
      editPhone: u.phoneNumber,
      editLocation: u.location ?? '',
      editBio: u.bio ?? '',
      editStoreName: u.storeName ?? '',
      editStoreNameAr: u.storeNameAr ?? '',
      editStoreCategory: u.storeCategory ?? '',
      editStoreDescription: u.storeDescription ?? '',
      editStoreDescriptionAr: u.storeDescriptionAr ?? '',
      editStoreCity: u.storeCity ?? '',
      editStoreWilaya: u.storeWilaya ?? '',
      editWhatsapp: u.whatsappNumber ?? '',
      editLatitude: u.latitude == null ? '' : u.latitude!.toStringAsFixed(6),
      editLongitude: u.longitude == null ? '' : u.longitude!.toStringAsFixed(6),
      editGovernorate: u.governorate ?? '',
      editTown: u.town ?? '',
      editDetailAddress: u.detailAddress ?? '',
      isDetectingLocation: false,
      locationError: null,
      locationAction: null,
      editDateOfBirth: u.dateOfBirth,
      editInstagram: u.instagramHandle ?? '',
      editFacebook: u.facebookPage ?? '',
      editAvatarFile: null,
      avatarRemoved: false,
      editStoreLogoFile: null,
      storeLogoRemoved: false,
      isDarkMode: isDarkMode,
      pushNotificationsEnabled: pushNotificationsEnabled,
      emailUpdatesEnabled: emailUpdatesEnabled,
      hasChanges: false,
      fieldErrors: {},
    );
  }

  UpdateProfileRequest toUpdateProfileRequest() {
    final u = user;
    if (u == null) {
      throw StateError('No profile loaded');
    }

    String? trim(String value) {
      final t = value.trim();
      return t.isEmpty ? null : t;
    }

    double? parseCoord(String value) {
      final t = value.trim();
      if (t.isEmpty) return null;
      return double.tryParse(t);
    }

    return UpdateProfileRequest(
      fullNameEn: trim(editName),
      fullNameAr: trim(editFullNameAr),
      userImageUrl: avatarRemoved ? null : u.avatarUrl,
      storeImageUrl: storeLogoRemoved ? null : u.storeLogoUrl,
      storeNameEn: trim(editStoreName),
      storeNameAr: trim(editStoreNameAr),
      storeDescriptionEn: trim(editStoreDescription),
      storeDescriptionAr: trim(editStoreDescriptionAr),
      whatsAppNumber: trim(editWhatsapp),
      instagramPage: trim(editInstagram),
      facebookPage: trim(editFacebook),
      detailedAddressByGoogleMaps: trim(editLocation),
      detailedAddressByUser: trim(editDetailAddress),
      cityByGoogleMaps: trim(editTown),
      governmentByGoogleMaps: trim(editGovernorate),
      userImagePath: editAvatarFile?.path,
      storeImagePath: editStoreLogoFile?.path,
      lat: parseCoord(editLatitude),
      lng: parseCoord(editLongitude),
      storeCategoryId: u.storeCategoryId,
      cityId: u.storeCityId,
      governmentId: u.storeGovernmentId,
      birthDate: editDateOfBirth,
    );
  }
}
