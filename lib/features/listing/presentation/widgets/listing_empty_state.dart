import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../../shared/widgets/xstore_button.dart';

/// Centered illustration + CTA when no listings match the current filter.
class ListingEmptyState extends StatelessWidget {
  const ListingEmptyState({
    super.key,
    required this.selectedFilter,
    required this.onAddListing,
  });

  final ListingStatus? selectedFilter;
  final VoidCallback onAddListing;

  String _title(BuildContext context) {
    final l10n = context.l10n;
    final filter = selectedFilter;
    if (filter == null) return l10n.listingsEmptyNone;
    final label = switch (filter) {
      ListingStatus.draft => l10n.draft,
      ListingStatus.pending => l10n.pending,
      ListingStatus.active => l10n.active,
      ListingStatus.paused => l10n.paused,
      ListingStatus.sold => l10n.sold,
      ListingStatus.rejected => l10n.rejected,
    };
    return l10n.listingsEmptyFiltered(label);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.packageOpen,
                size: AppSpacing.x4l + AppSpacing.lg,
                color: context.linkColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.x2l),
              Text(
                _title(context),
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.listingsEmptySubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.listingsEmptyCta,
                onPressed: onAddListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
