import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'profile_dependencies.dart';
import 'profile_state.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../core/utils/location_service.dart';

part 'profile_provider.g.dart';

/// Schedules an enriched profile reload without blocking the caller (login,
/// cold start, etc.). Single entry point for "warm profileNotifierProvider".
///
/// Pass [user] when the caller already knows the session user and
/// `authProvider` may still read as Loading — e.g. from inside `Auth.build()`,
/// where reading it back would return null and skip the fetch.
void prefetchProfileData(Ref ref, {UserEntity? user}) {
  if (kDebugMode) {
    debugPrint('[ProfileNotifier] prefetchProfileData scheduled');
  }
  unawaited(
    ref.read(profileNotifierProvider.notifier).refreshProfileData(user: user),
  );
}

/// Clears enriched profile state on logout so the next session starts fresh.
void resetProfileData(Ref ref) {
  ref.invalidate(profileNotifierProvider);
}

bool _isDarkTheme(ThemeMode mode) {
  if (mode == ThemeMode.dark) return true;
  if (mode == ThemeMode.light) return false;
  return SchedulerBinding
          .instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
}

bool _profileEditEqualsUser(ProfileState s, UserEntity u) {
  return s.editName.trim() == u.name.trim() &&
      s.editEmail.trim() == u.email.trim() &&
      s.editPhone.trim() == u.phoneNumber.trim() &&
      s.editLocation.trim() == (u.location ?? '').trim() &&
      s.editBio.trim() == (u.bio ?? '').trim() &&
      s.editFullNameAr.trim() == (u.fullNameAr ?? '').trim() &&
      s.editStoreName.trim() == (u.storeName ?? '').trim() &&
      s.editStoreNameAr.trim() == (u.storeNameAr ?? '').trim() &&
      s.editStoreCategory.trim() == (u.storeCategory ?? '').trim() &&
      s.editStoreDescription.trim() == (u.storeDescription ?? '').trim() &&
      s.editStoreDescriptionAr.trim() ==
          (u.storeDescriptionAr ?? '').trim() &&
      s.editStoreCity.trim() == (u.storeCity ?? '').trim() &&
      s.editStoreWilaya.trim() == (u.storeWilaya ?? '').trim() &&
      s.editWhatsapp.trim() == (u.whatsappNumber ?? '').trim() &&
      s.editLatitude.trim() == ((u.latitude == null) ? '' : u.latitude!.toStringAsFixed(6)) &&
      s.editLongitude.trim() == ((u.longitude == null) ? '' : u.longitude!.toStringAsFixed(6)) &&
      s.editGovernorate.trim() == (u.governorate ?? '').trim() &&
      s.editTown.trim() == (u.town ?? '').trim() &&
      s.editDetailAddress.trim() == (u.detailAddress ?? '').trim() &&
      s.editDateOfBirth == u.dateOfBirth &&
      s.editInstagram.trim() == (u.instagramHandle ?? '').trim() &&
      s.editFacebook.trim() == (u.facebookPage ?? '').trim() &&
      s.editAvatarFile == null &&
      !s.avatarRemoved;
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  // Bumped by ref.onDispose, which also fires on invalidate (resetProfileData
  // on logout / forced 401). In-flight refreshes compare their epoch so a
  // fetch from the previous session never writes into the next one. A plain
  // _disposed flag is not enough here: keepAlive invalidate reuses this
  // instance and build() would reset the flag, reopening the gate.
  var _sessionEpoch = 0;

  @override
  ProfileState build() {
    ref.onDispose(() => _sessionEpoch++);
    return const ProfileState();
  }

  /// Reloads enriched profile + stats from the server. Use this (not ad-hoc
  /// fetches) whenever profileNotifierProvider should sync with the backend.
  ///
  /// [user] overrides the `authProvider` read for callers holding the session
  /// user while `authProvider` is still Loading (see [prefetchProfileData]).
  Future<void> refreshProfileData({UserEntity? user}) async {
    final sessionUser = user ?? ref.read(authProvider).valueOrNull;
    if (sessionUser == null) {
      state = const ProfileState();
      return;
    }

    final epoch = _sessionEpoch;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (epoch != _sessionEpoch) return;
      final push = prefs.getBool(PrefsKeys.profilePushNotifications) ?? true;
      final email = prefs.getBool(PrefsKeys.profileEmailUpdates) ?? true;
      final themeMode = ref.read(appThemeModeProvider);

      final result =
          await ref.read(getProfileUseCaseProvider).call(sessionUser);
      if (epoch != _sessionEpoch) return;
      result.fold(
        (f) {
          state = state.copyWith(isLoading: false, error: f.toString());
        },
        (profile) {
          if (kDebugMode) {
            debugPrint(
              '[ProfileNotifier] refreshProfileData OK — '
              'orders=${profile.ordersCount} '
              'wishlist=${profile.wishlistCount} '
              'role=${profile.user.role.name}',
            );
          }
          state = state
              .applyFromProfile(
                profile,
                isDarkMode: _isDarkTheme(themeMode),
                pushNotificationsEnabled: push,
                emailUpdatesEnabled: email,
              )
              .copyWith(isLoading: false);
        },
      );
    } catch (e) {
      if (epoch != _sessionEpoch) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateField(String field, dynamic value) {
    var next = state;
    switch (field) {
      case 'name':
        next = next.copyWith(editName: value as String);
        break;
      case 'fullNameAr':
        next = next.copyWith(editFullNameAr: value as String);
        break;
      case 'email':
        next = next.copyWith(editEmail: value as String);
        break;
      case 'phone':
        next = next.copyWith(editPhone: value as String);
        break;
      case 'location':
        next = next.copyWith(editLocation: value as String);
        break;
      case 'bio':
        next = next.copyWith(editBio: value as String);
        break;
      case 'storeName':
        next = next.copyWith(editStoreName: value as String);
        break;
      case 'storeNameAr':
        next = next.copyWith(editStoreNameAr: value as String);
        break;
      case 'storeCategory':
        next = next.copyWith(editStoreCategory: value as String);
        break;
      case 'storeDescription':
        next = next.copyWith(editStoreDescription: value as String);
        break;
      case 'storeDescriptionAr':
        next = next.copyWith(editStoreDescriptionAr: value as String);
        break;
      case 'storeCity':
        next = next.copyWith(editStoreCity: value as String);
        break;
      case 'storeWilaya':
        next = next.copyWith(editStoreWilaya: value as String);
        break;
      case 'whatsapp':
        next = next.copyWith(editWhatsapp: value as String);
        break;
      case 'dateOfBirth':
        next = next.copyWith(editDateOfBirth: value as DateTime?);
        break;
      case 'latitude':
        next = next.copyWith(editLatitude: value as String);
        break;
      case 'longitude':
        next = next.copyWith(editLongitude: value as String);
        break;
      case 'governorate':
        next = next.copyWith(editGovernorate: value as String);
        break;
      case 'town':
        next = next.copyWith(editTown: value as String);
        break;
      case 'detailAddress':
        next = next.copyWith(editDetailAddress: value as String);
        break;
      case 'instagram':
        next = next.copyWith(editInstagram: value as String);
        break;
      case 'facebook':
        next = next.copyWith(editFacebook: value as String);
        break;
      default:
        return;
    }
    final u = next.user;
    final changed =
        u != null ? !_profileEditEqualsUser(next, u) : next.hasChanges;
    state = next.copyWith(hasChanges: changed, fieldErrors: {}, locationError: null, locationAction: null);
  }

  Future<void> detectCurrentLocation() async {
    state = state.copyWith(isDetectingLocation: true, locationError: null, locationAction: null);
    try {
      final result = await LocationService().getCurrentLocation();
      final next = state.copyWith(
        editLatitude: LocationService.formatCoordinate(result.latitude),
        editLongitude: LocationService.formatCoordinate(result.longitude),
        editGovernorate: result.governorate ?? '',
        editTown: result.town ?? '',
        editDetailAddress: result.detailAddress ?? '',
        isDetectingLocation: false,
        locationError: null,
        locationAction: null,
      );
      final u = next.user;
      state = next.copyWith(hasChanges: u != null ? !_profileEditEqualsUser(next, u) : true);
    } on XStoreLocationServiceDisabledException {
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationServiceDisabled',
        locationAction: 'open_location_settings',
      );
    } on XStoreLocationPermissionDeniedException {
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationPermissionDenied',
        locationAction: null,
      );
    } on XStoreLocationPermissionPermanentlyDeniedException {
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationPermissionPermanent',
        locationAction: 'open_app_settings',
      );
    } catch (_) {
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationPermissionDenied',
        locationAction: null,
      );
    }
  }

  void updateLatitude(String value) => updateField('latitude', value);
  void updateLongitude(String value) => updateField('longitude', value);
  void updateGovernorate(String value) => updateField('governorate', value);
  void updateTown(String value) => updateField('town', value);
  void updateDetailAddress(String value) => updateField('detailAddress', value);

  void clearLocationFeedback() {
    state = state.copyWith(locationError: null, locationAction: null);
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> pickAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (x == null) return false;
    state = state.copyWith(
      editAvatarFile: File(x.path),
      avatarRemoved: false,
      hasChanges: true,
    );
    return true;
  }

  void clearAvatarFile() {
    final cleared = state.copyWith(editAvatarFile: null);
    final u = cleared.user;
    state = cleared.copyWith(
      hasChanges: u != null && !_profileEditEqualsUser(cleared, u),
    );
  }

  void markAvatarRemoved() {
    final cleared = state.copyWith(
      editAvatarFile: null,
      avatarRemoved: true,
    );
    final u = cleared.user;
    state = cleared.copyWith(
      hasChanges: u != null && !_profileEditEqualsUser(cleared, u),
    );
  }

  Future<void> saveProfile() async {
    final u0 = state.user;
    if (u0 == null) return;

    final lat = state.editLatitude.trim();
    final lng = state.editLongitude.trim();
    if ((lat.isNotEmpty && lng.isEmpty) || (lat.isEmpty && lng.isNotEmpty)) {
      state = state.copyWith(
        isUpdating: false,
        error: lat.isEmpty ? 'invalidLatitude' : 'invalidLongitude',
      );
      return;
    }
    if (lat.isNotEmpty && !LocationService.isValidLatitude(lat)) {
      state = state.copyWith(isUpdating: false, error: 'invalidLatitude');
      return;
    }
    if (lng.isNotEmpty && !LocationService.isValidLongitude(lng)) {
      state = state.copyWith(isUpdating: false, error: 'invalidLongitude');
      return;
    }

    final epoch = _sessionEpoch;
    state = state.copyWith(isUpdating: true, error: null, fieldErrors: {});
    var nextUser = state.toEditedUser();
    final avatarPath = state.editAvatarFile?.path;

    if (avatarPath != null && avatarPath.isNotEmpty) {
      final avatarRes = await ref.read(updateAvatarUseCaseProvider).call(
            userId: u0.id,
            filePath: avatarPath,
          );
      if (epoch != _sessionEpoch) return;
      final avatarFailed = avatarRes.fold(
        (f) {
          state = state.copyWith(
            isUpdating: false,
            error: f.toString(),
          );
          return true;
        },
        (url) {
          nextUser = nextUser.copyWith(avatarUrl: url);
          return false;
        },
      );
      if (avatarFailed) return;
    }

    final res = await ref.read(updateProfileUseCaseProvider).call(nextUser);
    if (epoch != _sessionEpoch) return;
    UserEntity? updatedUser;
    final profileFailed = res.fold(
      (f) {
        state = state.copyWith(isUpdating: false, error: f.toString());
        return true;
      },
      (u) {
        updatedUser = u;
        return false;
      },
    );
    if (profileFailed) return;

    final updated = updatedUser!;
    final persist =
        await ref.read(authRepositoryProvider).persistSessionUser(updated);
    if (epoch != _sessionEpoch) return;
    final persistFailed = persist.fold(
      (c) {
        state = state.copyWith(isUpdating: false, error: c.toString());
        return true;
      },
      (_) => false,
    );
    if (persistFailed) return;

    ref.invalidate(authProvider);
    if (epoch != _sessionEpoch) return;
    state = state.copyWith(isUpdating: false, editAvatarFile: null);
    await refreshProfileData();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await ref.read(appThemeModeProvider.notifier).setTheme(
          enabled ? ThemeMode.dark : ThemeMode.light,
        );
    state = state.copyWith(isDarkMode: enabled);
  }

  Future<void> togglePushNotifications(bool enabled) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefsKeys.profilePushNotifications, enabled);
    state = state.copyWith(pushNotificationsEnabled: enabled);
  }

  Future<void> toggleEmailUpdates(bool enabled) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefsKeys.profileEmailUpdates, enabled);
    state = state.copyWith(emailUpdatesEnabled: enabled);
  }

  // Session teardown lives in Auth.logout — a notifier must not
  // ref.invalidate() itself (riverpod's debug assert kills the method
  // mid-way), which is what resetProfileData(ref) did from here. Auth's ref
  // invalidates this provider legally, and the router redirect on the auth
  // change handles navigation to login.
  Future<void> deleteAccount() async {
    final remote = await ref.read(deleteAccountUseCaseProvider).call();
    await remote.fold(
      (f) async {
        state = state.copyWith(error: f.toString());
      },
      (_) async {
        await ref.read(authProvider.notifier).logout();
      },
    );
  }
}
