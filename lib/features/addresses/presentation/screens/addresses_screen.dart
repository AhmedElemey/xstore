import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/address_location_display.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
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
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    const AuthBackButton(),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        context.l10n.menuAddresses,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 20,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.x3l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (addresses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.x3l,
                          ),
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
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
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
                      const SizedBox(height: AppSpacing.xs),
                      if (addresses.length < AddressBook.maxAddresses)
                        OutlinedButton(
                          onPressed: () => showAddressFormSheet(
                            context,
                            ref,
                            noSavedAddressesYet: addresses.isEmpty,
                            onSave: notifier.addAddress,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.linkColor,
                            side: BorderSide(color: context.borderColor),
                            shape: const StadiumBorder(),
                            minimumSize: const Size.fromHeight(48),
                            textStyle: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(context.l10n.checkoutAddAddress),
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
              ),
            ],
          ),
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
    final accent = context.brandGradient.first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: address.isDefault
            ? accent.withValues(alpha: 0.08)
            : context.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault ? accent : context.borderColor,
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
                  address.fullName,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: AppSpacing.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    child: Text(
                      context.l10n.addressesMainBadge,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: context.onBrandColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${address.street}\n'
            '${location.city}, ${location.wilaya} '
            '${address.postalCode ?? ''}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            address.phone,
            style: AppTypography.mono.copyWith(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: context.linkColor,
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.xl),
                  minimumSize: const Size(0, 44),
                ),
                child: Text(context.l10n.checkoutEdit),
              ),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                ),
                child: Text(context.l10n.checkoutRemoveAddress),
              ),
              if (onSetMain != null) ...[
                const Spacer(),
                TextButton(
                  onPressed: onSetMain,
                  style: TextButton.styleFrom(
                    foregroundColor: context.linkColor,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 44),
                  ),
                  child: Text(context.l10n.addressesSetAsMain),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
