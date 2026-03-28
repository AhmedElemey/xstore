import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/listing_entity.dart';

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
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(
                _emptyShelfSvg,
                width: 168,
                height: 140,
              ),
              const Gap(AppSpacing.lg),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.sm),
              Text(
                'Start selling by adding your first listing',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSpacing.lg),
              FilledButton(
                onPressed: onAddListing,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 2,
                  ),
                ),
                child: const Text('Add Your First Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal inline SVG: empty shelf / box (no asset folder required).
const _emptyShelfSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 100" fill="none">
  <rect x="14" y="38" width="92" height="52" rx="10" fill="#E2E8F0"/>
  <rect x="22" y="46" width="76" height="8" rx="4" fill="#CBD5E1"/>
  <rect x="22" y="60" width="52" height="8" rx="4" fill="#CBD5E1"/>
  <path d="M40 38V22c0-4 4-8 10-8h20c6 0 10 4 10 8v16" stroke="#94A3B8" stroke-width="3" stroke-linecap="round"/>
  <circle cx="68" cy="26" r="5" fill="#2563EB" opacity="0.25"/>
</svg>
''';
