import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../providers/profile_verification_provider.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/vendor_location_section.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/birth_date_picker.dart';
import '../../../../shared/widgets/location_cascade_field.dart';
import '../../../../shared/widgets/skeletons/edit_profile_skeleton.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const List<String> _storeCategoryOptions = [
    'Fashion',
    'Electronics',
    'Home',
    'Beauty',
    'Sports',
    'Other',
  ];

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _dobText = TextEditingController();
  final _storeName = TextEditingController();
  final _storeCategory = TextEditingController();
  final _storeDescription = TextEditingController();
  final _storeCity = TextEditingController();
  final _storeWilaya = TextEditingController();
  final _whatsapp = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _governorate = TextEditingController();
  final _town = TextEditingController();
  final _detailAddress = TextEditingController();

  String _category = '';
  DateTime? _dob;
  var _synced = false;

  @override
  void initState() {
    super.initState();
    // Profile data is prefetched on login/restore and read from
    // profileNotifierProvider — no mount-time get-profile here (429 risk).
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _dobText.dispose();
    _storeName.dispose();
    _storeCategory.dispose();
    _storeDescription.dispose();
    _storeCity.dispose();
    _storeWilaya.dispose();
    _whatsapp.dispose();
    _instagram.dispose();
    _facebook.dispose();
    _lat.dispose();
    _lng.dispose();
    _governorate.dispose();
    _town.dispose();
    _detailAddress.dispose();
    super.dispose();
  }

  void _syncFromState(ProfileState s) {
    _name.text = s.editName;
    _email.text = s.editEmail;
    _phone.text = s.editPhone;
    _location.text = s.editLocation;
    _dobText.text = s.editDateOfBirth != null
        ? DateFormat.yMMMd().format(s.editDateOfBirth!)
        : '';
    _storeName.text = s.editStoreName;
    _category = s.editStoreCategory;
    _storeCategory.text =
        _category.isEmpty ? context.l10n.requiredField : _category;
    _storeDescription.text = s.editStoreDescription;
    _storeCity.text = s.editStoreCity;
    _storeWilaya.text = s.editStoreWilaya;
    _whatsapp.text = s.editWhatsapp;
    _dob = s.editDateOfBirth;
    _instagram.text = s.editInstagram;
    _facebook.text = s.editFacebook;
    _lat.text = s.editLatitude;
    _lng.text = s.editLongitude;
    _governorate.text = s.editGovernorate;
    _town.text = s.editTown;
    _detailAddress.text = s.editDetailAddress;
  }

  void _pushFieldsToNotifier() {
    final n = ref.read(profileNotifierProvider.notifier);
    n.updateField('name', _name.text);
    n.updateField('email', _email.text);
    n.updateField('phone', _phone.text);
    n.updateField('location', _location.text);
    n.updateField('storeName', _storeName.text);
    n.updateField('storeCategory', _category);
    n.updateField('storeDescription', _storeDescription.text);
    n.updateField('storeCity', _storeCity.text);
    n.updateField('storeWilaya', _storeWilaya.text);
    n.updateField('whatsapp', _whatsapp.text);
    n.updateField('dateOfBirth', _dob);
    n.updateField('instagram', _instagram.text);
    n.updateField('facebook', _facebook.text);
    n.updateLatitude(_lat.text);
    n.updateLongitude(_lng.text);
    n.updateGovernorate(_governorate.text);
    n.updateTown(_town.text);
    n.updateDetailAddress(_detailAddress.text);
  }

  Future<void> _pickCategory() async {
    await showAnimatedBottomSheet<void>(
      context: context,
      builder: (ctx) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  context.l10n.storeCategoryLabel,
                  style: AppTypography.titleMedium,
                ),
              ),
              for (final c in _storeCategoryOptions)
                ListTile(
                  title: Text(c),
                  trailing: _category == c ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _category = c;
                      _storeCategory.text = c;
                    });
                    ref
                        .read(profileNotifierProvider.notifier)
                        .updateField('storeCategory', c);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final dateOnly = await pickBirthDate(
      context,
      selected: _dob,
      fallback: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
    );
    if (dateOnly == null) return;
    setState(() {
      _dob = dateOnly;
      _dobText.text = DateFormat.yMMMd().format(dateOnly);
    });
    ref.read(profileNotifierProvider.notifier).updateField('dateOfBirth', dateOnly);
  }

  Future<void> _avatarSheet() async {
    await showAnimatedBottomSheet<void>(
      context: context,
      builder: (ctx) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: Text(context.l10n.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: Text(context.l10n.removePhoto),
                onTap: () {
                  ref.read(profileNotifierProvider.notifier).markAvatarRemoved();
                  Navigator.pop(ctx);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _storeLogoSheet() async {
    await showAnimatedBottomSheet<void>(
      context: context,
      builder: (ctx) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: Text(context.l10n.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .pickStoreLogo(ImageSource.camera);
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .pickStoreLogo(ImageSource.gallery);
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: Text(context.l10n.removePhoto),
                onTap: () {
                  ref.read(profileNotifierProvider.notifier).markStoreLogoRemoved();
                  Navigator.pop(ctx);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    _pushFieldsToNotifier();
    final dobErr = Validators.dateOfBirth(context.l10n, _dob);
    if (dobErr != null) {
      AppSnackbar.error(context, dobErr);
      return;
    }
    await ref.read(profileNotifierProvider.notifier).saveProfile();
    if (!mounted) return;
    final err = ref.read(profileNotifierProvider).error;
    if (err != null) {
      AppSnackbar.error(context, _errorText(context, err));
      return;
    }
    AppSnackbar.success(context, context.l10n.profileUpdatedSuccess);
    Navigator.of(context).pop();
  }

  Future<void> _verifyEmail() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    final verified = await context.push<bool>(
      AppRoutes.profileVerification,
      extra: ProfileVerificationArgs(
        target: ProfileVerificationTarget.email,
        contactValue: email,
      ),
    );
    if (!mounted || verified != true) return;
    setState(() => _syncFromState(ref.read(profileNotifierProvider)));
  }

  Future<void> _verifyPhone() async {
    final isEmailVerified =
        ref.read(profileNotifierProvider).profile?.isEmailVerified ?? false;
    if (!isEmailVerified) {
      final proceed = await showAnimatedDialog<bool>(
        context: context,
        child: AlertDialog(
          title: Text(context.l10n.verifyYourEmail),
          content: Text(context.l10n.verifyEmailBeforePhone),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.verify),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
      await _verifyEmail();
      return;
    }
    final phone = _phone.text.trim();
    if (phone.isEmpty) return;
    final verified = await context.push<bool>(
      AppRoutes.profileVerification,
      extra: ProfileVerificationArgs(
        target: ProfileVerificationTarget.phone,
        contactValue: phone,
      ),
    );
    if (!mounted || verified != true) return;
    setState(() => _syncFromState(ref.read(profileNotifierProvider)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileNotifierProvider, (prev, next) async {
      if (prev?.isLoading == true &&
          !next.isLoading &&
          !next.isUpdating &&
          !next.hasChanges &&
          next.user != null &&
          mounted) {
        setState(() => _syncFromState(next));
      }
      if (prev?.isDetectingLocation == true &&
          !next.isDetectingLocation &&
          next.locationError == null &&
          mounted) {
        _lat.text = next.editLatitude;
        _lng.text = next.editLongitude;
        _governorate.text = next.editGovernorate;
        _town.text = next.editTown;
        _detailAddress.text = next.editDetailAddress;
        AppSnackbar.success(context, context.l10n.locationDetected);
      }
      if (prev?.locationAction != next.locationAction &&
          next.locationAction != null &&
          mounted) {
        if (next.locationAction == 'open_location_settings') {
          final open = await showAnimatedDialog<bool>(
            context: context,
            child: AlertDialog(
              title: Text(context.l10n.locationServicesOff),
              content: Text(context.l10n.enableLocationServices),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.openSettings),
                ),
              ],
            ),
          );
          if (open == true) await Geolocator.openLocationSettings();
        } else if (next.locationAction == 'open_app_settings') {
          final open = await showAnimatedDialog<bool>(
            context: context,
            child: AlertDialog(
              title: Text(context.l10n.locationPermissionPermanent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.openAppSettings),
                ),
              ],
            ),
          );
          if (open == true) await Geolocator.openAppSettings();
        }
        ref.read(profileNotifierProvider.notifier).clearLocationFeedback();
      }
    });

    final s = ref.watch(profileNotifierProvider);
    final u = s.user;
    final isVendor = u?.hasStore ?? false;

    if (!_synced && u != null) {
      _synced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _syncFromState(s));
      });
    }

    final canSave = s.hasChanges && !s.isUpdating;
    if (u == null && s.isLoading) {
      return const Scaffold(body: EditProfileSkeleton());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
        actions: [
          if (s.isUpdating)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: AppSpacing.lg),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: canSave ? _save : null,
              child: Text(context.l10n.save),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: ProfileAvatarPicker(
              name: u?.name ?? '',
              imageUrl: s.avatarRemoved ? null : u?.avatarUrl,
              imageFile: s.editAvatarFile,
              diameter: 100,
              onTap: _avatarSheet,
            ),
          ),
          const Gap(AppSpacing.x2l),
          Text(context.l10n.menuPersonalInfo, style: AppTypography.titleMedium),
          const Gap(AppSpacing.md),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.user),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('name', v),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mail),
              suffixIcon: _VerificationStatus(
                verified: s.profile?.isEmailVerified ?? false,
                onVerify: _email.text.trim().isEmpty ? null : _verifyEmail,
              ),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('email', v),
          ),
          const Gap(AppSpacing.md),
          PhoneInputField(
            controller: _phone,
            suffix: _VerificationStatus(
              verified: s.profile?.isPhoneVerified ?? false,
              onVerify: _phone.text.trim().isEmpty ? null : _verifyPhone,
            ),
            onChanged: (v) => ref
                .read(profileNotifierProvider.notifier)
                .updateField('phone', v.replaceAll(RegExp(r'\D'), '')),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _dobText,
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.calendar),
              suffixIcon: const Icon(LucideIcons.chevronDown),
              border: const OutlineInputBorder(),
            ),
            onTap: _pickDob,
          ),
          // const Gap(AppSpacing.md),
          // TextField(
          //   controller: _location,
          //   decoration: InputDecoration(
          //     prefixIcon: const Icon(LucideIcons.mapPin),
          //     border: const OutlineInputBorder(),
          //   ),
          //   onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('location', v),
          // ),
          const Gap(AppSpacing.md),
          // Single user location (governorate + city) for all roles; vendors
          // reuse this same pair as the store location.
          LocationCascadeField(
            cityId: s.editStoreCityId,
            governorateId: s.editStoreGovernmentId,
            hint: _registeredLocationHint(s),
            onChanged: (cityId, governorateId) => ref
                .read(profileNotifierProvider.notifier)
                .updateStoreLocation(cityId, governorateId),
          ),
          if (isVendor) ...[
            const Gap(AppSpacing.x2l),
            Text(context.l10n.storeInformation, style: AppTypography.titleMedium),
            const Gap(AppSpacing.md),
            Center(
              child: Column(
                children: [
                  Text(
                    context.l10n.storeLogoRequired,
                    style: AppTypography.labelLarge,
                  ),
                  const Gap(AppSpacing.sm),
                  ProfileAvatarPicker(
                    name: _storeName.text.isNotEmpty ? _storeName.text : (u?.name ?? ''),
                    imageUrl: s.storeLogoRemoved ? null : u?.storeLogoUrl,
                    imageFile: s.editStoreLogoFile,
                    diameter: 100,
                    onTap: _storeLogoSheet,
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.lg),
            TextField(
              controller: _storeName,
              decoration: InputDecoration(
                labelText: context.l10n.storeNameRequired,
                prefixIcon: const Icon(LucideIcons.store),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('storeName', v),
            ),
            const Gap(AppSpacing.md),
            TextField(
              readOnly: true,
              controller: _storeCategory,
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.tags),
                suffixIcon: const Icon(LucideIcons.chevronDown),
                border: const OutlineInputBorder(),
              ),
              onTap: _pickCategory,
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeDescription,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.storeDescriptionRequired,
                prefixIcon: const Icon(LucideIcons.fileText),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(profileNotifierProvider.notifier).updateField('storeDescription', v),
            ),
            const Gap(AppSpacing.md),
            PhoneInputField(
              controller: _whatsapp,
              onChanged: (v) => ref
                  .read(profileNotifierProvider.notifier)
                  .updateField('whatsapp', v.replaceAll(RegExp(r'\D'), '')),
            ),
            const Gap(AppSpacing.xl),
            VendorLocationSection(
              latController: _lat,
              lngController: _lng,
              governorateController: _governorate,
              townController: _town,
              detailAddressController: _detailAddress,
            ),
          ],
          const Gap(AppSpacing.x2l),
          Text(context.l10n.socialLinks, style: AppTypography.titleMedium),
          const Gap(AppSpacing.md),
          TextField(
            controller: _instagram,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.instagram),
              prefixText: '@',
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('instagram', v),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _facebook,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.facebook),
              prefixText: 'fb.com/',
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('facebook', v),
          ),
          const Gap(AppSpacing.x3l),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.profileHeaderGradientEnd],
              ),
            ),
            child: Material(
              color: AppColors.primary.withValues(alpha: 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                onTap: canSave ? _save : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: s.isUpdating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : Text(
                            context.l10n.saveChanges,
                            style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.x3l),
        ],
      ),
    );
  }
}

