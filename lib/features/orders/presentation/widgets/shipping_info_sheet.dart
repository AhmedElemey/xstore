import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/order_entity.dart';

class ShippingInfoSheet extends StatefulWidget {
  const ShippingInfoSheet({super.key, required this.onConfirm});

  final Future<void> Function(ShippingInfo info) onConfirm;

  @override
  State<ShippingInfoSheet> createState() => _ShippingInfoSheetState();
}

class _ShippingInfoSheetState extends State<ShippingInfoSheet> {
  static const _couriers = <String>[
    'Algérie Poste',
    'Yalidine Express',
    'Zr Express',
    'Maystro Delivery',
    'Guepex',
    'Other',
  ];

  final _trackingCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _courier = _couriers.first;
  DateTime? _date;
  var _loading = false;

  @override
  void dispose() {
    _trackingCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _date != null;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.vendorShippingInfoTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _trackingCtrl,
              decoration: const InputDecoration(hintText: AppStrings.vendorTrackingHint),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _courier,
              items: _couriers
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _courier = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(now.year, now.month, now.day),
                  lastDate: now.add(const Duration(days: 30)),
                  initialDate: now.add(const Duration(days: 2)),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Text(
                _date == null
                    ? AppStrings.ordersEstimatedDeliveryLabel
                    : DateFormat('EEEE, MMM d, yyyy').format(_date!),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: AppStrings.vendorShippingNoteHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: !canSubmit || _loading
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            setState(() => _loading = true);
                            await widget.onConfirm(
                              ShippingInfo(
                                trackingNumber: _trackingCtrl.text.trim(),
                                courierName: _courier == 'Other' ? null : _courier,
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
                        : Text(AppStrings.vendorConfirmShipment),
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
