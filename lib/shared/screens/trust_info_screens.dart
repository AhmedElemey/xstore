import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../legal/xstore_legal_documents.dart';
import '../widgets/xstore_button.dart';
import 'legal_document_screen.dart';

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

class TermsInfoScreen extends StatelessWidget {
  const TermsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return LegalDocumentScreen(
      title: context.l10n.menuTerms,
      sections: isAr ? xstoreTermsAr : xstoreTermsEn,
    );
  }
}

class PrivacyInfoScreen extends StatelessWidget {
  const PrivacyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return LegalDocumentScreen(
      title: context.l10n.menuPrivacy,
      sections: isAr ? xstorePrivacyAr : xstorePrivacyEn,
    );
  }
}

