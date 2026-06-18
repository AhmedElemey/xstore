import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/listing_entity.dart';
import 'status_badge.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onDelete,
  });

  final ListingEntity listing;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    listing.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                StatusBadge(status: listing.status),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const Gap(AppSpacing.sm),
            Text(
              listing.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const Gap(AppSpacing.md),
            Text(
              context.formatCurrency(listing.price),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
