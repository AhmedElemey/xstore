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
import '../../../../core/network/app_error_messages.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'profile_dependencies.dart';
import 'profile_state.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/validators.dart';

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

bool _sameCalendarDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
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
      s.editFullNameAr.trim() == (u.fullNameAr ?? '').trim() &&
      s.editStoreName.trim() == (u.storeName ?? '').trim() &&
      s.editStoreCategoryId == u.storeCategoryId &&
      s.editStoreDescription.trim() ==
          (u.storeDescription ?? '').trim() &&
      s.editStoreCity.trim() == (u.storeCity ?? '').trim() &&
      s.editStoreWilaya.trim() == (u.storeWilaya ?? '').trim() &&
      s.editStoreCityId == u.storeCityId &&
      s.editStoreGovernmentId == u.storeGovernmentId &&
      s.editWhatsapp.trim() == (u.whatsappNumber ?? '').trim() &&
      s.editLatitude.trim() == ((u.latitude == null) ? '' : u.latitude!.toStringAsFixed(6)) &&
      s.editLongitude.trim() == ((u.longitude == null) ? '' : u.longitude!.toStringAsFixed(6)) &&
      s.editGovernorate.trim() == (u.governorate ?? '').trim() &&
      s.editTown.trim() == (u.town ?? '').trim() &&
      s.editDetailAddress.trim() == (u.detailAddress ?? '').trim() &&
      _sameCalendarDate(s.editDateOfBirth, u.dateOfBirth) &&
      s.editInstagram.trim() == (u.instagramHandle ?? '').trim() &&
      s.editFacebook.trim() == (u.facebookPage ?? '').trim() &&
      s.editAvatarFile == null &&
      !s.avatarRemoved &&
      s.editStoreLogoFile == null &&
      !s.storeLogoRemoved;
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  // Bumped by ref.onDispose, which also fires on invalidate (resetProfileData
  // on logout / forced 401). In-flight refreshes compare their epoch so a
  // fetch from the previous session never writes into the next one. A plain
  // _disposed flag is not enough here: keepAlive invalidate reuses this
  // instance and build() would reset the flag, reopening the gate.
  var _sessionEpoch = 0;

  /// Coalesces concurrent tab-open / prefetch / edit-screen refreshes.
  Future<void>? _inFlightRefresh;

  /// Bumped on every fetch actually started (forced or not). Lets a
  /// `force: true` caller (e.g. right after verifying email/phone) guarantee
  /// its own fetch's result is the one that lands in state, even if an
  /// older, already-in-flight refresh resolves after it.
  var _refreshRequestId = 0;

  /// Skips back-to-back get-profile calls (login prefetch + profile tab, etc.).
  DateTime? _lastRefreshAt;
  static const _minRefreshInterval = Duration(seconds: 30);

  /// After HTTP 429, block automatic retries until this time.
  DateTime? _rateLimitedUntil;
  static const _rateLimitCooldown = Duration(minutes: 1);

  @override
  ProfileState build() {
    ref.onDispose(() {
      _sessionEpoch++;
      _inFlightRefresh = null;
    });
    return const ProfileState();
  }

  /// Reloads enriched profile + stats from the server. Use this (not ad-hoc
  /// fetches) whenever profileNotifierProvider should sync with the backend.
  ///
  /// [user] overrides the `authProvider` read for callers holding the session
  /// user while `authProvider` is still Loading (see [prefetchProfileData]).
  ///
  /// Pass [force: true] for pull-to-refresh and post-save reloads.
  Future<void> refreshProfileData({UserEntity? user, bool force = false}) async {
    final sessionUser = user ?? ref.read(authProvider).valueOrNull;
    if (sessionUser == null) {
      state = const ProfileState();
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _rateLimitedUntil != null &&
        now.isBefore(_rateLimitedUntil!)) {
      if (kDebugMode) {
        debugPrint(
          '[ProfileNotifier] refresh skipped — rate limited until '
          '$_rateLimitedUntil',
        );
      }
      return;
    }

    if (!force &&
        state.profile != null &&
        _lastRefreshAt != null &&
        now.difference(_lastRefreshAt!) < _minRefreshInterval) {
      if (kDebugMode) {
        debugPrint(
          '[ProfileNotifier] refresh skipped — last refresh '
          '${now.difference(_lastRefreshAt!).inSeconds}s ago',
        );
      }
      return;
    }

    if (!force) {
      final existing = _inFlightRefresh;
      if (existing != null) {
        if (kDebugMode) {
          debugPrint('[ProfileNotifier] refresh coalesced — awaiting in-flight');
        }
        return existing;
      }
    }

    // force: true always starts its own fetch rather than piggybacking on
    // whatever's already in flight — a refresh right after verifying
    // email/phone must not resolve to data fetched before that verification.
    final requestId = ++_refreshRequestId;
    final future = _refreshProfileDataImpl(sessionUser, requestId);
    _inFlightRefresh = future;
    try {
      await future;
    } finally {
      if (identical(_inFlightRefresh, future)) {
        _inFlightRefresh = null;
      }
    }
  }

  Future<void> _refreshProfileDataImpl(UserEntity sessionUser, int requestId) async {
    final epoch = _sessionEpoch;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (epoch != _sessionEpoch || requestId != _refreshRequestId) return;
      final push = prefs.getBool(PrefsKeys.profilePushNotifications) ?? true;
      final email = prefs.getBool(PrefsKeys.profileEmailUpdates) ?? true;
      final themeMode = ref.read(appThemeModeProvider);

      final result =
          await ref.read(getProfileUseCaseProvider).call(sessionUser);
      if (epoch != _sessionEpoch || requestId != _refreshRequestId) return;
      result.fold(
        (f) {
          final message = f.toString();
          if (message == rateLimitErrorCode) {
            _rateLimitedUntil =
                DateTime.now().add(_rateLimitCooldown);
          }
          state = state.copyWith(isLoading: false, error: message);
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
          _lastRefreshAt = DateTime.now();
          _rateLimitedUntil = null;
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
      if (epoch != _sessionEpoch || requestId != _refreshRequestId) return;
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
      case 'storeName':
        next = next.copyWith(editStoreName: value as String);
        break;
      case 'storeCategory':
        next = next.copyWith(editStoreCategory: value as String);
        break;
      case 'storeDescription':
        next = next.copyWith(editStoreDescription: value as String);
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
    final epoch = _sessionEpoch;
    state = state.copyWith(isDetectingLocation: true, locationError: null, locationAction: null);
    try {
      final result = await LocationService().getCurrentLocation();
      if (epoch != _sessionEpoch) return;
      final googleAddress = result.detailAddress ?? '';
      final next = state.copyWith(
        editLatitude: LocationService.formatCoordinate(result.latitude),
        editLongitude: LocationService.formatCoordinate(result.longitude),
        editGovernorate: result.governorate ?? '',
        editTown: result.town ?? '',
        editLocation: googleAddress,
        editDetailAddress: googleAddress,
        isDetectingLocation: false,
        locationError: null,
        locationAction: null,
      );
      final u = next.user;
      state = next.copyWith(hasChanges: u != null ? !_profileEditEqualsUser(next, u) : true);
    } on XStoreLocationServiceDisabledException {
      if (epoch != _sessionEpoch) return;
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationServiceDisabled',
        locationAction: 'open_location_settings',
      );
    } on XStoreLocationPermissionDeniedException {
      if (epoch != _sessionEpoch) return;
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationPermissionDenied',
        locationAction: null,
      );
    } on XStoreLocationPermissionPermanentlyDeniedException {
      if (epoch != _sessionEpoch) return;
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationPermissionPermanent',
        locationAction: 'open_app_settings',
      );
    } catch (_) {
      if (epoch != _sessionEpoch) return;
      state = state.copyWith(
        isDetectingLocation: false,
        locationError: 'locationPermissionDenied',
        locationAction: null,
      );
    }
  }

  /// Applies a device-detected location without the loading/error flags
  /// [detectCurrentLocation] sets — those drive Edit Profile's UI and would
  /// leak into unrelated screens if set from a background bootstrap. Used
  /// only by [autoDetectAndFillLocationIfMissing].
  void applyDetectedLocationSilently(LocationResult result) {
    final googleAddress = result.detailAddress ?? '';
    final next = state.copyWith(
      editLatitude: LocationService.formatCoordinate(result.latitude),
      editLongitude: LocationService.formatCoordinate(result.longitude),
      editGovernorate: result.governorate ?? '',
      editTown: result.town ?? '',
      editLocation: googleAddress,
      editDetailAddress: googleAddress,
    );
    final u = next.user;
    state = next.copyWith(hasChanges: u != null ? !_profileEditEqualsUser(next, u) : true);
  }

  /// Best-effort, silent location auto-fill for app-entry bootstrap (splash).
  /// Unlike [detectCurrentLocation] (user-initiated from Edit Profile,
  /// surfaces loading/error UI), this never prompts or shows errors — it
  /// only fills in a profile that has no location set yet, so it never
  /// overwrites a location the user already set deliberately. Runs on this
  /// notifier's own keepAlive `ref`, not the caller's — safe to
  /// fire-and-forget from a widget (splash) that navigates away, and
  /// disposes, before this completes.
  Future<void> autoDetectAndFillLocationIfMissing() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null || user.id.isEmpty) return;

    await refreshProfileData(user: user);

    final current = state.user ?? user;
    if (current.latitude != null && current.longitude != null) return;

    try {
      final result = await LocationService().getCurrentLocation();
      applyDetectedLocationSilently(result);
      await saveProfile();
    } catch (_) {
      // Silent — passive background detection must never surface errors.
    }
  }

  /// Sets the city (`cityId`) + governorate (`governorateId`) pair from the
  /// location cascade; both are assigned explicitly so a governorate change can
  /// clear the dependent city (null).
  void updateStoreLocation(int? cityId, int? governorateId) {
    final next = state.copyWith(
      editStoreCityId: cityId,
      editStoreGovernmentId: governorateId,
    );
    final u = next.user;
    state = next.copyWith(
      hasChanges: u != null ? !_profileEditEqualsUser(next, u) : true,
      fieldErrors: {},
    );
  }

  /// Sets the picked store category id + display label together — mirrors
  /// [updateStoreLocation]. `editStoreCategory` (id-less) is display-only;
  /// [toUpdateProfileRequest] sends `editStoreCategoryId`.
  void updateStoreCategory(int categoryId, String label) {
    final next = state.copyWith(
      editStoreCategoryId: categoryId,
      editStoreCategory: label,
    );
    final u = next.user;
    state = next.copyWith(
      hasChanges: u != null ? !_profileEditEqualsUser(next, u) : true,
      fieldErrors: {},
    );
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
    final epoch = _sessionEpoch;
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (epoch != _sessionEpoch) return false;
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

  Future<bool> pickStoreLogo(ImageSource source) async {
    final epoch = _sessionEpoch;
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (epoch != _sessionEpoch) return false;
    if (x == null) return false;
    state = state.copyWith(
      editStoreLogoFile: File(x.path),
      storeLogoRemoved: false,
      hasChanges: true,
    );
    return true;
  }

  void markStoreLogoRemoved() {
    final cleared = state.copyWith(
      editStoreLogoFile: null,
      storeLogoRemoved: true,
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
    if (state.editDateOfBirth != null &&
        Validators.isBirthDateAfterToday(state.editDateOfBirth)) {
      state = state.copyWith(isUpdating: false, error: 'birthDateBeforeToday');
      return;
    }

    final epoch = _sessionEpoch;
    state = state.copyWith(isUpdating: true, error: null, fieldErrors: {});

    final request = state.toUpdateProfileRequest();
    if (kDebugMode) {
      debugPrint(
        '[ProfileNotifier] saveProfile — '
        'fullNameEn=${request.fullNameEn} fullNameAr=${request.fullNameAr} '
        'birthDate=${request.birthDate} '
        'storeName=${request.storeName} '
        'storeDescription=${request.storeDescription} '
        'whatsAppNumber=${request.whatsAppNumber} '
        'instagramPage=${request.instagramPage} facebookPage=${request.facebookPage} '
        'detailedAddressByGoogleMaps=${request.detailedAddressByGoogleMaps} '
        'detailedAddressByUser=${request.detailedAddressByUser} '
        'cityByGoogleMaps=${request.cityByGoogleMaps} '
        'governmentByGoogleMaps=${request.governmentByGoogleMaps} '
        'lat=${request.lat} lng=${request.lng} '
        'cityId=${request.cityId} governorateId=${request.governorateId} '
        'storeCategoryId=${request.storeCategoryId} '
        'userImageUrl=${request.userImageUrl} storeImageUrl=${request.storeImageUrl}',
      );
    }

    final res = await ref.read(updateProfileUseCaseProvider).call(
          request,
          sessionUser: u0,
        );
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
    state = state.copyWith(
      isUpdating: false,
      editAvatarFile: null,
      editStoreLogoFile: null,
    );
    await refreshProfileData(force: true);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final epoch = _sessionEpoch;
    await ref.read(appThemeModeProvider.notifier).setTheme(
          enabled ? ThemeMode.dark : ThemeMode.light,
        );
    if (epoch != _sessionEpoch) return;
    state = state.copyWith(isDarkMode: enabled);
  }

  Future<void> togglePushNotifications(bool enabled) async {
    final epoch = _sessionEpoch;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefsKeys.profilePushNotifications, enabled);
    if (epoch != _sessionEpoch) return;
    state = state.copyWith(pushNotificationsEnabled: enabled);
  }

  Future<void> toggleEmailUpdates(bool enabled) async {
    final epoch = _sessionEpoch;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefsKeys.profileEmailUpdates, enabled);
    if (epoch != _sessionEpoch) return;
    state = state.copyWith(emailUpdatesEnabled: enabled);
  }

  // Returns true when the backend deleted the account. Session teardown is
  // the caller's job — this notifier must not `ref.read(authProvider)`:
  // that makes Profile depend on Auth, Auth.logout then reads analytics
  // (or invalidates Profile), and Riverpod circular-asserts in debug.
  // The dialog's WidgetRef calls Auth.logout(), same as the logout sheet.
  Future<bool> deleteAccount({
    required String password,
    required String confirmationText,
  }) async {
    final epoch = _sessionEpoch;
    final remote = await ref.read(deleteAccountUseCaseProvider).call(
          password: password,
          confirmationText: confirmationText,
        );
    if (epoch != _sessionEpoch) return false;
    return remote.fold(
      (f) {
        state = state.copyWith(error: f.toString());
        return false;
      },
      (_) => true,
    );
  }
}
