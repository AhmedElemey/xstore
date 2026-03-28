import 'package:flutter/material.dart';

import '../../domain/entities/listing_entity.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  /// Smaller padding for dense layouts (e.g. grid overlay).
  final ListingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ListingStatus.draft => 'Draft',
      ListingStatus.pending => 'Pending',
      ListingStatus.active => 'Active',
      ListingStatus.paused => 'Paused',
      ListingStatus.sold => 'Sold',
      ListingStatus.rejected => 'Rejected',
    };
    final (bg, fg) = _colors(status);
    final pad = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    final fontSize = compact ? 11.0 : 12.0;
    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
      ),
    );
  }

  /// Background and foreground for status pills (per product spec).
  (Color bg, Color fg) _colors(ListingStatus s) {
    switch (s) {
      case ListingStatus.active:
        return (const Color(0xFFDCFCE7), const Color(0xFF166534));
      case ListingStatus.pending:
        return (const Color(0xFFFEF3C7), const Color(0xFFB45309));
      case ListingStatus.paused:
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B));
      case ListingStatus.sold:
        return (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8));
      case ListingStatus.rejected:
        return (const Color(0xFFFEE2E2), const Color(0xFFB91C1C));
      case ListingStatus.draft:
        return (const Color(0xFFE2E8F0), const Color(0xFF475569));
    }
  }
}
