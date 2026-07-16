import 'dart:io';

import '../../../../core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../cities/domain/entities/city_entity.dart';
import '../../../cities/presentation/providers/city_dependencies.dart';
import '../../../governments/domain/entities/government_entity.dart';
import '../../../governments/presentation/providers/government_dependencies.dart';
import '../../../store_categories/domain/entities/store_category_entity.dart';
import '../../../store_categories/presentation/providers/store_category_dependencies.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_states.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/role_selector_card.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_login_row.dart';
import '../widgets/phone_input_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _fullNameAr = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _storeName = TextEditingController();
  final _storeNameAr = TextEditingController();
  final _storeDesc = TextEditingController();
  final _storeDescAr = TextEditingController();
  final _whatsapp = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registerNotifierProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _fullNameAr.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _password.dispose();
    _confirm.dispose();
    _storeName.dispose();
    _storeNameAr.dispose();
    _storeDesc.dispose();
    _storeDescAr.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _pickDob(RegisterNotifier n, RegisterState s) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (d != null) n.updateField(dateOfBirth: d);
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.leaveRegistrationTitle),
        content: Text(context.l10n.leaveRegistrationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.stay),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.leave),
          ),
        ],
      ),
    );
    if (leave == true && mounted) context.pop();
  }

  void _onBack(RegisterState s, RegisterNotifier n) {
    if (s.currentStep > 1) {
      n.previousStep();
    } else {
      _confirmExit();
    }
  }

  Future<void> _onPrimary(RegisterState s, RegisterNotifier n) async {
    final l10n = context.l10n;
    if (s.selectedRole == UserRole.consumer && s.currentStep == 3) {
      await n.submitFromCurrentStep(l10n);
      return;
    }
    if (s.selectedRole == UserRole.vendor && s.currentStep == 4) {
      await n.submitFromCurrentStep(l10n);
      return;
    }
    n.nextStep(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(registerNotifierProvider);
    final n = ref.read(registerNotifierProvider.notifier);

    ref.listen(registerNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error && mounted) {
        AppSnackbar.error(context, next.error!);
      }
    });

    final labels = s.totalSteps == 4
        ? [context.l10n.stepRole, context.l10n.stepInfo, context.l10n.stepSecurity, context.l10n.stepStore]
        : [context.l10n.stepRole, context.l10n.stepInfo, context.l10n.stepSecurity];
    final progress = s.currentStep / s.totalSteps;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.iconPrimary),
          onPressed: () => _onBack(s, n),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  context.l10n.stepOf(s.currentStep, s.totalSteps),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.textSecondary,
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: context.textDisabled.withValues(alpha: 0.35),
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    labels.length,
                    (i) => Expanded(
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: i + 1 == s.currentStep
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: i + 1 <= s.currentStep
                              ? AppColors.primary
                              : context.textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(s.currentStep),
                    child: _stepBody(s, n),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: XstoreButton(
                  label: s.selectedRole == UserRole.vendor && s.currentStep == 4
                      ? context.l10n.createMyStore
                      : context.l10n.continueLabel,
                  isLoading: s.isLoading,
                  onPressed: s.isLoading ||
                          (s.currentStep == 1 && s.selectedRole == null)
                      ? null
                      : () => _onPrimary(s, n),
                ),
              ),
            ],
          ),
          if (s.showVendorSuccessOverlay) _VendorSuccessOverlay(name: s.fullName),
        ],
      ),
    );
  }

  Widget _stepBody(RegisterState s, RegisterNotifier n) {
    switch (s.currentStep) {
      case 1:
        return _StepRole(s: s, n: n);
      case 2:
        return _StepPersonal(
          s: s,
          n: n,
          fullName: _fullName,
          fullNameAr: _fullNameAr,
          email: _email,
          phone: _phone,
          location: _location,
          onPickDob: () => _pickDob(n, s),
        );
      case 3:
        return _StepSecurity(
          s: s,
          n: n,
          password: _password,
          confirm: _confirm,
        );
      case 4:
        return _StepStore(
          s: s,
          n: n,
          storeName: _storeName,
          storeNameAr: _storeNameAr,
          storeDesc: _storeDesc,
          storeDescAr: _storeDescAr,
          whatsapp: _whatsapp,
        );
      default:
        return const SizedBox.shrink();
    }
  }

}

