import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/utils/require_login.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_write_params.dart';
import '../providers/product_reviews_notifier.dart';

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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WriteReviewSheet(
        listingId: widget.listingId,
        editing: editing,
      ),
    );
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
    final myId = ref.watch(authProvider).valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reviewsTitle),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () => _openWriteReviewSheet(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reviews.isEmpty
              ? Center(child: Text(context.l10n.noReviewsYet))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: state.reviews.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.reviews.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final review = state.reviews[index];
                    return _ReviewCard(
                      review: review,
                      isMine: review.userId == myId,
                      onEdit: () => _openWriteReviewSheet(editing: review),
                      onDelete: () => _confirmDelete(review.id),
                    );
                  },
                ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
  });

  final ReviewEntity review;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                backgroundImage:
                    review.userAvatar != null && review.userAvatar!.isNotEmpty
                        ? CachedNetworkImageProvider(review.userAvatar!)
                        : null,
                child: review.userAvatar == null || review.userAvatar!.isEmpty
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
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Formatters.shortDate(review.createdAt),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating.round()
                        ? LucideIcons.star
                        : LucideIcons.starOff,
                    size: AppSpacing.xl,
                    color: AppColors.warning,
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
          Text(review.comment, style: theme.textTheme.bodyMedium),
          Divider(height: AppSpacing.x2l),
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
    if (ok) Navigator.of(context).pop();
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
