import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';
import 'cart_item_card.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CartVendorGroupBlock extends ConsumerWidget {
  const CartVendorGroupBlock({
    super.key,
    required this.group,
  });

  final CartVendorGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final selectedIds = ref.watch(
      cartProvider.select((c) => c.selectedItemIds),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSpacing.md),
          child: InkWell(
            onTap: () => context.push(
              '${AppRoutes.sellerProfile}/${group.vendorId}',
            ),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🏪 ${group.vendorStoreName}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '(${group.items.length} items)',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${AppStrings.starChar} ${group.vendorRating.toStringAsFixed(1)}${AppStrings.reviewsDotSeparator}${AppStrings.verifiedSeller}',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.items.length,
          itemBuilder: (context, index) {
            final item = group.items[index];
            final selected = selectedIds.contains(item.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RepaintBoundary(
                child: Dismissible(
                  key: ValueKey<String>('dismiss_${item.id}'),
                  direction: item.isAvailable
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline, color: AppColors.white),
                        Text(
                          AppStrings.cartSwipeRemove,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (_) async {
                    ref.read(cartProvider.notifier).removeItem(item.id);
                    if (context.mounted) {
                      _showUndoSnack(context, ref, item.listingName);
                    }
                    return true;
                  },
                  child: CartItemCard(
                    key: ValueKey<String>('cart-item-${item.id}'),
                    item: item,
                    selected: selected,
                    onToggleSelect: () => notifier.toggleItemSelection(item.id),
                    onDecrement: () {
                      if (item.quantity <= 1) {
                        notifier.removeItem(item.id);
                        if (context.mounted) {
                          _showUndoSnack(context, ref, item.listingName);
                        }
                      } else {
                        notifier.updateQuantity(item.id, item.quantity - 1);
                      }
                    },
                    onIncrement: () {
                      if (item.quantity < item.maxQuantity) {
                        notifier.updateQuantity(item.id, item.quantity + 1);
                      }
                    },
                    onEditQuantity: () => _promptQty(context, ref, item),
                    onRemove: () {
                      notifier.removeItem(item.id);
                      if (context.mounted) {
                        _showUndoSnack(context, ref, item.listingName);
                      }
                    },
                    onSaveForLater: () => notifier.saveForLater(item.id),
                    onOpenProduct: () => context.push(
                      '${AppRoutes.product}/${item.listingId}',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showUndoSnack(BuildContext context, WidgetRef ref, String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.cartRemovedSnack(name)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: AppStrings.cartUndo,
          onPressed: () => ref.read(cartProvider.notifier).undoRemove(),
        ),
      ),
    );
  }

  Future<void> _promptQty(
    BuildContext context,
    WidgetRef ref,
    CartItemEntity item,
  ) async {
    final ctrl = TextEditingController(text: '${item.quantity}');
    final v = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.quantity),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(ctrl.text.trim());
              Navigator.pop(ctx, parsed);
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
    if (v == null || !context.mounted) return;
    final q = v.clamp(1, item.maxQuantity);
    if (q != item.quantity) {
      await ref.read(cartProvider.notifier).updateQuantity(item.id, q);
    }
  }
}
