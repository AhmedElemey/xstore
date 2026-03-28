import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _bio = TextEditingController();
  final _storeName = TextEditingController();
  final _storeDescription = TextEditingController();
  final _storeCity = TextEditingController();
  final _storeWilaya = TextEditingController();
  final _whatsapp = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();

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
    _bio.dispose();
    _storeName.dispose();
    _storeDescription.dispose();
    _storeCity.dispose();
    _storeWilaya.dispose();
    _whatsapp.dispose();
    _instagram.dispose();
    _facebook.dispose();
    super.dispose();
  }

  void _syncFromState(ProfileState s) {
    _name.text = s.editName;
    _email.text = s.editEmail;
    _phone.text = s.editPhone;
    _location.text = s.editLocation;
    _bio.text = s.editBio;
    _storeName.text = s.editStoreName;
    _category = s.editStoreCategory;
    _storeDescription.text = s.editStoreDescription;
    _storeCity.text = s.editStoreCity;
    _storeWilaya.text = s.editStoreWilaya;
    _whatsapp.text = s.editWhatsapp;
    _dob = s.editDateOfBirth;
    _instagram.text = s.editInstagram;
    _facebook.text = s.editFacebook;
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
              child: Text(AppStrings.storeCategoryLabel, style: AppTypography.titleMedium),
            ),
            for (final c in AppStrings.storeCategoryPickerOptions)
              ListTile(
                title: Text(c),
                trailing: _category == c ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _category = c);
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
    setState(() => _dob = picked);
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
              title: Text(AppStrings.takePhoto),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(profileNotifierProvider.notifier).pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(AppStrings.chooseFromGallery),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(profileNotifierProvider.notifier).pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2),
              title: Text(AppStrings.removePhoto),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.profileUpdatedSuccess)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
    final dobLabel = _dob != null ? DateFormat.yMMMd().format(_dob!) : AppStrings.dateOfBirthLabel;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.editProfile),
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
              child: Text(AppStrings.save),
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
          Text(AppStrings.menuPersonalInfo, style: AppTypography.titleMedium),
          const Gap(AppSpacing.md),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: '${AppStrings.fullNameLabel} *',
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('name', v),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: '${AppStrings.emailAddressLabel} *',
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('email', v),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: '${AppStrings.phoneNumberLabel} *',
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('phone', v),
          ),
          const Gap(AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppStrings.dateOfBirthLabel, style: AppTypography.bodySmall),
            subtitle: Text(dobLabel),
            trailing: const Icon(LucideIcons.calendar),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              side: const BorderSide(color: AppColors.textDisabled),
            ),
            onTap: _pickDob,
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _location,
            decoration: InputDecoration(
              labelText: '${AppStrings.locationCityLabel} *',
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
              labelText: AppStrings.bioLabel,
              hintText: AppStrings.bioHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('bio', v),
          ),
          if (isVendor) ...[
            const Gap(AppSpacing.x2l),
            Text(AppStrings.storeInformation, style: AppTypography.titleMedium),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeName,
              decoration: InputDecoration(
                labelText: '${AppStrings.storeNameLabel} *',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('storeName', v),
            ),
            const Gap(AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${AppStrings.storeCategoryLabel} *', style: AppTypography.bodyMedium),
              subtitle: Text(_category.isEmpty ? AppStrings.requiredField : _category),
              trailing: const Icon(LucideIcons.chevronDown),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                side: const BorderSide(color: AppColors.textDisabled),
              ),
              onTap: _pickCategory,
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeDescription,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '${AppStrings.storeDescriptionLabel} *',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(profileNotifierProvider.notifier).updateField('storeDescription', v),
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeCity,
              decoration: InputDecoration(
                labelText: '${AppStrings.storeCityLabel} *',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('storeCity', v),
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _storeWilaya,
              decoration: InputDecoration(
                labelText: '${AppStrings.storeWilayaLabel} *',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(profileNotifierProvider.notifier).updateField('storeWilaya', v),
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _whatsapp,
              decoration: InputDecoration(
                labelText: AppStrings.whatsappLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('whatsapp', v),
            ),
          ],
          const Gap(AppSpacing.x2l),
          Text(AppStrings.socialLinks, style: AppTypography.titleMedium),
          const Gap(AppSpacing.md),
          TextField(
            controller: _instagram,
            decoration: InputDecoration(
              labelText: AppStrings.instagramLabel,
              prefixText: '@',
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateField('instagram', v),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _facebook,
            decoration: InputDecoration(
              labelText: AppStrings.facebookLabel,
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
                            AppStrings.saveChanges,
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
