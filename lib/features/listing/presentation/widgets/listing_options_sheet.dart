import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/listing_entity.dart';

/// Bottom sheet: listing actions (edit, pause/resume, stats, delete).
class ListingOptionsSheet extends StatelessWidget {
  const ListingOptionsSheet({
    super.key,
    required this.listing,
    required this.onEdit,
    required this.onPause,
    required this.onResume,
    required this.onViewStats,
    required this.onDelete,
  });

  final ListingEntity listing;
  final VoidCallback onEdit;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onViewStats;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final showPause = listing.status == ListingStatus.active;
    final showResume = listing.status == ListingStatus.paused;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(AppSpacing.sm),
            Center(
              child: Container(
                width: AppSpacing.x3l + AppSpacing.sm,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
              ),
            ),
            const Gap(AppSpacing.lg),
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: const Text(AppStrings.editListingMenu),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            if (showPause)
              ListTile(
                leading: const Icon(LucideIcons.pauseCircle),
                title: const Text(AppStrings.pauseListing),
                onTap: () {
                  Navigator.of(context).pop();
                  onPause();
                },
              ),
            if (showResume)
              ListTile(
                leading: const Icon(LucideIcons.playCircle),
                title: const Text(AppStrings.resumeListing),
                onTap: () {
                  Navigator.of(context).pop();
                  onResume();
                },
              ),
            ListTile(
              leading: const Icon(LucideIcons.barChart2),
              title: const Text(AppStrings.viewStatsMenu),
              onTap: () {
                Navigator.of(context).pop();
                onViewStats();
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.trash2, color: Theme.of(context).colorScheme.error),
              title: Text(
                AppStrings.deleteListing,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
            const Gap(AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

/// Secondary sheet: views, saves, inquiries.
class ListingStatsSheet extends StatelessWidget {
  const ListingStatsSheet({super.key, required this.listing});

  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.listingStatsHeading,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(AppSpacing.x2l),
            _StatRow(
              icon: LucideIcons.eye,
              label: AppStrings.listingViews,
              value: '${listing.viewCount}',
            ),
            const Gap(AppSpacing.lg),
            _StatRow(
              icon: LucideIcons.bookmark,
              label: AppStrings.listingSaves,
              value: '${listing.saveCount}',
            ),
            const Gap(AppSpacing.lg),
            _StatRow(
              icon: LucideIcons.messageCircle,
              label: AppStrings.listingInquiries,
              value: '${listing.inquiryCount}',
            ),
            const Gap(AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const Gap(AppSpacing.lg),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
