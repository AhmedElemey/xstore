import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/checkout_provider.dart';
import 'checkout_add_address_sheet.dart';

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
          AppStrings.checkoutDeliveryTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (st.savedAddresses.isEmpty)
          Text(
            AppStrings.checkoutErrorNoAddress,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          for (var i = 0; i < st.savedAddresses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: AppColors.cardBg,
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
                            : AppColors.textDisabled,
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
                              Text(
                                '🏠 ${st.savedAddresses[i].fullName}',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${st.savedAddresses[i].phone}\n${st.savedAddresses[i].street}\n${st.savedAddresses[i].city}, ${st.savedAddresses[i].wilaya} ${st.savedAddresses[i].postalCode ?? ''}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(AppStrings.checkoutEdit),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => showCheckoutAddAddressSheet(context, ref),
          icon: const Icon(Icons.add),
          label: Text(AppStrings.checkoutAddAddress),
        ),
      ],
    );
  }
}