class _StepRole extends StatelessWidget {
  const _StepRole({required this.s, required this.n});

  final RegisterState s;
  final RegisterNotifier n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        Text(
          context.l10n.joinAs,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const Gap(AppSpacing.spacing10),
        Text(
          context.l10n.chooseHowUse,
          style: AppTypography.body15.copyWith(
            height: 1.4,
            color: context.textSecondary,
          ),
        ),
        const Gap(AppSpacing.xl),
        if (s.stepErrors.containsKey('role'))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              s.stepErrors['role']!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        RoleSelectorCard(
          title: context.l10n.iAmBuyer,
          subtitle: context.l10n.buyerSubtitle,
          icon: LucideIcons.shoppingBag,
          accentColor: AppColors.primary,
          selectionBorderColor: AppColors.primary,
          isSelected: s.selectedRole == UserRole.consumer,
          onTap: () => n.updateRole(UserRole.consumer),
          features: [
            context.l10n.buyerFeature1,
            context.l10n.buyerFeature2,
            context.l10n.buyerFeature3,
            context.l10n.buyerFeature4,
          ],
        ),
        RoleSelectorCard(
          title: context.l10n.iAmSeller,
          subtitle: context.l10n.sellerSubtitle,
          icon: LucideIcons.store,
          accentColor: AppColors.accent,
          selectionBorderColor: AppColors.accent,
          isSelected: s.selectedRole == UserRole.vendor,
          onTap: () => n.updateRole(UserRole.vendor),
          features: [
            context.l10n.sellerFeature1,
            context.l10n.sellerFeature2,
            context.l10n.sellerFeature3,
            context.l10n.sellerFeature4,
          ],
        ),
        const Gap(AppSpacing.xl),
        AuthDivider(label: context.l10n.socialLoginDivider),
        const Gap(AppSpacing.xl),
        const SocialLoginRow(),
      ],
    );
  }
}

