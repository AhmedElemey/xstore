import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';

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
      isDarkMode: isDarkMode,
      pushNotificationsEnabled: pushNotificationsEnabled,
      emailUpdatesEnabled: emailUpdatesEnabled,
      hasChanges: false,
      fieldErrors: {},
    );
  }

  UserEntity toEditedUser() {
    final u = user;
    if (u == null) {
      throw StateError('No profile loaded');
    }
    // When [avatarRemoved] is true, avatarUrl is null so update-profile sends
    // an explicit null and the server clears the stored avatar.
    return u.copyWith(
      name: editName.trim(),
      email: editEmail.trim(),
      phoneNumber: editPhone.trim(),
      avatarUrl: avatarRemoved ? null : u.avatarUrl,
      location: editLocation.trim().isEmpty ? null : editLocation.trim(),
      bio: editBio.trim().isEmpty ? null : editBio.trim(),
      storeName: editStoreName.trim().isEmpty ? null : editStoreName.trim(),
      storeCategory:
          editStoreCategory.trim().isEmpty ? null : editStoreCategory.trim(),
      storeDescription: editStoreDescription.trim().isEmpty
          ? null
          : editStoreDescription.trim(),
      storeCity: editStoreCity.trim().isEmpty ? null : editStoreCity.trim(),
      // Bilingual fields sent to /api/auth/update-profile.
      fullNameEn: editName.trim().isEmpty ? null : editName.trim(),
      fullNameAr: editFullNameAr.trim().isEmpty ? null : editFullNameAr.trim(),
      storeNameEn:
          editStoreName.trim().isEmpty ? null : editStoreName.trim(),
      storeNameAr:
          editStoreNameAr.trim().isEmpty ? null : editStoreNameAr.trim(),
      storeDescriptionEn: editStoreDescription.trim().isEmpty
          ? null
          : editStoreDescription.trim(),
      storeDescriptionAr: editStoreDescriptionAr.trim().isEmpty
          ? null
          : editStoreDescriptionAr.trim(),
      storeWilaya:
          editStoreWilaya.trim().isEmpty ? null : editStoreWilaya.trim(),
      whatsappNumber:
          editWhatsapp.trim().isEmpty ? null : editWhatsapp.trim(),
      latitude: editLatitude.trim().isEmpty ? null : double.tryParse(editLatitude.trim()),
      longitude: editLongitude.trim().isEmpty ? null : double.tryParse(editLongitude.trim()),
      governorate: editGovernorate.trim().isEmpty ? null : editGovernorate.trim(),
      town: editTown.trim().isEmpty ? null : editTown.trim(),
      detailAddress: editDetailAddress.trim().isEmpty ? null : editDetailAddress.trim(),
      dateOfBirth: editDateOfBirth,
      instagramHandle:
          editInstagram.trim().isEmpty ? null : editInstagram.trim(),
      facebookPage:
          editFacebook.trim().isEmpty ? null : editFacebook.trim(),
    );
  }
}
