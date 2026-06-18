import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_routes.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../shared/widgets/xstore_button.dart';

/// Honest placeholder for features not yet built — clearer than generic
/// “Coming Soon” without inventing backend or legal content.
class TrustInfoScreen extends StatelessWidget {
  const TrustInfoScreen({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actions = const [],
  });

  final String title;
  final String message;
  final IconData icon;
  final List<TrustInfoAction> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: AppSpacing.x4l, color: context.textSecondary),
              const Gap(AppSpacing.lg),
              Text(
                title,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.md),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              for (final action in actions) ...[
                XstoreButton(
                  label: action.label,
                  onPressed: action.onPressed,
                ),
                const Gap(AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TrustInfoAction {
  const TrustInfoAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class PaymentMethodsInfoScreen extends StatelessWidget {
  const PaymentMethodsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustInfoScreen(
      title: context.l10n.menuPaymentMethods,
      message: context.l10n.trustInfoPaymentMethodsBody,
      icon: LucideIcons.creditCard,
      actions: [
        TrustInfoAction(
          label: context.l10n.trustInfoActionCheckout,
          onPressed: () => context.push(AppRoutes.checkout),
        ),
      ],
    );
  }
}

class AddressesInfoScreen extends StatelessWidget {
  const AddressesInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustInfoScreen(
      title: context.l10n.menuAddresses,
      message: context.l10n.trustInfoAddressesBody,
      icon: LucideIcons.mapPin,
      actions: [
        TrustInfoAction(
          label: context.l10n.trustInfoActionCheckout,
          onPressed: () => context.push(AppRoutes.checkout),
        ),
      ],
    );
  }
}

class TermsInfoScreen extends StatelessWidget {
  const TermsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustInfoScreen(
      title: context.l10n.menuTerms,
      message: context.l10n.trustInfoTermsBody,
      icon: LucideIcons.fileText,
    );
  }
}

class PrivacyInfoScreen extends StatelessWidget {
  const PrivacyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustInfoScreen(
      title: context.l10n.menuPrivacy,
      message: context.l10n.trustInfoPrivacyBody,
      icon: LucideIcons.shield,
    );
  }
}

class HelpCenterInfoScreen extends StatelessWidget {
  const HelpCenterInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustInfoScreen(
      title: context.l10n.menuHelpCenter,
      message: context.l10n.trustInfoHelpBody,
      icon: LucideIcons.messageCircle,
      actions: [
        TrustInfoAction(
          label: context.l10n.trustInfoHelpViewOrders,
          onPressed: () => context.push(AppRoutes.orders),
        ),
        TrustInfoAction(
          label: context.l10n.trustInfoHelpNotifications,
          onPressed: () => context.push(AppRoutes.notificationSettings),
        ),
      ],
    );
  }
}
