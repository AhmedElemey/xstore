import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/utils/require_login.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_write_params.dart';
import '../providers/product_reviews_notifier.dart';
import '../widgets/already_reviewed_sheet.dart';
import '../widgets/review_avatar.dart';
import '../widgets/review_stars.dart';

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
      ref
          .read(productReviewsNotifierProvider(widget.listingId).notifier)
          .loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openWriteReviewSheet({ReviewEntity? editing}) async {
    if (!requireLogin(
      context,
      ref,
      message: context.l10n.signInToWriteReview,
    )) {
      return;
    }
    // Editing an existing review needs no re-check — the reviewer already
    // cleared this gate the first time they wrote it.
    if (editing == null) {
      final viewer = ref.read(authProvider).valueOrNull;
      ReviewEntity? myExistingReview;
      for (final r
          in ref
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
      builder: (_) =>
          _WriteReviewSheet(listingId: widget.listingId, editing: editing),
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

    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.xl,
                  18,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    const AuthBackButton(),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Text(
                        context.l10n.reviewsTitle,
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Material(
                      color: context.glassColor,
                      shape: CircleBorder(
                        side: BorderSide(color: context.borderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        constraints: const BoxConstraints.tightFor(
                          width: 44,
                          height: 44,
                        ),
                        icon: Icon(
                          LucideIcons.pencil,
                          size: 20,
                          color: context.textPrimary,
                        ),
                        onPressed: () => _openWriteReviewSheet(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.reviews.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.noReviewsYet,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.labelColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
                        ),
                        itemCount:
                            state.reviews.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.reviews.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final review = state.reviews[index];
                          return _ReviewCard(
                            review: review,
                            authorName: reviewAuthorLabel(
                              wireName: review.userName,
                              reviewUserId: review.userId,
                              viewerId: viewer?.id,
                              viewerEmail: viewer?.email,
                              viewerDisplayName: viewerName,
                            ),
                            isMine: review.userId == myId,
                            onEdit: () =>
                                _openWriteReviewSheet(editing: review),
                            onDelete: () => _confirmDelete(review.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.authorName,
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
  });

  final ReviewEntity review;
  final String authorName;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
              ReviewAvatar(name: authorName, imageUrl: review.userAvatar),
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
                      Formatters.shortDate(review.createdAt),
                      style: AppTypography.body12.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
              ReviewStars(rating: review.rating),
              if (isMine)
                PopupMenuButton<String>(
                  iconColor: context.labelColor,
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
              color: context.textPrimary.withValues(alpha: 0.85),
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
  late final _comment = TextEditingController(
    text: widget.editing?.comment ?? '',
  );
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
    final error = ref
        .read(productReviewsNotifierProvider(widget.listingId))
        .error;
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
                  color: context.amberColor,
                ),
              );
            }),
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _comment,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.l10n.reviewCommentHint,
            ),
          ),
          const Gap(AppSpacing.lg),
          // A comment is required, so the button stays disabled until one is
          // typed rather than ignoring taps.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _comment,
            builder: (context, value, _) => XstoreButton(
              label: context.l10n.submitReview,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting || value.text.trim().isEmpty
                  ? null
                  : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
