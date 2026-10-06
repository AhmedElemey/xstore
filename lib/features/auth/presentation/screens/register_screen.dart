import 'dart:io';
import 'dart:math' as math;

import '../../../../core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/legal_links.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/birth_date_picker.dart';
import '../../../../shared/widgets/location_cascade_field.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../store_categories/domain/entities/store_category_entity.dart';
import '../../../store_categories/presentation/providers/store_category_dependencies.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_states.dart';
import '../providers/social_auth_provider.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/role_selector_card.dart';
import '../widgets/auth_divider.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/phone_input_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.googlePrefill});

  /// Google profile of a sign-in that matched no account; its email and
  /// name prefill step 2. The user still picks a role, phone and password.
  final SocialAuthResult? googlePrefill;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _storeName = TextEditingController();
  final _storeDesc = TextEditingController();
  final _whatsapp = TextEditingController();

  /// Email came from a Google sign-in — it's the identity being registered,
  /// so it can't be edited.
  var _emailFromGoogle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(registerNotifierProvider.notifier).reset();
      final prefill = widget.googlePrefill;
      if (prefill != null) _applyGooglePrefill(prefill);
    });
  }

  void _applyGooglePrefill(SocialAuthResult r) {
    final name = r.displayName?.trim() ?? '';
    final email = r.email?.trim() ?? '';
    if (name.isNotEmpty) _fullName.text = name;
    if (email.isNotEmpty) {
      _email.text = email;
      setState(() => _emailFromGoogle = true);
    }
    ref.read(registerNotifierProvider.notifier)
      ..updateField(
        fullName: name.isEmpty ? null : name,
        email: email.isEmpty ? null : email,
      )
      // Sent as `idToken` + `clientId` on the register request.
      ..setSocialIdToken(r.idToken);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _storeName.dispose();
    _storeDesc.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _pickDob(RegisterNotifier n, RegisterState s) async {
    final l10n = context.l10n;
    final now = DateTime.now();
    final d = await pickBirthDate(
      context,
      selected: s.dateOfBirth,
      fallback: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
    );
    if (!mounted || d == null) return;
    n.applyDateOfBirth(d, l10n);
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
    if (leave != true || !mounted) return;
    // Google "no account" reaches register via `go`, leaving nothing to pop.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _onBack(RegisterState s, RegisterNotifier n) {
    if (s.currentStep > 1) {
      n.previousStep();
    } else {
      _confirmExit();
    }
  }

  bool _primaryEnabled(RegisterState s) {
    if (s.isLoading) return false;
    if (s.currentStep == 1 && s.selectedRole == null) return false;
    final l10n = context.l10n;
    if (s.currentStep == 2) {
      if (Validators.registerEmail(l10n, s.email) != null) return false;
      if (Validators.registerPhoneEgypt(l10n, rawInput: s.phoneNumber) !=
          null) {
        return false;
      }
    }
    if (s.currentStep == 3) {
      if (Validators.registerPassword(l10n, s.password) != null) return false;
      if (Validators.confirmPasswordMatches(
            l10n,
            s.password,
            s.confirmPassword,
          ) !=
          null) {
        return false;
      }
      if (!s.agreedToTerms) return false;
    }
    if (s.currentStep == 4) {
      final wa = s.whatsappNumber.trim();
      if (wa.isNotEmpty &&
          Validators.registerPhoneEgypt(l10n, rawInput: wa) != null) {
        return false;
      }
    }
    return true;
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
    // Already on the register screen (Google via the same GoogleSignInButton
    // matched no account) — prefill in place, no navigation needed.
    ref.listen(socialAuthProvider.select((s) => s.googleRegistration), (
      prev,
      next,
    ) {
      if (next != null && mounted) {
        ref.read(socialAuthProvider.notifier).acknowledgeNeedsRegistration();
        _applyGooglePrefill(next);
      }
    });
    ref.listen(socialAuthProvider.select((s) => s.error), (prev, next) {
      if (next != null && next != prev && mounted) {
        AppSnackbar.error(context, next);
      }
    });

    final labels = s.totalSteps == 4
        ? [
            context.l10n.stepRole,
            context.l10n.stepInfo,
            context.l10n.stepSecurity,
            context.l10n.stepStore,
          ]
        : [
            context.l10n.stepRole,
            context.l10n.stepInfo,
            context.l10n.stepSecurity,
          ];
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        AuthBackButton(onPressed: () => _onBack(s, n)),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: Text(
                            context.l10n
                                .stepOf(s.currentStep, s.totalSteps)
                                .toUpperCase(),
                            style: AppTypography.mono.copyWith(
                              fontSize: AppTypography.rem(0.75),
                              color: context.labelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.spacing18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _StepTrail(current: s.currentStep, labels: labels),
                  ),
                  const Gap(AppSpacing.x2l),
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
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      AppSpacing.md,
                      24,
                      28,
                    ),
                    child: XstoreButton(
                      label:
                          s.selectedRole == UserRole.vendor &&
                              s.currentStep == 4
                          ? context.l10n.createMyStore
                          : context.l10n.continueLabel,
                      isLoading: s.isLoading,
                      onPressed: _primaryEnabled(s)
                          ? () => _onPrimary(s, n)
                          : null,
                    ),
                  ),
                ],
              ),
              if (s.showVendorSuccessOverlay)
                _VendorSuccessOverlay(name: s.fullName),
            ],
          ),
        ),
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
          email: _email,
          emailReadOnly: _emailFromGoogle,
          phone: _phone,
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
          storeDesc: _storeDesc,
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
      padding: _stepPadding,
      children: [
        _StepHeading(
          title: context.l10n.joinAs,
          subtitle: context.l10n.chooseHowUse,
        ),
        if (s.stepErrors.containsKey('role'))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              s.stepErrors['role']!,
              style: AppTypography.bodySmall.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
        RoleSelectorCard(
          title: context.l10n.iAmBuyer,
          subtitle: context.l10n.buyerSubtitle,
          icon: LucideIcons.shoppingBag,
          orbColors: const [
            AppColors.white,
            AppColors.primaryLight,
            AppColors.primary,
          ],
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
          orbColors: const [
            AppColors.white,
            AppColors.accentLight,
            AppColors.darkSecondary,
          ],
          isSelected: s.selectedRole == UserRole.vendor,
          onTap: () => n.updateRole(UserRole.vendor),
          features: [
            context.l10n.sellerFeature1,
            context.l10n.sellerFeature2,
            context.l10n.sellerFeature3,
          ],
        ),
        const Gap(AppSpacing.xl),
        AuthDivider(label: context.l10n.socialLoginDivider),
        const Gap(AppSpacing.xl),
        const GoogleSignInButton(),
      ],
    );
  }
}

