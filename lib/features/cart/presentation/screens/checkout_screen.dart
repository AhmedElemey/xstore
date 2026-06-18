import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/checkout_address_section.dart';
import '../../../../core/network/app_error_messages.dart';
import '../widgets/checkout_error_banner.dart';
import '../widgets/checkout_payment_section.dart';
import '../widgets/checkout_primary_footer.dart';
import '../widgets/checkout_progress.dart';
import '../widgets/checkout_review_section.dart';
import '../widgets/order_confirmation_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    Future<void> onPrimary() async {
      if (st.currentStep < 3) {
        notifier.nextStep();
        return;
      }
      final order = await notifier.placeOrder();
      if (!context.mounted) return;
      if (order == null) {
        final ck = ref.read(checkoutProvider);
        final c = ref.read(cartProvider);
        final msg = ck.error != null
            ? checkoutErrorMessage(context, ck.error)
            : resolveAppError(context, c.error);
        AppSnackbar.error(context, msg);
        return;
      }
      ref.invalidate(ordersNotifierProvider);
      await showOrderConfirmationSheet(context, orderId: order.id);
    }

    final busy = st.isPlacingOrder;
    final label = st.currentStep < 3
        ? context.l10n.checkoutContinue
        : context.l10n.checkoutPlaceOrderTotal(
            context.formatCurrency(cart.total),
          );

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.checkoutTitle),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (st.currentStep > 1) {
              notifier.previousStep();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          CheckoutProgress(step: st.currentStep),
          CheckoutErrorBanner(messageKey: st.error),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: switch (st.currentStep) {
                1 => const CheckoutAddressSection(),
                2 => const CheckoutPaymentSection(),
                _ => const CheckoutReviewSection(),
              },
            ),
          ),
          CheckoutPrimaryFooter(
            label: label,
            busy: busy,
            onPressed: busy ? null : onPrimary,
          ),
        ],
      ),
    );
  }
}
