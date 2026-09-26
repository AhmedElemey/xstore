import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/utils/require_login.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/space_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_write_params.dart';
import '../providers/product_detail_notifier.dart';
import '../providers/product_reviews_notifier.dart';
import '../widgets/already_reviewed_sheet.dart';

/// Full reviews list for a listing — paginated, with write/edit/delete.
class ProductReviewsScreen extends ConsumerStatefulWidget {
  const ProductReviewsScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ProductReviewsScreen> createState() =>
      _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends ConsumerState<ProductReviewsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels > p.maxScrollExtent - 120) {
      ref.read(productReviewsNotifierProvider(widget.listingId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openWriteReviewSheet({ReviewEntity? editing}) async {
    if (!requireLogin(context, ref, message: context.l10n.signInToWriteReview)) {
      return;
    }
    // Editing an existing review needs no re-check — the reviewer already
    // cleared this gate the first time they wrote it.
    if (editing == null) {
      final viewer = ref.read(authProvider).valueOrNull;
      ReviewEntity? myExistingReview;
      for (final r in ref
          .read(productReviewsNotifierProvider(widget.listingId))
          .reviews) {
        if (isOwnReview(r, userId: viewer?.id, email: viewer?.email)) {
          myExistingReview = r;
          break;
        }
      }
      if (myExistingReview != null) {
        await showAlreadyReviewedSheet(
          context,
          onEdit: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _openWriteReviewSheet(editing: myExistingReview);
            });
          },
        );
        return;
      }
      if (!await _canWriteNewReview()) {
        if (!mounted) return;
        AppSnackbar.error(context, context.l10n.reviewRequiresDeliveredOrder);
        return;
      }
    }
    if (!mounted) return;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WriteReviewSheet(
        listingId: widget.listingId,
        editing: editing,
      ),
    );
    if (!mounted) return;
    if (result == 'added') {
      AppSnackbar.success(context, context.l10n.ordersReviewThanks);
    } else if (result == 'already') {
      await showAlreadyReviewedSheet(context);
    }
  }

  /// Verified-purchase gate: only a consumer with a delivered order for
  /// this listing may write a NEW review (editing an existing one skips
  /// this — see caller).
  Future<bool> _canWriteNewReview() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null || user.role != UserRole.consumer) return false;
    await ref.read(ordersNotifierProvider.notifier).fetchOrders();
    final orders = ref.read(ordersNotifierProvider).orders;
    return hasDeliveredOrderForListing(orders, widget.listingId);
  }

  Future<void> _confirmDelete(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteReviewConfirmTitle),
        content: Text(context.l10n.deleteReviewConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              context.l10n.deleteReview,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(productReviewsNotifierProvider(widget.listingId).notifier)
          .deleteReview(reviewId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productReviewsNotifierProvider(widget.listingId));
    final viewer = ref.watch(authProvider).valueOrNull;
    final myId = viewer?.id;
    final viewerName = viewer?.displayName(context.isArabic);

    final summary = _summaryOf(state.reviews);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reviewsTitle),
        actions: [
          OrbitCircleButton(
            tooltip: context.l10n.writeReview,
            onPressed: () => _openWriteReviewSheet(),
            child: Icon(
              LucideIcons.pencil,
              size: 20,
              color: context.textPrimary,
            ),
          ),
          const Gap(AppSpacing.lg),
        ],
      ),
      body: SpaceBackground(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.reviews.isEmpty
                ? Center(child: Text(context.l10n.noReviewsYet))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.x3l,
                    ),
                    itemCount: state.reviews.length +
                        1 +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _RatingOverview(summary: summary),
                        );
                      }
                      final i = index - 1;
                      if (i >= state.reviews.length) {
                        return const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final review = state.reviews[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ReviewCard(
                          review: review,
                          orbIndex: i,
                          authorName: reviewAuthorLabel(
                            wireName: review.userName,
                            reviewUserId: review.userId,
                            viewerId: viewer?.id,
                            viewerEmail: viewer?.email,
                            viewerDisplayName: viewerName,
                          ),
                          isMine: review.userId == myId,
                          onEdit: () => _openWriteReviewSheet(editing: review),
                          onDelete: () => _confirmDelete(review.id),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  /// The product page's summary (whole-listing counts) when it is loaded,
  /// else one built from the reviews fetched so far.
  ReviewSummaryEntity _summaryOf(List<ReviewEntity> reviews) {
    final detail = productDetailProvider(widget.listingId);
    final fromDetail = ref.exists(detail)
        ? ref.watch(detail.select((a) => a.valueOrNull?.reviewSummary))
        : null;
    if (fromDetail != null && fromDetail.totalCount > 0) return fromDetail;
    final counts = List<int>.filled(5, 0);
    var sum = 0.0;
    for (final r in reviews) {
      sum += r.rating;
      counts[5 - r.rating.round().clamp(1, 5)]++;
    }
    return ReviewSummaryEntity(
      average: reviews.isEmpty ? 0 : sum / reviews.length,
      totalCount: reviews.length,
      starCounts: counts,
    );
  }
}

/// Orbit rating card: amber ring with the average, and 5→1 star bars.
class _RatingOverview extends StatelessWidget {
  const _RatingOverview({required this.summary});

  final ReviewSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalCount;
    final counted = summary.starCounts.fold<int>(0, (a, b) => a + b);
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: (summary.average / 5).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  color: context.cashColor,
                  backgroundColor: context.borderColor,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      summary.average.toStringAsFixed(1),
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      '$total${context.l10n.reviewsSuffix}',
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textSecondary,
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
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          child: Text(
                            '${5 - i}',
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              value: counted == 0
                                  ? 0
                                  : summary.starCounts[i] / counted,
                              color: context.cashColor,
                              backgroundColor: context.borderColor,
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
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.orbIndex,
    required this.authorName,
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
  });

  final ReviewEntity review;
  final int orbIndex;
  final String authorName;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final avatar = review.userAvatar;
    final hasAvatar = avatar != null && avatar.isNotEmpty;
    final stars = review.rating.round().clamp(0, 5);
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: orbitOrbGradient(orbIndex),
                ),
                child: hasAvatar
                    ? AppCachedNetworkImage(
                        imageUrl: avatar,
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                        memCacheWidth: 102,
                        memCacheHeight: 102,
                      )
                    : Text(
                        authorName.isNotEmpty
                            ? authorName[0].toUpperCase()
                            : '?',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.space,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const Gap(AppSpacing.sm + 2),
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
                      Formatters.shortDate(review.createdAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: '$stars/5',
                child: ExcludeSemantics(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '★' * stars),
                        TextSpan(
                          text: '★' * (5 - stars),
                          style: TextStyle(color: context.borderColor),
                        ),
                      ],
                    ),
                    style: AppTypography.labelMedium.copyWith(
                      color: context.cashColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (isMine)
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.l10n.editReview),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(context.l10n.deleteReview),
                    ),
                  ],
                ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(
            review.comment,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.55,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends ConsumerStatefulWidget {
  const _WriteReviewSheet({required this.listingId, this.editing});

  final String listingId;
  final ReviewEntity? editing;

  @override
  ConsumerState<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<_WriteReviewSheet> {
  late double _rating = widget.editing?.rating ?? 5;
  late final _comment = TextEditingController(text: widget.editing?.comment ?? '');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _comment.clear();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_comment.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final ok = await ref
        .read(productReviewsNotifierProvider(widget.listingId).notifier)
        .submitReview(
          ReviewWriteParams(rating: _rating, comment: _comment.text.trim()),
          editingReviewId: widget.editing?.id,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      _comment.clear();
      _rating = widget.editing?.rating ?? 5;
      Navigator.of(context).pop(widget.editing == null ? 'added' : 'updated');
      return;
    }
    final error =
        ref.read(productReviewsNotifierProvider(widget.listingId)).error;
    if (error != null && error.toLowerCase().contains('already')) {
      _comment.clear();
      Navigator.of(context).pop('already');
      return;
    }
    if (error != null) AppSnackbar.error(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.editing == null
                ? context.l10n.writeReview
                : context.l10n.editReview,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(AppSpacing.lg),
          Text(context.l10n.reviewRatingLabel),
          const Gap(AppSpacing.sm),
          Row(
            children: List.generate(5, (i) {
              final starValue = i + 1.0;
              return IconButton(
                onPressed: () => setState(() => _rating = starValue),
                icon: Icon(
                  starValue <= _rating ? LucideIcons.star : LucideIcons.starOff,
                  color: AppColors.warning,
                ),
              );
            }),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _comment,
            maxLines: 4,
            decoration: InputDecoration(hintText: context.l10n.reviewCommentHint),
          ),
          const Gap(AppSpacing.lg),
          XstoreButton(
            label: context.l10n.submitReview,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
