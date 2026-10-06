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

  String get _title {
    if (selectedFilter == null) {
      return 'No listings yet';
    }
    final label = switch (selectedFilter!) {
      ListingStatus.draft => 'Draft',
      ListingStatus.pending => 'Pending',
      ListingStatus.active => 'Active',
      ListingStatus.paused => 'Paused',
      ListingStatus.sold => 'Sold',
      ListingStatus.rejected => 'Rejected',
    };
    return 'No $label listings';
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
                _title,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start selling by adding your first listing',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              XstoreButton(
                label: 'Add Your First Listing',
                onPressed: onAddListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
