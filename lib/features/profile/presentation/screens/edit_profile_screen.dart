import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/vendor_location_section.dart';
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
  final _bio = TextEditingController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).fetchProfile();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _dobText.dispose();
    _bio.dispose();
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
    _bio.text = s.editBio;
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
    n.updateField('bio', _bio.text);
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
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(context.l10n.storeCategoryLabel, style: AppTypography.titleMedium),
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
                  ref.read(profileNotifierProvider.notifier).updateField('storeCategory', c);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dob = picked;
      _dobText.text = DateFormat.yMMMd().format(picked);
    });
    ref.read(profileNotifierProvider.notifier).updateField('dateOfBirth', picked);
  }

  Future<void> _avatarSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(context.l10n.takePhoto),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(profileNotifierProvider.notifier).pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(profileNotifierProvider.notifier).pickAvatar(ImageSource.gallery);
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
    );
  }

  Future<void> _save() async {
    _pushFieldsToNotifier();
    await ref.read(profileNotifierProvider.notifier).saveProfile();
    if (!mounted) return;
    final err = ref.read(profileNotifierProvider).error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorText(context, err))),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.profileUpdatedSuccess)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileNotifierProvider, (prev, next) async {
      if (prev?.isDetectingLocation == true &&
          !next.isDetectingLocation &&
          next.locationError == null &&
          mounted) {
        _lat.text = next.editLatitude;
        _lng.text = next.editLongitude;
        _governorate.text = next.editGovernorate;
        _town.text = next.editTown;
        _detailAddress.text = next.editDetailAddress;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.locationDetected)),
        );
      }
      if (prev?.locationAction != next.locationAction &&
          next.locationAction != null &&
          mounted) {
        if (next.locationAction == 'open_location_settings') {
          final open = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.l10n.locationServicesOff),
              content: Text(context.l10n.enableLocationServices),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(context.l10n.openSettings),
                ),
              ],
            ),
          );
          if (open == true) await Geolocator.openLocationSettings();
        } else if (next.locationAction == 'open_app_settings') {
          final open = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.l10n.locationPermissionPermanent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
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
    final isVendor = u?.role == UserRole.vendor;

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
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('email', v),
          ),
          const Gap(AppSpacing.md),
          PhoneInputField(
            controller: _phone,
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
          const Gap(AppSpacing.md),
          TextField(
            controller: _location,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mapPin),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('location', v),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _bio,
            maxLines: 3,
            maxLength: 150,
            decoration: InputDecoration(
              hintText: context.l10n.bioHint,
              prefixIcon: const Icon(LucideIcons.alignLeft),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('bio', v),
          ),
          if (isVendor) ...[
            const Gap(AppSpacing.x2l),
            Text(context.l10n.storeInformation, style: AppTypography.titleMedium),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeName,
              decoration: InputDecoration(
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
                prefixIcon: const Icon(LucideIcons.fileText),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(profileNotifierProvider.notifier).updateField('storeDescription', v),
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeCity,
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.mapPin),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('storeCity', v),
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeWilaya,
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.map),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(profileNotifierProvider.notifier).updateField('storeWilaya', v),
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

String _errorText(BuildContext context, String key) {
  return switch (key) {
    'invalidLatitude' => context.l10n.invalidLatitude,
    'invalidLongitude' => context.l10n.invalidLongitude,
    'locationPermissionDenied' => context.l10n.locationPermissionDenied,
    'locationPermissionPermanent' => context.l10n.locationPermissionPermanent,
    'locationServiceDisabled' => context.l10n.locationServiceDisabled,
    _ => key,
  };
}
