import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';

class ShippingInfoSheet extends StatefulWidget {
  const ShippingInfoSheet({super.key, required this.onConfirm});

  final Future<void> Function(ShippingInfo info) onConfirm;

  @override
  State<ShippingInfoSheet> createState() => _ShippingInfoSheetState();
}

class _ShippingInfoSheetState extends State<ShippingInfoSheet> {
  final _trackingCtrl = TextEditingController();
  final _courierCtrl = TextEditingController();
  late DateTime _date;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
  }

  @override
  void dispose() {
    _trackingCtrl.dispose();
    _courierCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.vendorShippingInfoTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _trackingCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.ordersTrackingNumberLabel,
                hintText: context.l10n.vendorTrackingHint,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _courierCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.ordersCourierNameLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: _date,
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Text(
                '${context.l10n.ordersEstimatedDeliveryLabel}: '
                '${DateFormat('EEEE, MMM d, yyyy').format(_date)}',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            final tracking = _trackingCtrl.text.trim();
                            final courier = _courierCtrl.text.trim();
                            setState(() => _loading = true);
                            await widget.onConfirm(
                              ShippingInfo(
                                trackingNumber:
                                    tracking.isEmpty ? null : tracking,
                                courierName: courier.isEmpty ? null : courier,
                                estimatedDelivery: _date,
                              ),
                            );
                            if (!mounted) return;
                            navigator.pop();
                          },
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.vendorConfirmShipment),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
