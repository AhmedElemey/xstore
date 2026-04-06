import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_states.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/role_selector_card.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_login_row.dart';
import '../widgets/phone_input_field.dart';

const _storeCategories = [
  'Electronics',
  'Fashion',
  'Home',
  'Beauty',
  'Sports',
  'Books',
  'Food',
  'Automotive',
  'Mixed/Other',
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _storeName = TextEditingController();
  final _storeDesc = TextEditingController();
  final _storeCity = TextEditingController();
  final _storeWilaya = TextEditingController();
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
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _password.dispose();
    _confirm.dispose();
    _storeName.dispose();
    _storeDesc.dispose();
    _storeCity.dispose();
    _storeWilaya.dispose();
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
        title: Text('Leave registration?'),
        content: Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Leave'),
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
    if (s.selectedRole == UserRole.consumer && s.currentStep == 3) {
      await n.submitFromCurrentStep();
      return;
    }
    if (s.selectedRole == UserRole.vendor && s.currentStep == 4) {
      await n.submitFromCurrentStep();
      return;
    }
    n.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(registerNotifierProvider);
    final n = ref.read(registerNotifierProvider.notifier);

    ref.listen(registerNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    final labels = s.totalSteps == 4
        ? ['Role', 'Info', 'Security', 'Store']
        : ['Role', 'Info', 'Security'];
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Step ${s.currentStep} of ${s.totalSteps}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.textSecondary,
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    labels.length,
                    (i) => Expanded(
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
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
              const Gap(16),
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
                padding: const EdgeInsets.all(20),
                child: AuthButton(
                  label: s.selectedRole == UserRole.vendor && s.currentStep == 4
                      ? 'Create My Store'
                      : 'Continue',
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
          storeDesc: _storeDesc,
          storeCity: _storeCity,
          storeWilaya: _storeWilaya,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Join xStore as...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const Gap(10),
        Text(
          'Choose how you want to use xStore. You can always add the other role later.',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: context.textSecondary,
          ),
        ),
        const Gap(20),
        if (s.stepErrors.containsKey('role'))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              s.stepErrors['role']!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        RoleSelectorCard(
          title: "I'm a Buyer",
          subtitle: 'Discover and buy products from verified sellers',
          icon: LucideIcons.shoppingBag,
          accentColor: AppColors.primary,
          selectionBorderColor: AppColors.primary,
          isSelected: s.selectedRole == UserRole.consumer,
          onTap: () => n.updateRole(UserRole.consumer),
          features: const [
            'Browse thousands of products',
            'Secure checkout & payments',
            'Track your orders in real time',
            'Save favorites to wishlist',
          ],
        ),
        RoleSelectorCard(
          title: "I'm a Seller",
          subtitle: 'List your products and start earning today',
          icon: LucideIcons.store,
          accentColor: AppColors.accent,
          selectionBorderColor: AppColors.accent,
          isSelected: s.selectedRole == UserRole.vendor,
          onTap: () => n.updateRole(UserRole.vendor),
          features: const [
            'List unlimited products',
            'Manage orders & inventory',
            'Analytics & sales insights',
            'Direct chat with buyers',
          ],
        ),
        const Gap(20),
        const AuthDivider(label: AppStrings.socialLoginDivider),
        const Gap(20),
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
    required this.email,
    required this.phone,
    required this.location,
    required this.onPickDob,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController fullName;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController location;
  final VoidCallback onPickDob;

  @override
  Widget build(BuildContext context) {
    final dobLabel = s.dateOfBirth == null
        ? 'Date of Birth (optional)'
        : DateFormat('d MMM yyyy').format(s.dateOfBirth!);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Tell us about you',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(8),
        Text(
          'This information will be on your profile',
          style: TextStyle(color: context.textSecondary, fontSize: 15),
        ),
        const Gap(20),
        AuthTextField(
          label: 'Full Name *',
          controller: fullName,
          prefixIcon: const Icon(LucideIcons.user),
          errorText: s.stepErrors['fullName'],
          onChanged: (v) => n.updateField(fullName: v),
        ),
        const Gap(14),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: email,
          builder: (context, val, _) {
            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.text.trim());
            return AuthTextField(
              label: 'Email Address *',
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
        const Gap(14),
        PhoneInputField(
          controller: phone,
          errorText: s.stepErrors['phone'],
          onChanged: (v) => n.updateField(
            phoneNumber: v.replaceAll(RegExp(r'\D'), ''),
          ),
        ),
        const Gap(14),
        AuthTextField(
          label: 'Date of Birth (optional)',
          readOnly: true,
          onTap: onPickDob,
          hint: dobLabel,
          prefixIcon: const Icon(LucideIcons.calendar),
          errorText: s.stepErrors['dob'],
        ),
        const Gap(14),
        AuthTextField(
          label: 'Location / City *',
          hint: 'e.g. Algiers',
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Secure your account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(8),
        Text(
          'Choose a strong password to protect your account',
          style: TextStyle(color: context.textSecondary, fontSize: 15),
        ),
        const Gap(20),
        AuthTextField(
          label: 'Password *',
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
        const Gap(12),
        PasswordStrengthBar(password: s.password),
        const Gap(16),
        AuthTextField(
          label: 'Confirm Password *',
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
        const Gap(16),
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
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      'I agree to the',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    Text(
                      'and',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 14,
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
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
      ],
    );
  }
}

class _StepStore extends StatelessWidget {
  const _StepStore({
    required this.s,
    required this.n,
    required this.storeName,
    required this.storeDesc,
    required this.storeCity,
    required this.storeWilaya,
    required this.whatsapp,
  });

  final RegisterState s;
  final RegisterNotifier n;
  final TextEditingController storeName;
  final TextEditingController storeDesc;
  final TextEditingController storeCity;
  final TextEditingController storeWilaya;
  final TextEditingController whatsapp;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Set up your store',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(8),
        Text(
          'Tell buyers about your store',
          style: TextStyle(color: context.textSecondary, fontSize: 15),
        ),
        const Gap(20),
        AuthTextField(
          label: 'Store Name *',
          hint: "e.g. Ahmed's Electronics",
          controller: storeName,
          prefixIcon: const Icon(LucideIcons.store),
          errorText: s.stepErrors['storeName'],
          onChanged: (v) => n.updateField(storeName: v),
        ),
        const Gap(8),
        Text(
          'Your store URL: xstore.com/store/${s.storeSlug}',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(16),
        Text(
          'Store Category *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const Gap(8),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: s.storeCategory.isEmpty ? null : s.storeCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          hint: Text('What do you mainly sell?'),
          items: _storeCategories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) n.updateField(storeCategory: v);
          },
        ),
        if (s.stepErrors.containsKey('storeCategory'))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              s.stepErrors['storeCategory']!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        const Gap(16),
        AuthTextField(
          label: 'Store Description *',
          hint: 'Describe your store and what makes it unique...',
          controller: storeDesc,
          maxLines: 3,
          errorText: s.stepErrors['storeDescription'],
          onChanged: (v) => n.updateField(storeDescription: v),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${s.storeDescription.length}/300',
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
        ),
        const Gap(16),
        Text(
          'Store Logo (optional)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const Gap(10),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
        const Gap(16),
        if (s.stepErrors.containsKey('storeLocation'))
          Text(
            s.stepErrors['storeLocation']!,
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'City *',
                controller: storeCity,
                onChanged: (v) => n.updateField(storeCity: v),
              ),
            ),
            const Gap(12),
            Expanded(
              child: AuthTextField(
                label: 'Wilaya *',
                controller: storeWilaya,
                onChanged: (v) => n.updateField(storeWilaya: v),
              ),
            ),
          ],
        ),
        const Gap(14),
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
      color: Colors.black.withValues(alpha: context.isDark ? 0.65 : 0.54),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
              ),
              const Gap(20),
              Text(
                'Welcome to xStore, ${name.isEmpty ? 'Seller' : name.split(' ').first}! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(10),
              Text(
                'Your store is ready. Start listing!',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary),
              ),
              const Gap(24),
              AuthButton(
                label: 'Go to My Store',
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
