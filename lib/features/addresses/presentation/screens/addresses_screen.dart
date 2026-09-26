import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/address_location_display.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/space_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
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
      appBar: AppBar(title: Text(context.l10n.menuAddresses)),
      body: SpaceBackground(
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: addresses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.x2l),
                          child: Text(
                            context.l10n.addressesEmptyState,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, i) => _AddressCard(
                          address: addresses[i],
                          onEdit: () => showAddressFormSheet(
                            context,
                            ref,
                            existing: addresses[i],
                            editIndex: i,
                            noSavedAddressesYet: false,
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: addresses.length < AddressBook.maxAddresses
                    ? XstoreButton(
                        label: context.l10n.checkoutAddAddress,
                        onPressed: () => showAddressFormSheet(
                          context,
                          ref,
                          noSavedAddressesYet: addresses.isEmpty,
                          onSave: notifier.addAddress,
                        ),
                      )
                    : Text(
                        context.l10n.addressesMaxReached,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orbit address row: glowing dot (plasma for the main address), name with
/// a DEFAULT pill, the address lines and an edit disc. Set-as-main and
/// remove are app-only actions under the text.
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
    final accent = context.primaryColor;
    final dot = address.isDefault ? accent : AppColors.nova;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: address.isDefault ? accent.withValues(alpha: 0.45) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot,
              boxShadow: [BoxShadow(color: dot, blurRadius: 10)],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  children: [
                    Text(
                      address.fullName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.l10n.addressesMainBadge.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: context.isDark
                                ? AppColors.space
                                : AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${address.street}, ${location.city}, ${location.wilaya}'
                  '${(address.postalCode ?? '').isEmpty ? '' : ' ${address.postalCode}'}'
                  '\n${address.phone}',
                  style: AppTypography.bodyMedium.copyWith(
                    height: 1.45,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    if (onSetMain != null)
                      TextButton(
                        onPressed: onSetMain,
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(44, 36),
                        ),
                        child: Text(context.l10n.addressesSetAsMain),
                      ),
                    TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorLight,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(44, 36),
                      ),
                      child: Text(context.l10n.checkoutRemoveAddress),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OrbitCircleButton(
            tooltip: context.l10n.checkoutEdit,
            onPressed: onEdit,
            child: Icon(
              LucideIcons.pencil,
              size: 18,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
