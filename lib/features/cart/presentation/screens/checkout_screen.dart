import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
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
import '../../../../shared/utils/require_phone_verified.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/space_background.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    // Orbit checkout is one page: the footer always places the order;
    // placeOrder() itself rejects a missing address (shown in the banner).
    Future<void> onPrimary() async {
      // Proactive check — the backend rejects this with the same
      // phoneNotVerifiedErrorCode below, but checking first skips a
      // guaranteed-failing request and gets the OTP sheet up sooner.
      if (!await requirePhoneVerified(context, ref)) return;
      if (!context.mounted) return;
      // A double tap: the first onPrimary is already placing — bail
      // silently instead of surfacing the guard's null as a failure.
      if (ref.read(checkoutProvider).isPlacingOrder) return;
      // Checkout places one real order per cart line (no batch endpoint
      // exists) — capture what was actually submitted so a partial
      // failure can be told apart from full success below.
      final requestedCount = cart.selectedAvailableItems.length;
      final order = await notifier.placeOrder();
      if (!context.mounted) return;
      if (order == null) {
        final ck = ref.read(checkoutProvider);
        final c = ref.read(cartProvider);
        final errorCode = ck.error ?? c.error;
        if (errorCode == phoneNotVerifiedErrorCode) {
          // Profile already marked verified but the backend still 400'd —
          // don't recurse requirePhoneVerified (it would return true
          // immediately and loop). Surface the error instead.
          final alreadyVerified = ref
                  .read(profileNotifierProvider)
                  .profile
                  ?.isPhoneVerified ??
              false;
          if (alreadyVerified) {
            AppSnackbar.error(
              context,
              checkoutErrorMessage(context, errorCode),
            );
            return;
          }
          final verified = await requirePhoneVerified(context, ref);
          if (!context.mounted) return;
          if (verified) {
            await onPrimary();
          }
          return;
        }
        final msg = ck.error != null
            ? checkoutErrorMessage(context, ck.error)
            : resolveAppError(context, c.error);
        AppSnackbar.error(context, msg);
        return;
      }
      ref.invalidate(ordersNotifierProvider);
      final missing = requestedCount - order.items.length;
      if (missing > 0 && context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.l10n.checkoutPartialOrderTitle),
            content: Text(context.l10n.checkoutPartialOrderWarning(missing)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.checkoutPartialOrderAck),
              ),
            ],
          ),
        );
        if (!context.mounted) return;
      }
      await showOrderConfirmationSheet(
        context,
        orderId: order.id,
        cashDue: order.paymentMethod == PaymentMethod.cashOnDelivery
            ? order.total
            : null,
      );
    }

    final busy = st.isPlacingOrder;
    final label = context.l10n.checkoutPlaceOrderTotal(
      context.formatCurrency(cart.total),
    );

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(title: Text(context.l10n.checkoutTitle)),
      body: SpaceBackground(child: Column(
        children: [
          CheckoutProgress(hasAddress: st.selectedAddressIndex != null),
          CheckoutErrorBanner(messageKey: st.error),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckoutAddressSection(),
                  SizedBox(height: AppSpacing.x2l),
                  CheckoutPaymentSection(),
                  SizedBox(height: AppSpacing.x2l),
                  CheckoutReviewSection(),
                ],
              ),
            ),
          ),
          CheckoutPrimaryFooter(
            label: label,
            busy: busy,
            onPressed: busy ? null : onPrimary,
          ),
        ],
      )),
    );
  }
}
