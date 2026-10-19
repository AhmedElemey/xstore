import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../legal/xstore_legal_documents.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/orbit_background.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(title: title),
              Expanded(child: _body(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.x2l,
      ),
      itemCount: sections.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.glassColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: context.amberColor.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  context.l10n.legalDraftNotice,
                  style: AppTypography.bodySmall.copyWith(
                    height: 1.45,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }
        final section = sections[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                section.body,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.5,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Orbit header: frosted back button (when there is a route to return to)
/// and an Unbounded title.
class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.spacing18,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop()) ...[
            const AuthBackButton(),
            const Gap(AppSpacing.md),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 20,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
