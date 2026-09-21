import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/address_location_display.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../providers/address_book_provider.dart';
import '../widgets/address_form_sheet.dart';
import '../widgets/remove_address_sheet.dart';

/// Profile's "My Addresses" screen — add/edit/delete a saved address and
/// choose which one is the account's main (default) address. This is the
/// account-wide address book; checkout's own address step reads the same
/// [addressBookProvider] but only ever changes the per-order selection,
/// never which address is main.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressBookProvider);
    final notifier = ref.read(addressBookProvider.notifier);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.menuAddresses),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3l),
                child: Text(
                  context.l10n.addressesEmptyState,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              )
            else
              for (var i = 0; i < addresses.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AddressCard(
                    address: addresses[i],
                    onEdit: () => showAddressFormSheet(
                      context,
                      ref,
                      existing: addresses[i],
                      editIndex: i,
                      noSavedAddressesYet: addresses.isEmpty,
                      onSave: (a) => notifier.updateAddress(i, a),
                    ),
                    onRemove: () => showRemoveAddressSheet(
                      context,
                      onConfirm: () => notifier.removeAddress(i),
                    ),
                    onSetMain: addresses[i].isDefault
                        ? null
                        : () => notifier.setMainAddress(i),
                  ),
                ),
            const SizedBox(height: AppSpacing.sm),
            if (addresses.length < AddressBook.maxAddresses)
              OutlinedButton.icon(
                onPressed: () => showAddressFormSheet(
                  context,
                  ref,
                  noSavedAddressesYet: addresses.isEmpty,
                  onSave: notifier.addAddress,
                ),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.checkoutAddAddress),
              )
            else
              Text(
                context.l10n.addressesMaxReached,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onRemove,
    required this.onSetMain,
  });

  final OrderAddress address;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback? onSetMain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = resolveAddressLocation(ref, address);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : context.textDisabled,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '🏠 ${address.fullName}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.x4l),
                  ),
                  child: Text(
                    context.l10n.addressesMainBadge,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${address.phone}\n${address.street}\n'
            '${location.city}, ${location.wilaya} '
            '${address.postalCode ?? ''}',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (onSetMain != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSetMain,
                    child: Text(context.l10n.addressesSetAsMain),
                  ),
                ),
              if (onSetMain != null) const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onEdit,
                child: Text(context.l10n.checkoutEdit),
              ),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(context.l10n.checkoutRemoveAddress),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
