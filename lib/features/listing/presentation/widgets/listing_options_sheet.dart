import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
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
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(AppSpacing.xs),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Listing'),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            if (showPause)
              ListTile(
                leading: const Icon(Icons.pause_circle_outline),
                title: const Text('Pause'),
                onTap: () {
                  Navigator.of(context).pop();
                  onPause();
                },
              ),
            if (showResume)
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Resume'),
                onTap: () {
                  Navigator.of(context).pop();
                  onResume();
                },
              ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('View Stats'),
              onTap: () {
                Navigator.of(context).pop();
                onViewStats();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
            const Gap(AppSpacing.sm),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listing stats',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(AppSpacing.lg),
            _StatRow(icon: Icons.visibility_outlined, label: 'Views', value: '${listing.viewCount}'),
            const Gap(AppSpacing.md),
            _StatRow(icon: Icons.bookmark_border, label: 'Saves', value: '${listing.saveCount}'),
            const Gap(AppSpacing.md),
            _StatRow(icon: Icons.chat_bubble_outline, label: 'Inquiries', value: '${listing.inquiryCount}'),
            const Gap(AppSpacing.md),
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
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const Gap(AppSpacing.md),
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