class _StepPersonal extends StatelessWidget {
  const _StepPersonal({
    required this.s,
    required this.n,
    required this.fullName,
    required this.email,
    required this.emailReadOnly,
    required this.phone,
    required this.onPickDob,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController fullName;
  final TextEditingController email;
  final bool emailReadOnly;
  final TextEditingController phone;
  final VoidCallback onPickDob;

  @override
  Widget build(BuildContext context) {
    final dobLabel = s.dateOfBirth == null
        ? context.l10n.dateOfBirthOptional
        : context.formatDate(s.dateOfBirth!);

    return ListView(
      padding: _stepPadding,
      children: [
        _StepHeading(
          title: context.l10n.tellUsAboutYou,
          subtitle: context.l10n.infoOnProfile,
        ),
        AuthTextField(
          label: context.l10n.fullNameRequired,
          hint: context.l10n.fullNameHint,
          controller: fullName,
          prefixIcon: const Icon(LucideIcons.user),
          errorText: s.stepErrors['fullName'],
          onChanged: (v) => n.updateField(fullName: v),
        ),
        const Gap(AppSpacing.lg),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: email,
          builder: (context, val, _) {
            final ok = Validators.registerEmail(context.l10n, val.text) == null;
            return AuthTextField(
              label: context.l10n.emailAddressRequired,
              hint: context.l10n.enterEmailHint,
              controller: email,
              readOnly: emailReadOnly,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(LucideIcons.mail),
              errorText: s.stepErrors['email'],
              suffixIcon: emailReadOnly
                  ? Icon(LucideIcons.lock, color: context.textSecondary)
                  : ok
                  ? Icon(Icons.check_circle, color: _successColor(context))
                  : null,
              onChanged: (v) => n.updateField(email: v),
            );
          },
        ),
        const Gap(AppSpacing.lg),
        PhoneInputField(
          controller: phone,
          errorText: s.stepErrors['phone'],
          onChanged: (v) =>
              n.updateField(phoneNumber: v.replaceAll(RegExp(r'\D'), '')),
        ),
        const Gap(AppSpacing.lg),
        AuthTextField(
          label: context.l10n.dateOfBirthOptional,
          readOnly: true,
          onTap: onPickDob,
          hint: dobLabel,
          prefixIcon: const Icon(LucideIcons.calendar),
          errorText: s.stepErrors['dob'],
        ),
        const Gap(AppSpacing.lg),
        LocationCascadeField(
          cityId: s.storeCityId,
          governorateId: s.storeGovernmentId,
          errorText: s.stepErrors['storeLocation'],
          onChanged: (cityId, governorateId) => n.updateStoreLocation(
            storeCityId: cityId,
            storeGovernmentId: governorateId,
          ),
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
      padding: _stepPadding,
      children: [
        _StepHeading(
          title: context.l10n.secureYourAccount,
          subtitle: context.l10n.strongPasswordHint,
        ),
        AuthTextField(
          label: context.l10n.passwordRequired,
          hint: context.l10n.passwordMask,
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
          hint: context.l10n.passwordMask,
          controller: confirm,
          obscureText: !s.isConfirmPasswordVisible,
          prefixIcon: const Icon(LucideIcons.shieldCheck),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s.password.isNotEmpty &&
                  s.password == s.confirmPassword &&
                  s.confirmPassword.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: _successColor(context),
                  ),
                ),
              IconButton(
                onPressed: () => n.toggleConfirmPasswordVisibility(),
                icon: Icon(
                  s.isConfirmPasswordVisible
                      ? LucideIcons.eyeOff
                      : LucideIcons.eye,
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
                      onTap: () => launchLegalUrl(xstoreTermsUrl),
                      child: Text(
                        context.l10n.termsOfService,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.linkColor,
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
                      onTap: () => launchLegalUrl(xstorePrivacyUrl),
                      child: Text(
                        context.l10n.privacyPolicy,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.linkColor,
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
            style: AppTypography.bodySmall.copyWith(
              color: context.colorScheme.error,
            ),
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
    required this.storeDesc,
    required this.whatsapp,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController storeName;
  final TextEditingController storeDesc;
  final TextEditingController whatsapp;

  /// Renders a labeled dropdown for a reference-data lookup (store category
  /// from `GET /api/categories`), sourced from an [AsyncValue] provider.
  Widget _lookupDropdown<T>({
    required BuildContext context,
    required AsyncValue<List<T>> async,
    required int? value,
    required int Function(T) idOf,
    required String Function(T) labelOf,
    required String hint,
    required ValueChanged<int?> onChanged,
    String? errorText,
    VoidCallback? onRetry,
  }) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.genericError,
            style: AppTypography.bodySmall.copyWith(
              color: context.colorScheme.error,
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
      data: (items) => DropdownButtonFormField<int>(
        // ignore: deprecated_member_use
        value: value != null && items.any((e) => idOf(e) == value)
            ? value
            : null,
        decoration: InputDecoration(errorText: errorText),
        hint: Text(hint),
        items: items
            .map(
              (e) => DropdownMenuItem(value: idOf(e), child: Text(labelOf(e))),
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
      padding: _stepPadding,
      children: [
        _StepHeading(
          title: context.l10n.setUpYourStore,
          subtitle: context.l10n.tellBuyersStore,
        ),
        AuthTextField(
          label: context.l10n.storeNameRequired,
          hint: context.l10n.storeNameHint,
          controller: storeName,
          prefixIcon: const Icon(LucideIcons.store),
          errorText: s.stepErrors['storeName'],
          onChanged: (v) => n.updateField(storeName: v),
        ),
        const Gap(AppSpacing.sm),
        Text(
          context.l10n.storeUrlPreview(s.storeSlug),
          style: AppTypography.bodySmall.copyWith(
            color: context.linkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSpacing.lg),
        Text(
          context.l10n.storeCategoryRequired.toUpperCase(),
          style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
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
          onRetry: () => ref.invalidate(allStoreCategoriesProvider),
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
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            '${s.storeDescription.length}/300',
            style: AppTypography.mono.copyWith(
              fontSize: AppTypography.rem(0.75),
              color: context.labelColor,
            ),
          ),
        ),
        const Gap(AppSpacing.lg),
        Text(
          context.l10n.storeLogoRequired.toUpperCase(),
          style: AppTypography.fieldLabel.copyWith(
            color: s.stepErrors.containsKey('storeLogo')
                ? context.colorScheme.error
                : context.labelColor,
          ),
        ),
        const Gap(AppSpacing.spacing10),
        Center(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => n.pickStoreLogo(),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: context.brandGradient.first.withValues(alpha: 0.3),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: s.storeLogoPath != null
                      ? Image.file(
                          File(s.storeLogoPath!),
                          width: 100,
                          height: 100,
                          cacheWidth:
                              (100 * MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                              colors: context.brandGradient,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: AppTypography.displayMedium.copyWith(
                              color: context.onBrandColor,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        if (s.stepErrors.containsKey('storeLogo')) ...[
          const Gap(AppSpacing.sm),
          Center(
            child: Text(
              s.stepErrors['storeLogo']!,
              style: AppTypography.bodySmall.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
        ],
        const Gap(AppSpacing.lg),
        PhoneInputField(
          controller: whatsapp,
          onChanged: (v) =>
              n.updateField(whatsappNumber: v.replaceAll(RegExp(r'\D'), '')),
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
            color: context.elevatedSurfaceColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, v, child) {
                  return Transform.scale(scale: v, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing18),
                  decoration: BoxDecoration(
                    color: _successColor(context),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _successColor(context).withValues(alpha: 0.5),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: context.isDark
                        ? AppColors.darkBackground
                        : AppColors.white,
                    size: 48,
                  ),
                ),
              ),
              const Gap(AppSpacing.xl),
              Text(
                context.l10n.vendorWelcome(
                  name.isEmpty
                      ? context.l10n.sellerFallbackName
                      : name.split(' ').first,
                ),
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: AppTypography.rem(1.375),
                  color: context.textPrimary,
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
                onPressed: () async {
                  ref
                      .read(registerNotifierProvider.notifier)
                      .dismissVendorSuccessOverlay();
                  await maybeShowLocationPermissionPrompt(context, ref);
                  if (!context.mounted) return;
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

const _stepPadding = EdgeInsets.symmetric(horizontal: 24);

Color _successColor(BuildContext context) =>
    context.isDark ? AppColors.successLight : AppColors.success;

/// Display title and supporting line at the top of each step.
class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          const Gap(AppSpacing.spacing10),
          Text(
            subtitle,
            style: AppTypography.body15.copyWith(
              height: 1.4,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Orbit step progress: a filled check node per finished step, a glowing
/// ring for the current one, faint rings ahead; solid trail behind, dashed
/// trail ahead. Step names sit underneath.
class _StepTrail extends StatelessWidget {
  const _StepTrail({required this.current, required this.labels});

  /// 1-based current step.
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final brand = context.isDark ? AppColors.primaryLight : AppColors.primary;
    final faint = (context.isDark ? AppColors.darkTextLabel : AppColors.primary)
        .withValues(alpha: 0.4);
    final count = labels.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var step = 1; step <= count; step++) ...[
              _node(context, step, brand, faint),
              if (step < count)
                Expanded(
                  child: step < current
                      ? Container(height: 2, color: brand)
                      : CustomPaint(
                          size: const Size.fromHeight(2),
                          painter: _DashPainter(faint),
                        ),
                ),
            ],
          ],
        ),
        const Gap(AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var step = 1; step <= count; step++)
              Text(
                labels[step - 1],
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: step < current
                      ? context.linkColor
                      : step == current
                      ? context.textPrimary
                      : context.labelColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _node(BuildContext context, int step, Color brand, Color faint) {
    const size = 28.0;
    if (step < current) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brand,
          boxShadow: [
            BoxShadow(color: brand.withValues(alpha: 0.6), blurRadius: 14),
          ],
        ),
        child: Icon(Icons.check_rounded, size: 16, color: context.onBrandColor),
      );
    }
    final isCurrent = step == current;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isCurrent ? brand : faint, width: 2),
        boxShadow: isCurrent
            ? [BoxShadow(color: brand.withValues(alpha: 0.5), blurRadius: 18)]
            : null,
      ),
      child: isCurrent
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: brand),
            )
          : null,
    );
  }
}

/// 6px-on / 6px-off horizontal line for the trail ahead.
class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += 12) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + 6, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
