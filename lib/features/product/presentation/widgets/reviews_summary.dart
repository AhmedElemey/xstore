import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/entities/review_entity.dart';
import 'review_avatar.dart';
import 'review_stars.dart';

class ReviewsSummary extends ConsumerStatefulWidget {
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
  ConsumerState<ReviewsSummary> createState() => _ReviewsSummaryState();
}

class _ReviewsSummaryState extends ConsumerState<ReviewsSummary> {
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
    final counts = widget.summary.starCounts;
    final maxBar = counts.isEmpty
        ? 1
        : counts.reduce((a, b) => a > b ? a : b).clamp(1, 999999);
    final viewer = ref.watch(authProvider).valueOrNull;
    final viewerName = viewer?.displayName(context.isArabic);
    final barGradient = LinearGradient(
      colors: [context.amberColor, const Color(0xFFFF8A5B)],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.customerReviews,
            style: AppTypography.labelLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.labelColor,
            ),
          ),
          const Gap(AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.glassColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                // Amber ring filled to average / 5.
                SizedBox.square(
                  dimension: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (widget.summary.average / 5).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          color: context.amberColor,
                          backgroundColor: context.borderColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.summary.average.toStringAsFixed(1),
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 30,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            '${widget.summary.totalCount} ${context.l10n.ratingsWord}',
                            style: AppTypography.body12.copyWith(
                              color: context.labelColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(18),
                Expanded(
                  child: Column(
                    children: [
                      for (var star = 5; star >= 1; star--)
                        Padding(
                          padding: EdgeInsets.only(
                            top: star == 5 ? 0 : AppSpacing.xs + 2,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: AppSpacing.lg,
                                child: Text(
                                  '$star',
                                  style: AppTypography.body12.copyWith(
                                    color: context.labelColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Container(
                                    height: 6,
                                    color: context.borderColor,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: FractionallySizedBox(
                                      widthFactor: counts.isNotEmpty
                                          ? (counts[5 - star] / maxBar)
                                                .clamp(0.0, 1.0)
                                                .toDouble()
                                          : 0,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: barGradient,
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
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
          ),
          const Gap(AppSpacing.lg),
          for (var i = 0; i < widget.reviews.length && i < 3; i++)
            _ReviewTile(
              review: widget.reviews[i],
              authorName: reviewAuthorLabel(
                wireName: widget.reviews[i].userName,
                viewerEmail: viewer?.email,
                viewerDisplayName: viewerName,
              ),
              expanded: i < _expanded.length ? _expanded[i] : false,
              onToggle: () => setState(() {
                if (i < _expanded.length) _expanded[i] = !_expanded[i];
              }),
            ),
          const Gap(AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: widget.onSeeAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.linkColor,
                side: BorderSide(color: context.borderColor),
                shape: const StadiumBorder(),
                textStyle: AppTypography.labelLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
    required this.authorName,
    required this.expanded,
    required this.onToggle,
  });

  final ProductReviewEntity review;
  final String authorName;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = review.userAvatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReviewAvatar(
                name: authorName,
                imageUrl: hasAvatar ? avatarUrl : null,
              ),
              const Gap(AppSpacing.md - 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      Formatters.shortDate(review.date),
                      style: AppTypography.body12.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
              ReviewStars(rating: review.stars),
            ],
          ),
          const Gap(AppSpacing.sm),
          ExpandableText(
            text: review.text,
            maxLines: 2,
            expanded: expanded,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.55,
              color: context.textPrimary.withValues(alpha: 0.85),
            ),
            toggle: TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(foregroundColor: context.linkColor),
              child: Text(
                expanded ? context.l10n.readLess : context.l10n.readMore,
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            '${context.l10n.helpfulPrompt}${review.helpfulCount}',
            style: AppTypography.body12.copyWith(color: context.labelColor),
          ),
        ],
      ),
    );
  }
}
