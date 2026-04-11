import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/product_review_entity.dart';

class ReviewsSummary extends StatefulWidget {
  const ReviewsSummary({
    super.key,
    required this.summary,
    required this.reviews,
    required this.onSeeAll,
  });

  final ReviewSummaryEntity summary;
  final List<ProductReviewEntity> reviews;
  final VoidCallback onSeeAll;

  @override
  State<ReviewsSummary> createState() => _ReviewsSummaryState();
}

class _ReviewsSummaryState extends State<ReviewsSummary> {
  final List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _syncExpanded();
  }

  @override
  void didUpdateWidget(ReviewsSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reviews.length != widget.reviews.length) {
      _syncExpanded();
    }
  }

  void _syncExpanded() {
    _expanded
      ..clear()
      ..addAll(List.filled(widget.reviews.length, false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = widget.summary.starCounts;
    final maxBar = counts.isEmpty
        ? 1
        : counts.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.customerReviews,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    widget.summary.average.toStringAsFixed(1),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    LucideIcons.star,
                    color: AppColors.warning,
                    size: AppSpacing.x3l - AppSpacing.xs,
                  ),
                  Text(
                    '${widget.summary.totalCount} ${context.l10n.ratingsWord}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.x2l),
              Expanded(
                child: Column(
                  children: [
                    for (var star = 5; star >= 1; star--)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            SizedBox(
                              width: AppSpacing.x3l - AppSpacing.xs,
                              child: Text(
                                '$star★',
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: counts.isNotEmpty
                                      ? counts[5 - star] / maxBar
                                      : 0,
                                  minHeight: 8,
                                  backgroundColor: theme
                                      .colorScheme.surfaceContainerHighest,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.x2l),
          for (var i = 0; i < widget.reviews.length && i < 3; i++)
            _ReviewTile(
              review: widget.reviews[i],
              expanded: i < _expanded.length ? _expanded[i] : false,
              onToggle: () => setState(() {
                if (i < _expanded.length) _expanded[i] = !_expanded[i];
              }),
            ),
          const Gap(AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onSeeAll,
              child: Text(context.l10n.seeAllReviews),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.expanded,
    required this.onToggle,
  });

  final ProductReviewEntity review;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: review.userAvatarUrl != null &&
                        review.userAvatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(review.userAvatarUrl!)
                    : null,
                child: review.userAvatarUrl == null ||
                        review.userAvatarUrl!.isEmpty
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Formatters.shortDate(review.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.stars.round()
                        ? LucideIcons.star
                        : LucideIcons.starOff,
                    size: AppSpacing.xl,
                    color: AppColors.warning,
                  );
                }),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: Text(
              review.text,
              maxLines: expanded ? null : 2,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onToggle,
              child: Text(expanded ? context.l10n.readLess : context.l10n.readMore),
            ),
          ),
          Text(
            '${context.l10n.helpfulPrompt}${review.helpfulCount}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Divider(height: AppSpacing.x2l),
        ],
      ),
    );
  }
}