class _StepPersonal extends StatelessWidget {
  const _StepPersonal({
    required this.s,
    required this.n,
    required this.fullName,
    required this.fullNameAr,
    required this.email,
    required this.phone,
    required this.location,
    required this.onPickDob,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController fullName;
  final TextEditingController fullNameAr;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController location;
  final VoidCallback onPickDob;

  @override
  Widget build(BuildContext context) {
    final dobLabel = s.dateOfBirth == null
        ? context.l10n.dateOfBirthOptional
        : DateFormat('d MMM yyyy').format(s.dateOfBirth!);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        Text(
          context.l10n.tellUsAboutYou,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          context.l10n.infoOnProfile,
          style:
              AppTypography.body15.copyWith(color: context.textSecondary),
        ),
        const Gap(AppSpacing.xl),
        AuthTextField(
          label: context.l10n.fullNameRequired,
          controller: fullName,
          prefixIcon: const Icon(LucideIcons.user),
          errorText: s.stepErrors['fullName'],
          onChanged: (v) => n.updateField(fullName: v),
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        AuthTextField(
          label: context.l10n.fullNameArRequired,
          controller: fullNameAr,
          prefixIcon: const Icon(LucideIcons.user),
          errorText: s.stepErrors['fullNameAr'],
          onChanged: (v) => n.updateField(fullNameAr: v),
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: email,
          builder: (context, val, _) {
            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.text.trim());
            return AuthTextField(
              label: context.l10n.emailAddressOptional,
              controller: email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(LucideIcons.mail),
              errorText: s.stepErrors['email'],
              suffixIcon: ok
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
              onChanged: (v) => n.updateField(email: v),
            );
          },
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        PhoneInputField(
          controller: phone,
          errorText: s.stepErrors['phone'],
          onChanged: (v) => n.updateField(
            phoneNumber: v.replaceAll(RegExp(r'\D'), ''),
          ),
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        AuthTextField(
          label: context.l10n.dateOfBirthOptional,
          readOnly: true,
          onTap: onPickDob,
          hint: dobLabel,
          prefixIcon: const Icon(LucideIcons.calendar),
          errorText: s.stepErrors['dob'],
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        AuthTextField(
          label: context.l10n.locationCityRequired,
          hint: context.l10n.locationHintAlgiers,
          controller: location,
          prefixIcon: const Icon(LucideIcons.mapPin),
          errorText: s.stepErrors['location'],
          onChanged: (v) => n.updateField(location: v),
        ),
      ],
    );
  }
}

class _StepSecurity extends StatelessWidget {
  const _StepSecurity({
    required this.s,
    required this.n,
    required this.password,
    required this.confirm,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController password;
  final TextEditingController confirm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        Text(
          context.l10n.secureYourAccount,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          context.l10n.strongPasswordHint,
          style:
              AppTypography.body15.copyWith(color: context.textSecondary),
        ),
        const Gap(AppSpacing.xl),
        AuthTextField(
          label: context.l10n.passwordRequired,
          hint: '********',
          controller: password,
          obscureText: !s.isPasswordVisible,
          prefixIcon: const Icon(LucideIcons.lock),
          suffixIcon: IconButton(
            onPressed: () => n.togglePasswordVisibility(),
            icon: Icon(
              s.isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
              color: context.iconSecondary,
            ),
          ),
          errorText: s.stepErrors['password'],
          onChanged: n.updatePasswordFields,
        ),
        const Gap(AppSpacing.md),
        PasswordStrengthBar(password: s.password),
        const Gap(AppSpacing.lg),
        AuthTextField(
          label: context.l10n.confirmPasswordRequired,
          hint: '********',
          controller: confirm,
          obscureText: !s.isConfirmPasswordVisible,
          prefixIcon: const Icon(LucideIcons.shieldCheck),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s.password.isNotEmpty &&
                  s.password == s.confirmPassword &&
                  s.confirmPassword.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.check_circle, color: AppColors.success),
                ),
              IconButton(
                onPressed: () => n.toggleConfirmPasswordVisibility(),
                icon: Icon(
                  s.isConfirmPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: context.iconSecondary,
                ),
              ),
            ],
          ),
          errorText: s.stepErrors['confirm'],
          onChanged: n.updateConfirmPassword,
        ),
        const Gap(AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: s.agreedToTerms,
              activeColor: AppColors.primary,
              onChanged: (_) => n.toggleAgreedToTerms(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.spacing10),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      context.l10n.agreeTo,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        context.l10n.termsOfService,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.andWord,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        context.l10n.privacyPolicy,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (s.stepErrors.containsKey('terms'))
          Text(
            s.stepErrors['terms']!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
      ],
    );
  }
}

