import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../addresses/presentation/providers/address_book_provider.dart';
import '../../../addresses/presentation/widgets/address_form_sheet.dart';
import '../../../addresses/presentation/widgets/remove_address_sheet.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CheckoutAddressSection extends ConsumerWidget {
  const CheckoutAddressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.checkoutDeliveryTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
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
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: InkWell(
                  onTap: () => notifier.selectAddress(i),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(
                        color: st.selectedAddressIndex == i
                            ? AppColors.primary
                            : context.textDisabled,
                        width: st.selectedAddressIndex == i ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: st.selectedAddressIndex, // ignore: deprecated_member_use
                          onChanged: (_) => notifier.selectAddress(i), // ignore: deprecated_member_use
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '🏠 ${st.savedAddresses[i].fullName}',
                                      style: AppTypography.titleMedium
                                          .copyWith(fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (st.savedAddresses[i].isDefault) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.x4l,
                                        ),
                                      ),
                                      child: Text(
                                        context.l10n.addressesMainBadge,
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${st.savedAddresses[i].phone}\n${st.savedAddresses[i].street}\n${st.savedAddresses[i].city}, ${st.savedAddresses[i].wilaya} ${st.savedAddresses[i].postalCode ?? ''}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () => showAddressFormSheet(
                                context,
                                ref,
                                existing: st.savedAddresses[i],
                                editIndex: i,
                                noSavedAddressesYet: st.savedAddresses.isEmpty,
                                onSave: (a) => notifier.updateAddress(i, a),
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
                              ),
                              child: Text(context.l10n.checkoutRemoveAddress),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
        if (st.savedAddresses.length < AddressBook.maxAddresses)
          OutlinedButton.icon(
            onPressed: () => showAddressFormSheet(
              context,
              ref,
              noSavedAddressesYet: st.savedAddresses.isEmpty,
              onSave: notifier.addAddress,
            ),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.checkoutAddAddress),
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
}
