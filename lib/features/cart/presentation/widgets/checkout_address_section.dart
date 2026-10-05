import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../addresses/presentation/providers/address_book_provider.dart';
import '../../../addresses/presentation/widgets/address_form_sheet.dart';
import '../../../addresses/presentation/widgets/remove_address_sheet.dart';
import '../providers/checkout_provider.dart';
import '../providers/checkout_state.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/address_location_display.dart';

class CheckoutAddressSection extends ConsumerWidget {
  const CheckoutAddressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);
    final accent = context.brandGradient.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.checkoutDeliveryTitle,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (st.savedAddresses.isEmpty)
          Text(
            context.l10n.checkoutErrorNoAddress,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          )
        else
          for (var i = 0; i < st.savedAddresses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _AddressCard(
                selected: st.selectedAddressIndex == i,
                accent: accent,
                onSelect: () => notifier.selectAddress(i),
                child: _addressBody(context, ref, st, notifier, i),
              ),
            ),
        const SizedBox(height: AppSpacing.xs),
        if (st.savedAddresses.length < AddressBook.maxAddresses)
          OutlinedButton(
            onPressed: () => showAddressFormSheet(
              context,
              ref,
              noSavedAddressesYet: st.savedAddresses.isEmpty,
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
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _addressBody(
    BuildContext context,
    WidgetRef ref,
    CheckoutState st,
    Checkout notifier,
    int i,
  ) {
    final a = st.savedAddresses[i];
    final loc = resolveAddressLocation(ref, a);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                a.fullName,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (a.isDefault) ...[
              const SizedBox(width: AppSpacing.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.brandGradient.first,
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
          '${a.street}\n${loc.city}, ${loc.wilaya} ${a.postalCode ?? ''}',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          a.phone,
          style: AppTypography.mono.copyWith(
            fontSize: 13,
            color: context.textSecondary,
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => showAddressFormSheet(
                context,
                ref,
                existing: a,
                editIndex: i,
                noSavedAddressesYet: st.savedAddresses.isEmpty,
                onSave: (updated) => notifier.updateAddress(i, updated),
              ),
              style: TextButton.styleFrom(
                foregroundColor: context.linkColor,
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.xl),
                minimumSize: const Size(0, 44),
              ),
              child: Text(context.l10n.checkoutEdit),
            ),
            TextButton(
              onPressed: () => showRemoveAddressSheet(
                context,
                onConfirm: () => notifier.removeAddress(i),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 44),
              ),
              child: Text(context.l10n.checkoutRemoveAddress),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.selected,
    required this.accent,
    required this.onSelect,
    required this.child,
  });

  final bool selected;
  final Color accent;
  final VoidCallback onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: AppColors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : context.glassColor,
          borderRadius: radius,
          border: Border.all(
            color: selected ? accent : context.borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onSelect,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: selected, // ignore: deprecated_member_use
                  onChanged: (_) => onSelect(), // ignore: deprecated_member_use
                  activeColor: accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