class _StepStore extends ConsumerWidget {
  const _StepStore({
    required this.s,
    required this.n,
    required this.storeName,
    required this.storeNameAr,
    required this.storeDesc,
    required this.storeDescAr,
    required this.whatsapp,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController storeName;
  final TextEditingController storeNameAr;
  final TextEditingController storeDesc;
  final TextEditingController storeDescAr;
  final TextEditingController whatsapp;

  /// Renders a labeled dropdown for a reference-data lookup (city / government
  /// / store category), sourced from an [AsyncValue] provider.
  Widget _lookupDropdown<T>({
    required BuildContext context,
    required AsyncValue<List<T>> async,
    required int? value,
    required int Function(T) idOf,
    required String Function(T) labelOf,
    required String hint,
    required ValueChanged<int?> onChanged,
    String? errorText,
  }) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Text(
        context.l10n.genericError,
        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
      ),
      data: (items) => DropdownButtonFormField<int>(
        // ignore: deprecated_member_use
        value: value != null && items.any((e) => idOf(e) == value)
            ? value
            : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.surfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          errorText: errorText,
        ),
        hint: Text(hint),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: idOf(e),
                child: Text(labelOf(e)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(appIsArabicProvider);
    final initials = s.storeName.isEmpty
        ? '?'
        : s.storeName
            .trim()
            .split(RegExp(r'\s+'))
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        Text(
          context.l10n.setUpYourStore,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          context.l10n.tellBuyersStore,
          style:
              AppTypography.body15.copyWith(color: context.textSecondary),
        ),
        const Gap(AppSpacing.xl),
        AuthTextField(
          label: context.l10n.storeNameRequired,
          hint: context.l10n.storeNameHint,
          controller: storeName,
          prefixIcon: const Icon(LucideIcons.store),
          errorText: s.stepErrors['storeName'],
          onChanged: (v) => n.updateField(storeName: v),
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        AuthTextField(
          label: context.l10n.storeNameArRequired,
          controller: storeNameAr,
          prefixIcon: const Icon(LucideIcons.store),
          errorText: s.stepErrors['storeNameAr'],
          onChanged: (v) => n.updateField(storeNameAr: v),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Your store URL: xstore.com/store/${s.storeSlug}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSpacing.lg),
        Text(
          context.l10n.storeCategoryRequired,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const Gap(AppSpacing.sm),
        _lookupDropdown<StoreCategoryEntity>(
          context: context,
          async: ref.watch(allStoreCategoriesProvider),
          value: s.storeCategoryId,
          idOf: (e) => e.id,
          labelOf: (e) => e.name.resolve(isArabic),
          hint: context.l10n.storeSellHint,
          errorText: s.stepErrors['storeCategory'],
          onChanged: (v) => n.updateField(storeCategoryId: v),
        ),
        const Gap(AppSpacing.lg),
        AuthTextField(
          label: context.l10n.storeDescriptionRequired,
          hint: context.l10n.storeDescriptionHint,
          controller: storeDesc,
          maxLines: 3,
          errorText: s.stepErrors['storeDescription'],
          onChanged: (v) => n.updateField(storeDescription: v),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${s.storeDescription.length}/300',
            style: AppTypography.body12.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        const Gap(AppSpacing.lg),
        AuthTextField(
          label: context.l10n.storeDescriptionArRequired,
          controller: storeDescAr,
          maxLines: 3,
          errorText: s.stepErrors['storeDescriptionAr'],
          onChanged: (v) => n.updateField(storeDescriptionAr: v),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${s.storeDescriptionAr.length}/300',
            style: AppTypography.body12.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        const Gap(AppSpacing.lg),
        Text(
          context.l10n.storeLogoOptional,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(AppSpacing.spacing10),
        Center(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => n.pickStoreLogo(),
              customBorder: const CircleBorder(),
              child: ClipOval(
                child: s.storeLogoPath != null
                    ? Image.file(
                        File(s.storeLogoPath!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
        const Gap(AppSpacing.lg),
        if (s.stepErrors.containsKey('storeLocation'))
          Text(
            s.stepErrors['storeLocation']!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _lookupDropdown<CityEntity>(
                context: context,
                async: ref.watch(allCitiesProvider),
                value: s.storeCityId,
                idOf: (e) => e.id,
                labelOf: (e) => e.name.resolve(isArabic),
                hint: context.l10n.cityRequired,
                onChanged: (v) => n.updateField(storeCityId: v),
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: _lookupDropdown<GovernmentEntity>(
                context: context,
                async: ref.watch(allGovernmentsProvider),
                value: s.storeGovernmentId,
                idOf: (e) => e.id,
                labelOf: (e) => e.name.resolve(isArabic),
                hint: context.l10n.wilayaRequired,
                onChanged: (v) => n.updateField(storeGovernmentId: v),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.inputContentPaddingH),
        PhoneInputField(
          controller: whatsapp,
          onChanged: (v) => n.updateField(
            whatsappNumber: v.replaceAll(RegExp(r'\D'), ''),
          ),
        ),
      ],
    );
  }
}

class _VendorSuccessOverlay extends ConsumerWidget {
  const _VendorSuccessOverlay({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.black.withValues(alpha: context.isDark ? 0.65 : 0.54),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.x2l),
          padding: const EdgeInsets.all(AppSpacing.spacing28),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, v, child) {
                  return Transform.scale(
                    scale: v,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing18),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.white, size: 48),
                ),
              ),
              const Gap(AppSpacing.xl),
              Text(
                context.l10n.vendorWelcome(
                  name.isEmpty ? context.l10n.sellerFallbackName : name.split(' ').first,
                ),
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(AppSpacing.spacing10),
              Text(
                context.l10n.storeReady,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const Gap(AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.goToMyStore,
                onPressed: () {
                  ref.read(registerNotifierProvider.notifier).dismissVendorSuccessOverlay();
                  context.go(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
