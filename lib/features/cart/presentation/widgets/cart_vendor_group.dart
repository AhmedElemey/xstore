import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';
import 'cart_item_card.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class CartVendorGroupBlock extends ConsumerWidget {
  const CartVendorGroupBlock({super.key, required this.group});

  final CartVendorGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final selectedIds = ref.watch(
      cartProvider.select((c) => c.selectedItemIds),
    );
    final store = group.vendorStoreName.trim().isNotEmpty
        ? group.vendorStoreName.trim()
        : group.vendorName.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (store.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.labelColor,
                      ),
                      child: const SizedBox.square(dimension: 8),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        store,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: context.linkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Plain Column, not a nested shrinkWrap ListView: the parent
            // scrollable already handles scrolling via slivers, and a
            // vendor's item count is small/bounded.
            for (var i = 0; i < group.items.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.lg),
                child: RepaintBoundary(
                  child: _row(
                    context,
                    ref,
                    notifier,
                    group.items[i],
                    selectedIds,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    Cart notifier,
    CartItemEntity item,
    Set<String> selectedIds,
  ) {
    return Dismissible(
      key: ValueKey<String>('dismiss_${item.id}'),
      direction: item.isAvailable
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: AppColors.white),
            Text(
              context.l10n.cartSwipeRemove,
              style: AppTypography.labelSmall.copyWith(color: AppColors.white),
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
        selected: selectedIds.contains(item.id),
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
        onOpenProduct: () =>
            context.push('${AppRoutes.product}/${item.listingId}'),
      ),
    );
  }

  void _showUndoSnack(BuildContext context, WidgetRef ref, String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    AppSnackbar.show(
      context,
      message: context.l10n.cartRemovedSnack(name),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: context.l10n.cartUndo,
        onPressed: () => ref.read(cartProvider.notifier).undoRemove(),
      ),
    );
  }

  Future<void> _promptQty(
    BuildContext context,
    WidgetRef ref,
    CartItemEntity item,
  ) async {
    final ctrl = TextEditingController(text: '${item.quantity}');
    final v = await showAnimatedDialog<int>(
      context: context,
      child: Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(dialogContext.l10n.quantity),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(ctrl.text.trim());
                Navigator.pop(dialogContext, parsed);
              },
              child: Text(dialogContext.l10n.save),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (v == null || !context.mounted) return;
    final q = v.clamp(1, item.maxQuantity);
    if (q != item.quantity) {
      await ref.read(cartProvider.notifier).updateQuantity(item.id, q);
    }
  }
}
