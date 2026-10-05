import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/utils/address_location_display.dart';
import '../../../../shared/utils/legal_links.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../orders/presentation/widgets/order_price_breakdown.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import 'cart_summary_card.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CheckoutReviewSection extends ConsumerWidget {
  const CheckoutReviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final st = ref.watch(checkoutProvider);
    final items = cart.selectedAvailableItems.toList();
    final idx = st.selectedAddressIndex;
    final addr = idx != null && idx >= 0 && idx < st.savedAddresses.length
        ? st.savedAddresses[idx]
        : null;
    final pay = st.selectedPayment;
    final note = st.deliveryNote.trim();
    final vendors = items.map((e) => e.vendorId).toSet().length;
    final addrLocation = addr == null
        ? null
        : resolveAddressLocation(ref, addr);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.checkoutReviewTitle,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 18,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.checkoutItemsFromSellers(items.length, vendors),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final it in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: AppCachedNetworkImage(
                              imageUrl: it.listingImage,
                              fit: BoxFit.cover,
                              memCacheWidth: 120,
                              memCacheHeight: 120,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.listingName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text:
                                      '${context.l10n.quantity} ${it.quantity} · ',
                                  children: [
                                    TextSpan(
                                      text: context.formatCurrency(
                                        it.price * it.quantity,
                                      ),
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.amberColor,
                                      ),
                                    ),
                                  ],
                                ),
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Divider(height: AppSpacing.x2l, color: context.borderColor),
                if (addr != null && addrLocation != null) ...[
                  _iconLine(
                    context,
                    LucideIcons.mapPin,
                    '${addr.street}, ${addrLocation.city}, ${addrLocation.wilaya}',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (pay != null)
                  _iconLine(
                    context,
                    LucideIcons.banknote,
                    paymentMethodLabel(context, pay),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.checkoutEstimatedDelivery,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.checkoutDeliveryNoteLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    note,
                    style: AppTypography.bodySmall.copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const CartSummaryCard(),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              context.l10n.checkoutTermsBefore,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                height: 1.45,
              ),
            ),
            InkWell(
              onTap: () => launchLegalUrl(xstoreTermsUrl),
              child: Text(
                context.l10n.menuTerms,
                style: AppTypography.bodySmall.copyWith(
                  color: context.linkColor,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconLine(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.linkColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}
