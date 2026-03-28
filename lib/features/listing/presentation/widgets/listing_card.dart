import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
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
        padding: const EdgeInsets.all(AppSpacing.md),
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
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const Gap(AppSpacing.xs),
            Text(
              listing.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const Gap(AppSpacing.sm),
            Text(
              Formatters.currency(listing.price),
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
