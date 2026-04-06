import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/social_auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/role_selector_card.dart';

class SocialRoleScreen extends ConsumerStatefulWidget {
  const SocialRoleScreen({super.key});

  @override
  ConsumerState<SocialRoleScreen> createState() => _SocialRoleScreenState();
}

class _SocialRoleScreenState extends ConsumerState<SocialRoleScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final social = ref.watch(socialAuthProvider);
    final pending = social.pendingSocialResult;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          const Expanded(
            flex: 42,
            child: AuthHeader(
              heightFraction: 1,
              title: AppStrings.chooseYourRole,
              subtitle: AppStrings.socialRoleSubtitle,
              logoSize: 32,
            ),
          ),
          Expanded(
            flex: 58,
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: context.surfaceVariantColor,
                      backgroundImage:
                          pending?.photoUrl == null ? null : NetworkImage(pending!.photoUrl!),
                      child: pending?.photoUrl == null
                          ? const Icon(Icons.person, size: 38)
                          : null,
                    ),
                    const Gap(10),
                    Text(
                      'Welcome, ${pending?.displayName ?? 'there'}! 👋',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(4),
                    Text(
                      'One last step — how will you use xStore?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSecondary),
                    ),
                    const Gap(18),
                    RoleSelectorCard(
                      title: "I'm a Buyer",
                      subtitle: 'Discover and buy products from verified sellers',
                      icon: Icons.shopping_bag_outlined,
                      accentColor: AppColors.primary,
                      selectionBorderColor: AppColors.primary,
                      isSelected: _selectedRole == UserRole.consumer,
                      onTap: () => setState(() => _selectedRole = UserRole.consumer),
                      features: const [
                        'Browse thousands of products',
                        'Secure checkout & payments',
                      ],
                    ),
                    RoleSelectorCard(
                      title: "I'm a Seller",
                      subtitle: 'List products and start earning today',
                      icon: Icons.storefront_outlined,
                      accentColor: AppColors.accent,
                      selectionBorderColor: AppColors.accent,
                      isSelected: _selectedRole == UserRole.vendor,
                      onTap: () => setState(() => _selectedRole = UserRole.vendor),
                      features: const [
                        'List unlimited products',
                        'Manage orders & inventory',
                      ],
                    ),
                    const Gap(12),
                    AuthButton(
                      label: 'Continue',
                      isLoading: social.isAnyLoading,
                      onPressed: _selectedRole == null
                          ? null
                          : () => ref
                              .read(socialAuthProvider.notifier)
                              .completeSocialRegistration(_selectedRole!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