/// Compact verified badge or "Verify" action for the trailing edge of a field.
class _VerificationStatus extends StatelessWidget {
  const _VerificationStatus({required this.verified, required this.onVerify});

  final bool verified;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 16, color: AppColors.success),
            const Gap(AppSpacing.xs),
            Text(
              context.l10n.verified,
              style: AppTypography.labelSmall.copyWith(color: AppColors.success),
            ),
          ],
        ),
      );
    }
    return TextButton(
      onPressed: onVerify,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: Text(context.l10n.verify),
    );
  }
}

/// "Governorate - City" from the location saved at register, used as the
/// cascade hint until the live lists resolve the selected ids.
String? _registeredLocationHint(ProfileState s) {
  final government = s.editStoreWilaya.trim();
  final city = s.editStoreCity.trim();
  if (government.isEmpty && city.isEmpty) return null;
  if (government.isEmpty) return city;
  if (city.isEmpty) return government;
  return '$government - $city';
}

String _errorText(BuildContext context, String key) {
  return switch (key) {
    'invalidLatitude' => context.l10n.invalidLatitude,
    'invalidLongitude' => context.l10n.invalidLongitude,
    'birthDateBeforeToday' => context.l10n.validationBirthDateBeforeToday,
    'locationPermissionDenied' => context.l10n.locationPermissionDenied,
    'locationPermissionPermanent' => context.l10n.locationPermissionPermanent,
    'locationServiceDisabled' => context.l10n.locationServiceDisabled,
    rateLimitErrorCode => resolveAppError(context, key),
    _ => key,
  };
}
