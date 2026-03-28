import 'package:flutter/material.dart';

import '../../domain/entities/listing_entity.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ListingStatus.draft => 'Draft',
      ListingStatus.pending => 'Pending',
      ListingStatus.active => 'Active',
    };
    final color = switch (status) {
      ListingStatus.draft => Theme.of(context).colorScheme.outline,
      ListingStatus.pending => Theme.of(context).colorScheme.tertiary,
      ListingStatus.active => Theme.of(context).colorScheme.primary,
    };
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
      backgroundColor: color.withValues(alpha: 0.12),
    );
  }
}
